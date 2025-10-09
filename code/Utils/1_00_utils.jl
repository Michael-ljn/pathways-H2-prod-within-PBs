include("./general_utils/config.jl");
include("./matrices/lade2020.jl");

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
                            rotation_angle=0, 
                            scale_edge=15,
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
    pos = nx.spring_layout(G, seed=seed, weight="weight") 


    if rotation_angle != 0
        angle_rad = deg2rad(rotation_angle)
        rotation_matrix = [cos(angle_rad) -sin(angle_rad); sin(angle_rad) cos(angle_rad)]
        for (key, value) in pos
            pos[key] = rotation_matrix * value
        end
    end

    fontproperties=font_prop

    plt.figure(figsize=figsize)
    nx.draw_networkx_nodes(G, pos, node_size=node_size, node_color="white", edgecolors="black") #node_color='#c2b280',
    nx.draw_networkx_labels(G, pos, labels=nx.get_node_attributes(G, "label"), font_size=5, font_color="black")
    edges = G.edges(data=true)
    edge_colors = [ adjacency_matrix[u, v] < 0 ? "#2CAFFF" : "#EF3B2C" for (u, v, d) in edges ]
    edge_widths = [d["weight"] * scale_edge for (u, v, d) in edges]

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
    end
end
function force_interactions(adjacency_matrix;node_size=1500, 
                            figsize=(9, 9), 
                            seed=11,
                            arrowsize=18,
                            min_source_margin=10,
                            min_target_margin=25,
                            aspect="auto",
                            adjustable="box",
                            savepath=respath*"SI_Fig5_force_interactions",
                            disp=true,
                            dpi=800,
                            invertxaxis=false,
                            invertyaxis=false,
                            rotation_angle=0, 
                            scale_edge=15,
                            labels=catlabels_lade_ticks[bꜝ],max_scale=0.04 )

    node_labels=labels
    # node_labels[2]= "Biosphere\n Integrity"
    
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
    pos = nx.spring_layout(G, seed=seed, weight="weight") 


    if rotation_angle != 0
        angle_rad = deg2rad(rotation_angle)
        rotation_matrix = [cos(angle_rad) -sin(angle_rad); sin(angle_rad) cos(angle_rad)]
        for (key, value) in pos
            pos[key] = rotation_matrix * value
        end
    end

    fontproperties=font_prop

    plt.figure(figsize=figsize)
    nx.draw_networkx_nodes(G, pos, node_size=node_size, node_color="white", edgecolors="black") #node_color='#c2b280',
    nx.draw_networkx_labels(G, pos, labels=nx.get_node_attributes(G, "label"), font_size=5, font_color="black")
    edges = G.edges(data=true)
    edge_colors = [adjacency_matrix[u, v] < 0 ? "dodgerblue"  : "red" for (u, v, d) ∈ edges]# "#2CAFFF", #EF3B2C
    weights = [abs(adjacency_matrix[u, v]) for (u, v, d) in edges]
    
    min_weight, max_weight = minimum(weights), maximum(weights)#*1.2,*max_scale 
    
    edge_widths = [(abs(adjacency_matrix[u, v])*max_scale- min_weight) / (max_weight - min_weight+0.003)+ 1 * scale_edge for (u, v, d) ∈ edges]
    # edge_widths = [d["weight"] * scale_edge for (u, v, d) in edges]

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
    plt.savefig(savepath*".svg",bbox_inches="tight",transparent=true)
    # plt.savefig(savepath*".png",dpi=dpi,bbox_inches="tight",transparent=true)
    if disp
        display(plt.gcf())
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

function bi_aggregation(mat)
    𝖘ᵇⁱ = [2,3,4]
    𝐁°=zeros(10,10)
    sum_row=mean(mat[𝖘ᵇⁱ,:],dims=1)
    mean_col=sum(mat[:,𝖘ᵇⁱ],dims=2)
    𝖘ꜝᵇⁱ=setdiff(1:1:10, 𝖘ᵇⁱ)
    𝐁°[𝖘ꜝᵇⁱ,𝖘ꜝᵇⁱ]=mat[𝖘ꜝᵇⁱ,𝖘ꜝᵇⁱ]
    𝐁°[2,:]=sum_row
    𝐁°[:,2]=mean_col
    𝐁°=𝐁°[Not([3,4]),Not([3,4])]; # we drop the unnecessary colums.
    return 𝐁°
end


"""
#   Matrix formatting function 
## Description   
> function to convert the interaction matrix into an amplification vector to be directly applied on a control variable vector. Dimensions are rearranged to matach that of the characterisation matrix. The biosphere integrity amplificiation coefficient is the avegrage of the 3 variables. Climate change and biochemical flows have amplification variables duplicated for consistency. 

> takes a matrix ``A`` to compute ``A^°`` a an updated matrix.

## Methods available
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





