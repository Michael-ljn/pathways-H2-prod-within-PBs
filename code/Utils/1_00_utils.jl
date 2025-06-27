include("./general_utils/config.jl");


"""
    function to convert the interaction matrix into an amplification vector to be directly applied on a control variable vector. Dimensions are rearranged to matach that of the characterisation matrix. The biosphere integrity amplificiation coefficient is the avegrage of the 3 variables. Climate change and biochemical flows have amplification variables duplicated for consistency. 
"""
function matformat(mat)
    bi=sum(mat[:,2:4],dims=2)
    # mat=mat[:,Not(2:4)]
    mat°=zeros(10,10)
    mat°[:,1]=mat[:,1]
    # mat°[:,2]=zeros(10,1)# mat[:,1]
    mat°[:,3]=mat[:,7]
    mat°[:,4]=mat[:,9]
    mat°[:,5]=mat[:,8]
    mat°[:,6]=mat[:,6]
    mat°[:,7]=mat[:,6]
    mat°[:,8]=mat[:,10]
    mat°[:,9]=mat[:,5]
    mat°[:,10]=bi
    bi=mean(mat°[2:4,:],dims=1) # reaggregating biosphere integrity variables as in Lade et al. 2020
    mat1°=zeros(10,10)
    mat1°[1,:]=mat°[1,:]
    mat1°[2,:]=mat°[1,:]
    mat1°[3,:]=mat°[7,:]
    mat1°[4,:]=mat°[9,:]
    mat1°[5,:]=mat°[8,:]
    mat1°[6,:]=mat°[6,:]
    mat1°[7,:]=mat°[6,:]
    mat1°[8,:]=mat°[10,:]
    mat1°[9,:]=mat°[5,:]
    mat1°[10,:]=bi

    #removing effect of CO2 concentration on other boundaries since it is done by radiative forcing
    mat1°[2,2]=mat1°[1,1]
    mat1°[2,1]=0

    #Set biochemical flows with same interaction coefficients
    mat1°[6,7]=mat1°[6,6]
    mat1°[7,6]=mat1°[7,7]

    return mat1°
end

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
function remove_index(matrix, index_to_remove)
    # Check if the index is valid
    if index_to_remove < 1 || index_to_remove > size(matrix, 1)
        throw(ArgumentError("Index out of bounds"))
    end
    
    # Remove the specified row and column
    return matrix[[1:index_to_remove-1; index_to_remove+1:end], [1:index_to_remove-1; index_to_remove+1:end]]
end

### some labels
ticks= ["Climate  Change"
        "BI Land"
        "BI Freshwater"
        "BI Ocean"
        "Land System Change"
        "Biochemical Flows"
        "Ocean Acidification"
        "Freshwater Use"
        "Aerosol Loading"
        "Stratospheric Ozone Depletion"];



ticks = wrap_text.(ticks, 9)
;
catnames_=["Climate  change  Energy  imbalance"
                    "Climate  change  CO2  Concentration"
                    "Ocean  acidification"
                    "Atmospheric  aerosol  loading"
                    "Freshwater  use"
                    "Biogeochemical  flows-P"
                    "Biogeochemical  flows-N"
                    "Stratospheric  ozone  depletion"
                    "Land-system  change"
                    "Biosphere  Integrity"]

node_labels = ["Climate\nchange"
                "Ocean\nacidification"
                "Atmospheric\naerosol\nloading"
                "Freshwater\nuse"
                "Biochemical\nflows"
                "Stratospheric\nozone\ndepletion"
                "Land-system\nchange"
                "Biosphere\nIntegrity"];

catnames=wrap_text.(["Climate  change  Energy  imbalance"
                    "Climate  change  CO2  Concentration"
                    "Ocean  acidification"
                    "Atmospheric  aerosol  loading"
                    "Freshwater  use"
                    "Biogeochemical  flows-P"
                    "Biogeochemical  flows-N"
                    "Stratospheric  ozone  depletion"
                    "Land-system  change"
                    "Biosphere  Integrity"], 9);



function print_state(Δ𝐱)
    catnames_= ["Climate change Energy imbalance"
                    "Climate change CO2 Concentration"
                    "Ocean acidification"
                    "Atmospheric aerosol loading"
                    "Freshwater use"
                    "Biogeochemical flows-P"
                    "Biogeochemical flows-N"
                    "Stratospheric ozone depletion"
                    "Land-system change"
                    "Biosphere Integrity"]

    return [i=>j for (i,j) in zip(catnames_,Δ𝐱)]

end


rcParams["ytick.right"] =false
rcParams["xtick.top"] = false
rcParams["xtick.bottom"] = true
rcParams["ytick.direction"] = "out"
rcParams["ytick.minor.visible"] = false
rcParams["xtick.direction"] = "out"
rcParams["xtick.minor.visible"] = false
rcParams["figure.facecolor"] = "white"

respath=mkpath(config_respath*"/1_00_total_human_impact/")*"/";