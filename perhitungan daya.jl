using CSV
using DataFrames
using Plots
using DelimitedFiles
################################ pemanggilan data irradiasi ######################################
data= CSV.read("irradiasi_unib2019.csv", DataFrame)
G = data[:,4]
Gstc = 1000.0 #W/m^2

#perhitungan nilai gaksen
Gaks = G/Gstc
Ct = 0.035 #°CW^(-1) m^2
T = data[:,3] 

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
for x in 1:8753
    append!(N_rel,1 + k1*log(Gaks[x]) + k2*(log(Gaks[x]))^2 + Taks[x]*(k3+k4*log(Gaks[x])+k5*(log(Gaks[x])^2)) + k6*Taks[x]^2)
end
#print(N_rel) 

Pstc = 919.024
#perhitungan nilai daya 
P=[] #watt
for y in 1:8753
    append!(P,Pstc*Gaks[y]*N_rel[y]/1000)
end
writedlm("Daya_FTunib2019.csv",P,',')

#perhitungan energi
#Delta_t = 1 #1jam
#E = P*Delta_t
#print(E)