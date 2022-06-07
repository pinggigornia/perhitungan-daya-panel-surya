using CSV
using DataFrames
using DelimitedFiles
#===================================== Perhitungan irradiance ===============================================#
data = CSV.read("Sun_Position2016.csv", DataFrame)
irradiance = CSV.read("irradiasi_BMKG2016.csv", DataFrame)
IdrH = irradiance[:,4]
IdfH = irradiance[:,5]
Sun_Azimuth = data[:,5]
Sun_Altitude = data[:,6]
Panel_Tilt = 36
Panel_Azimuth = 90
a =sin.(deg2rad.(Sun_Altitude)) * cos(deg2rad(Panel_Tilt)) + cos.(deg2rad.(Sun_Altitude)) * sin(deg2rad(Panel_Tilt)) + cos.(deg2rad.(Panel_Azimuth .- Sun_Azimuth))
 for i in 1:length(a)
    if a[i]>1
        a[i]=1
    elseif a[i]<-1
        a[i] =-1
    end
end
α = rad2deg.(acos.(a))
IdrP = (IdrH .* cos.(deg2rad.(α))) ./ cos.(deg2rad.(90 .- Sun_Azimuth))
IdfP = IdfH .* (1+cos(deg2rad(Panel_Tilt))/2) .+ 0.3 .* (IdrH+IdfH) .* (1-cos(deg2rad(Panel_Tilt))/2)
G = IdrP
Gstc = 1000
Gaks = G/Gstc
Ct = 0.035 #°CW^(-1) m^2
T = irradiance[:,3] 
#perhitungan nilai Tmod
Tmod = T.+Ct*G
Tstc = 25.0 #derajat celcius
#perhitungan nilai Taksen
Taks = Tmod.-Tstc
#penginputan nilai k1-k6 type panel c-Si
k1 = -0.017162
k2 = -0.040289
k3 = -0.004681
k4 = 0.000148
k5 = 0.000169
k6 = 0.000005

#perhitungan nilai effesiensi
N_rel=[]
for x in 1:8784
    append!(N_rel,1 + k1*log(Gaks[x]) + k2*(log(Gaks[x]))^2 + Taks[x]*(k3+k4*log(Gaks[x])+k5*(log(Gaks[x])^2)) + k6*Taks[x]^2)
end

print(N_rel) 
Pstc = 1000
#perhitungan nilai daya 
P=[] #watt
for y in 1:8784
    append!(P,Pstc*Gaks[y]*N_rel[y]/1000)
end
writedlm("Daya_unib2016.csv",P,',')

println(maximum(Sun_Azimuth))