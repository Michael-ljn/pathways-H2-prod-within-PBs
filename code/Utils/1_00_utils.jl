include("./general_utils/config.jl");
respath=mkpath(config_respath*"/1_00_total_human_impact/")*"/";
using InvertedIndices
using SparseArrays, LinearAlgebra, Statistics


# Set up matplotlib parameters
rcParams["ytick.right"] =false
rcParams["xtick.top"] = false
rcParams["xtick.bottom"] = true
rcParams["ytick.direction"] = "out"
rcParams["ytick.minor.visible"] = false
rcParams["xtick.direction"] = "out"
rcParams["xtick.minor.visible"] = false
rcParams["figure.facecolor"] = "white"

"""
    function to print the state of the control variables in a readable format
"""
function print_state(Δ𝐱;catnames=catnames)
    return [i=>j for (i,j) in zip(catnames,Δ𝐱)]
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


## indexes of the variables in the interaction matrix from Lade et al. 2020
catlabels_lade= [ # Labels order from Lade et al. 2020
                "Climate Change"
                "BI Land"
                "BI Freshwater"
                "BI Ocean"
                "Land System Change"
                "Biogeochemical Flows"
                "Ocean Acidification"
                "Freshwater Use"
                "Aerosol Loading"
                "Strat. Ozone Depletion"]

ᶜᶜ = 1 # Climate Change
ᴮᴵˡ = 2 # BI Land
ᴮᴵᶠ = 3 # BI Freshwater
ᴮᴵᴼ = 4  # BI Ocean
ˡˢᶜ = 5 # Land System Change
ᴮᶜᶠ = 6 # Biogeochemical Flows
ᴼᵃ = 7 # Ocean Acidification
ᶠʷᵘ = 8 # Freshwater Use
ᵃᵃˡ = 9 # Aerosol Loading
ˢᵒᵈ = 10 # Strat. Ozone Depletion

catlabels_lade_ticks = wrap_text.(catlabels_lade, 9) # as ticks for figures.

s= 1:1:10 # This represent the set of all planetary boundaries
bⁿ=[3,4] # Removing unnecessary node labels for the force interaction figure.
bꜝ = setdiff(s, bⁿ) # Creation of a a complementary set without the set bⁿ

"""
    Function to plot a graph of interactions
"""
function force_interactions(adjacency_matrix;node_size=1500, 
                            figsize=(9, 9), 
                            seed=11,
                            arrowsize=18,
                            min_source_margin=10,
                            min_target_margin=25,
                            aspect="auto",
                            adjustable="box",
                            savepath=respath*"SI_Fig5_force_interactions.svg",
                            disp=true,
                            dpi=800,
                            invertxaxis=false,
                            invertyaxis=false,
                            labels=catlabels_lade_ticks[bꜝ])

    node_labels=labels
    node_labels[2]= "Biosphere\n Integrity"
    
    G = nx.DiGraph()
    for (i, label) in enumerate(node_labels)
        G.add_node(i, label=label)
    end
    for i in range(1,size(adjacency_matrix)[1],step=1)
        for j in range(1,size(adjacency_matrix)[1],step=1)
            if adjacency_matrix[i, j] != 0
                G.add_edge(i, j, weight=adjacency_matrix[i, j])
            end
        end
    end
    pos = nx.spring_layout(G, seed=seed, weight="weight")#45,25,22,21,2,3
    fontproperties=font_prop

    plt.figure(figsize=figsize)
    nx.draw_networkx_nodes(G, pos, node_size=node_size, node_color="white", edgecolors="black") #node_color='#c2b280',
    nx.draw_networkx_labels(G, pos, labels=nx.get_node_attributes(G, "label"), font_size=5, font_color="black")
    edges = G.edges(data=true)
    edge_colors = [ adjacency_matrix[u, v] < 0 ? "#2CAFFF" : "#EF3B2C" for (u, v, d) in edges ]
    edge_widths = [d["weight"] * 10 for (u, v, d) in edges]  # Scale edge width for visibility

    nx.draw_networkx_edges(G, pos, edgelist=edges, edge_color=edge_colors, width=edge_widths,
                        arrows=true, arrowstyle="->", arrowsize=arrowsize, connectionstyle="arc3,rad=0.2",
                        min_source_margin=min_source_margin,min_target_margin=min_target_margin)

    plt.gca().set_aspect(aspect,adjustable=adjustable)

    if invertxaxis
        plt.gca().invert_xaxis()
    end
    if invertyaxis
        plt.gca().invert_yaxis()
    end

    plt.axis("off")
    plt.tight_layout()
    plt.savefig(savepath,bbox_inches="tight",transparent=true)
    plt.savefig(savepath,dpi=dpi,bbox_inches="tight",transparent=true)
    if disp
        display(plt.gcf())
        plt.close("all")
    else
        plt.close("all")
    end
