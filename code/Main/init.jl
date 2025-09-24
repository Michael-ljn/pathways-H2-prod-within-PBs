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
include("../Utils/general_utils/ssp_utils.jl")
include("./modules/optimisation.jl")
include("./utils/PBplot.jl")

using .optimisation, lce, .TcmUtils
import Statistics:quantile
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
    # A(p) =   Tcm!(p)[:technosphere]
    # B(p) =   Tcm!(p)[:biosphere]
    # f(p) =   spzeros(A(p).m)
    # 𝚲b(p)=   Characterisation!(p).Matrix*B(p); 
## end

## pyplot options
cmap = plt.get_cmap("tab20c_r")
colors = [cmap(i) for i in 0:19]
cmap = plt.get_cmap("tab20b_r")
colors2 = [cmap(i) for i in 0:19]
mpl_colors = pyimport("matplotlib.colors")
SymLogNorm = mpl_colors.SymLogNorm

## some operators to match the math of the paper
⊘ = ./ # elementwise division - Hadamard division `\oslash`
⊙ = .* # elementwise multiplication - Hadamard product  `\odot`
⊕ = .+ # elementwise addition - Hadamard sum `\oplus``
⊖ = .- # elementwise subtraction - Hadamard difference `\ominus`
∑ = sum # summation operator
Π = prod # product operator


## Importing the IPCC data and hydrogen production.
    # @load "../Source data/02_results/2_02_allocated_space/ensemble.jld";
    @load "../Source data/02_results/main/Fig2/ensemble.jld";
    years=2025:5:2050
    ## future hydrogen demand
    EJ_to_kwh=1/3.6e-12
    LHVH2=33.33 # kWh/kgH2
    EJH2_to_kgH2=1*EJ_to_kwh/LHVH2
    ṁᵏᵍ=38*EJH2_to_kgH2 # mass H2
    ṁᴹᵗ=ṁᵏᵍ.*1e-9 # convert to Mt
    ṁᴳᵗ=ṁᴹᵗ.*1e-3

    SEʰ²=getVals("Secondary Energy|Hydrogen",years=years,df=df_h2)
    ṁᵏᵍ=SEʰ²⊙ EJH2_to_kgH2 # mass H2 using the LHV of hydrogen (33.33 kWh/kg)
    ṁᴹᵗ=ṁᵏᵍ⊙ 1e-9 # convert to Mt
    ṁᴳᵗ=ṁᴹᵗ⊙ 1e-3;

    ṁᴹᵗq50=median(ṁᴹᵗ,dims=1)
    ṁᵏᵍq50=median(ṁᵏᵍ,dims=1)
## end 

"""
    create a new set from tcm activity keys.
    """
    function newSet(vec::Vector{Symbol})
        𝖘=[v.second for v in getTcmKey(vec,𝐏)]
        return 𝖘
    end
    function newSet(vec::Vector{Symbol})
        𝖘=[v.second for v in getTcmKey(vec,𝐏)]
        return 𝖘
    end

𝖘ᵈᵃᶜ=newSet([:DAC_heatpump,:DAC_steam])
𝖘ᶠᵒˢˢⁱˡ= newSet([:SMR,:hydrogen_pyrolysis,:hydrogen_coal]) #grey
fossil_names= ["SMR","pyrolysis","coal"]
𝖘ᶠᵒˢˢⁱˡ⁻ᶜᶜˢ= newSet([:hydrogen_SMRccs,:hydrogen_coalccs])
fossil_ccs_names= ["SMR+CCS","coal+CCS"]
𝖘ᵇᶦᵒ = newSet([:hydrogen_bSMR,:hydrogen_BioG,:hydrogen_BioCccs,:hydrogen_bSMRccs])
bio_names= ["bSMR","BioG","BioGccs","bSMR+CCS"]
𝖘ᵉˡᵉᶜᵗʳᵒˡʸˢⁱˢ = newSet([:hydrogen_PEM,:hydrogen_AE,:hydrogen_SOEC_steam,:hydrogen_SOEC_elec])
electrolysis_names= ["PEM","AE","SOECsteam","SOECelectricity"]

"""
    utility function to wrap text, use a double space to separate words
"""
function wrap_text(str, width=9)
    words = split(str)
    lines = String[]
    current_line = ""
    for word in words
        if length(current_line) + length(word) > width
            push!(lines, strip(current_line))
            current_line = word
        else
            current_line = current_line * " " * word
        end
    end
    push!(lines, strip(current_line))
    result = join(lines, "\n")
    return replace(result, r"^\n+" => "")  # Remove leading newlines
end

catnames=[ # labels to match the dimensions of AESA categories.
            "Climate  change  Energy  imbalance"
            "Climate  change  CO2  Concentration"
            "Ocean  acidification"
            "Atmospheric  aerosol  loading"
            "Freshwater  use"
            "Biogeochemical  flows-P"
            "Biogeochemical  flows-N"
            "Stratospheric  ozone  depletion"
            "Land-system  change"
            "Biosphere  Integrity"]

catnames_ticks=wrap_text.(catnames, 9);#as ticks for figures.