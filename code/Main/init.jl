
include("./config.jl")
include("./namings.jl")
include("./main_utils.jl")
include("./inventories.jl")



using .LCAModule
using Statistics
using CSV
using DataFrames
using XLSX
using LinearAlgebra,SparseArrays,Symbolics
using JuMP, CPLEX
using JLD2
using PyCall
using PyPlot
import Seaborn


### constants
ssp=1
rcp=1
year=1;
wrapped_names = wrap_text.(catnames, 9)