end


S =[ᶜᶜ ᴮᴵˡ ᴮᴵᶠ ᴮᴵᴼ ˡˢᶜ ᴮᶜᶠ ᴼᵃ ᶠʷᵘ ᵃᵃˡ ˢᵒᵈ]

#### indexes of control variables from AESA

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


catnames_ticks=wrap_text.(catnames, 9); #as ticks for figures.

ᶜᶜ¹° = 1 # Climate Change RF
ᶜᶜ²° = 2 # Climate Change CO2 Concentration
ᴼᵃ° = 3 # Ocean Acidification
ᵃᵃˡ° = 4 # At. Aerosol Loading
ᶠʷᵘ° = 5 # Freshwater Use
ᴮᶜᶠᵖ° = 6 # Biogeochemical Flows - Phosphorus
ᴮᶜᶠⁿ° = 7 # Biogeochemical Flows - Nitrogen
ˢᵒᵈ° = 8 # Stratospheric Ozone Depletion
ˡˢᶜ° = 9 # Land System Change   
ᴮᴵ° = 10 # Biosphere Integrity


"""
function to convert the interaction matrix into an amplification vector to be directly applied on a control variable vector. Dimensions are rearranged to matach that of the characterisation matrix. The biosphere integrity amplificiation coefficient is the avegrage of the 3 variables. Climate change and biochemical flows have amplification variables duplicated for consistency. 
"""
function matformat(mat)
    b = [ᴮᴵˡ, ᴮᴵᶠ, ᴮᴵᴼ] # indexes of biosphere integrity variables
    PBs= 10
    # reordering columns to match the order of the categories in AESA
    bi=sum(mat[:,b],dims=2)
    mat°=zeros(PBs,PBs)
    mat°[:,ᶜᶜ¹°]=mat[:,ᶜᶜ] 
    mat°[:,ᶜᶜ²°]=mat[:,ᶜᶜ]
    mat°[:,ᴼᵃ°]=mat[:,ᴼᵃ]
    mat°[:,ᵃᵃˡ°]=mat[:,ᵃᵃˡ]
    mat°[:,ᶠʷᵘ°]=mat[:,ᶠʷᵘ]
    mat°[:,ᴮᶜᶠᵖ°]=mat[:,ᴮᶜᶠ]
    mat°[:,ᴮᶜᶠⁿ°]=mat[:,ᴮᶜᶠ]
    mat°[:,ˢᵒᵈ°]=mat[:,ˢᵒᵈ]
    mat°[:,ˡˢᶜ°]=mat[:,ˡˢᶜ]
    mat°[:,ᴮᴵ°]=bi

    # reordering rows to match the order of the categories in AESA
    bi=mean(mat°[b,:],dims=1) # reaggregating biosphere integrity variables as in Lade et al. 2020
    mat1°=zeros(PBs,PBs)
    mat1°[ᶜᶜ¹°,:] = mat°[ᶜᶜ,:]
    #mat1°[ᶜᶜ²°,:] = mat°[ᶜᶜ,:] # is nullyfied so no effect from CO2 emissions to other bondaries is accounted.
    mat1°[ᴼᵃ°,:] = mat°[ᴼᵃ,:]
    mat1°[ᵃᵃˡ°,:] = mat°[ᵃᵃˡ,:]
    mat1°[ᶠʷᵘ°,:] = mat°[ᶠʷᵘ,:]
    mat1°[ᴮᶜᶠᵖ°,:] = mat°[ᴮᶜᶠ,:]
    mat1°[ᴮᶜᶠⁿ°,:] = mat°[ᴮᶜᶠ,:]
    mat1°[ˢᵒᵈ°,:] = mat°[ˢᵒᵈ,:]
    mat1°[ˡˢᶜ°,:] = mat°[ˡˢᶜ,:]
    mat1°[ᴮᴵ°,:] = bi

    # Removing effect of CO2 concentration on other boundaries since it is done by radiative forcing
    mat1°[ᶜᶜ²°,ᶜᶜ²°] = mat1°[ᶜᶜ¹°,ᶜᶜ¹°] # same interaction coefficient for CO2 concentration and radiative forcing
    mat1°[ᶜᶜ¹°,ᶜᶜ²°] = 0 #nullifying the effect of CO2 concentration on radiative forcing

    #Set biochemical flows with same interaction coefficients as they share the common agriculture driver. 
    mat1°[ᴮᶜᶠᵖ°,ᴮᶜᶠⁿ°]=mat1°[ᴮᶜᶠᵖ°,ᴮᶜᶠᵖ°]
    mat1°[ᴮᶜᶠⁿ°,ᴮᶜᶠᵖ°]=mat1°[ᴮᶜᶠⁿ°,ᴮᶜᶠⁿ°]

    return mat1°
