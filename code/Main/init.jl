using Revise
using lce
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

include("./config.jl")
include("./data/namings.jl")
include("./utils/main_utils.jl")
include("./data/inventories.jl")
include("./utils/ssp_utils.jl")
# include("./constraints.jl") # no need to include this one as we have already computed files. 


# some useful math operator to match that of the paper. 
⊙ = .*  # Define ⊙ as an alias for element-wise multiplication - Hadamard product
⊘ = ./  # Define ⊘ as an alias for element-wise division - Hadamard division
# ∑(a) = sum(a) # written `\sum` # Define ∑ as an alias for the sum function
# ∏(a) = prod(a) # written `\prod` # Define ∏ as an alias for the product function


## quick utility function

    Saving(p)=saveProject(p)
    clear(p)=clearTcm!(project=p)

    𝐋(a,p)=lca(a(p),project=p)[end,2]
    𝐋i(a,p)=Array(lca(a(p),project=p)[end,2:end])
    𝐋x(a,m,p)=Array(lca(a(p,m),project=p)[end,2:end]);

    TCM(p) = Tcm!(p)
    A(p) =   Tcm!(p)[:technosphere]
    B(p) =   Tcm!(p)[:biosphere]
    f(p) =   spzeros(A(p).m)
    𝚲b(p)=   Characterisation!(p).Matrix*B(p); 
## end


# wrapped_names = wrap_text.(catnames, 9)