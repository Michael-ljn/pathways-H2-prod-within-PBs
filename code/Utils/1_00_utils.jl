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
                            invertyaxis=false)
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