end

#### matrices


𝐈=I(10) # Identity matrix

# 𝐁 matrix for Biophysical interactions, # NOTE: Matrix arranged as 𝐁z⁺z, effect of columns on rows
𝐁 = [
    1.0     0.15    0.38    0.22    0.10    0.19    -0.07   -0.08   0       -0.06   # Climate Change
    0.22    1       0       0       0       0       0.08    0       0       0       # BI Land
    0.17    0       1       0       0       0       0.04    0       0       0       # BI Freshwater
    0.15    0       0       1       0       0       0.06    0       0       0       # BI Ocean
    0.12    0.8     0.08    0       1       0       0.16    -0.11   0       0       # Land System Change
    0.04    0.02    1       0.05    0       1       -0.03   0       0.10    0.01    # Biogeochemical Flows
    0.10    0       0       1       0       0       1       0       0       0       # Ocean Acidification
    0       0       1       0       0       0       0       1       0       0       # Freshwater Use
    -0.56   0       0       0       0       0       0       0       1       0       # Aerosol Loading
    -0.11   0       0       0       0       0       0       0       0       1       # Strat. Ozone Deplet.
    ]'-𝐈 |>sparse

# NOTE: Matrix arranged as 𝐁z⁺z, effect of columns on rows
# 𝐁 = matformat(𝐁)'|>sparse # NOTE: Matrix arranged as 𝐁zz⁺, effect of rows on columns
    

# 𝐑 matrix for Reactive human-mediated interactions # NOTE: Matrix arranged as 𝐑z⁺z, effect of columns on rows
𝐑 = [
    1       0       0       0       0.05        0       0       0       0       0       # Climate Change
    0       1       0       0       0           0       0       0       0       0       # BI Land
    0.002   0       1       0       0.003       0       0       0       0       0       # BI Freshwater
    0       0       0       1       0.02        0       0       0       0       0       # BI Ocean
    0       0       0       0       1           0       0       0       0       0       # Land System Change
    0       0       0       0       0           1       0       0       0       0       # Biogeochemical Flows
    0       0       0       0       0           0       1       0       0       0       # Ocean Acidification
    0       0       0       0       0           0       0       1       0       0       # Freshwater Use
    0       0       0       0       0           0       0       0       1       0       # Aerosol Loading
    0       0       0       0       0           0       0       0       0       1       # Strat. Ozone Deplet.
    ]'-𝐈 |>sparse

# NOTE: Matrix arranged as 𝐑z⁺z, effect of columns on rows
# 𝐑 = matformat(𝐑)'|>sparse # NOTE: Matrix arranged as 𝐑zz⁺, effect of rows on columns

# Define 𝐏 matrix for Parallel human drivers, # NOTE: Matrix arranged as 𝐏z⁺z, effect of columns on rows
𝐏 = [
    1       0       0       0       0       0       0.40        0.065       0       0       # Climate Change
    0       1       0       0       0       0       0           0           0       0       # BI Land
    0       0       1       0       0       0       0           0           0       0       # BI Freshwater
    0       0       0       1       0       0       0           0           0       0       # BI Ocean
    0.33    0       0       0       1       1.3     0           0.36        0       0       # Land System Change
    0.005   0       0       0       0       1       0           0           0       0       # Biogeochemical Flows
    0       0       0       0       0       0       1           0           0       0       # Ocean Acidification
    0.018   0       0       0       0       0       0           1           0       0       # Freshwater Use
    0       0       0       0       0       0       0           0           1       0       # Aerosol Loading
    0.52    0       0       0       0       0       0           0           0       1       # Strat. Ozone Deplet.
    ]'-𝐈 |>sparse # NOTE: Matrix arranged as 𝐏z⁺z, effect of columns on rows


# NOTE: Matrix arranged as 𝐏z⁺z, effect of columns on rows

# 𝐏 = matformat(𝐏)'|>sparse # NOTE: Matrix arranged as 𝐏zz⁺, effect of rows on columns
;





