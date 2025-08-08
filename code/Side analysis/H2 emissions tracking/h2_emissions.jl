include("../lca/src/lca.jl")
include("../Utils/3_00_utils.jl")
using .LCAModule
using PyPlot
using DimensionalData
using Statistics
using Distributions
using XLSX

initProject("natcom_validation",model="REMIND",RCP=1.9,SSP=1,year=2025,method="IPCC2021")

h2_bio=getBio("Hydrogen","air, unspecified");

h2_emi=[hcat(getAct(i).ref,getAct(i).act,getAct(i).loc,h2_bio.downstream[i],h2_bio.unit) for i ∈ sparse(h2_bio.downstream).nzind]

vcat(h2_emi...)


dfa=DataFrame(vcat(h2_emi...),["reference flow","activity","location","hydrogen emissions","unit"])

XLSX.writetable(datapath*"h2_emi.xlsx", Tables.columntable(dfa), sheetname="Sheet1", overwrite=true)