using SparseArrays
using JLD2
@load "../Source data/02_results/1_00_total_human_impact/data_interaction_matrices.jld2" 𝚪ᵦ 𝚪ₕ catnames_ticks

refrence_flows=[
    "Processed rice (in Mt)"
    "Unprocessed rice (in Mt)"
    "Thermal energy (in TWh)"
    "Rice husk at factory (in Mt)"
    "Rice husk at farm (in Mt)"
    "Natural gas (in TWh)"
    "Wood pellets (in Mt)"
    "Electricity (in TWh)"
    "Transportation (in Gt*km)"
    ]

processes=[
    "Rice factory"
    "Rice farming"	
    "Low-nitrogen" 
    "Rice husk boiler"	
    "Natural gas boiler"	
    "Wood pellet boiler"	
    "Rice husk collection 1"	
    "Rice husk collection 2"	
    "Rice husk collection 3"	
    "Rice husk collection 4"	
    "Rice husk collection 5"	
    "natural gas supply"	
    "Wood pellet supply"	
    "Burning of rice husk"	
    "Power plant"	
    "Transportation by truck"
    ]

boundaries=[
    "Climate change - energy imbalance in W/m2"
    "Ocean acidification in Ωarag"
    "Change in biosphere integrity in %"
    "Nitrogen cycle in Tg"
    "Phosphorus cycle in Tg"
    "Atmospheric aerosol loading in Aerosol optical depth"
    "Freshwater use in km3"
    "Stratospheric ozone depletion in Dobson units"
    "Land-system change in %"
    ]

requirements=[
        "Operation of rice factory (in Mt)"
        "Cultication of land (in Gha*a)"
        "Zone 1 - purchase of rice husk at farm (in Mt)"
        "Zone 2 - purchase of rice husk at farm (in Mt)"
        "Zone 3 - purchase of rice husk at farm (in Mt)"
        "Zone 4 - purchase of rice husk at farm (in Mt)"
        "Zone 5 - purchase of rice husk at farm (in Mt)"
        "Extraction of natural gas (in TWh)"
        "Operation of power plant (in TWh)"
        "Extraction of coal (in Mt)"
        "Operation of truck (in Gt*km)"
        ]

elementary_flows=["CO2 (in Mt)"
                "CH4 (in Mt)"
                "N2O (in Mt)"
                "Phosphate (in Mt)"
                "Particulates, < 2.5 um (in Mt)"
                "Water, river (in km3)"
                "Transformation, from forest, intensive (in km2)"
                "Occupation, annual crop, irrigated in km2*year"
                "N-fertilizer use (in Mt)"]

Δxᵖᵇ=[  1 # Climate change - energy imbalance in W/m2
        0.688 # ocean acidification in Ωarag
        10 # change in biosphere integrity in %
        39.7 # nitrogen cycle in Tg
        10 # phosphorus cycle in Tg
        0.11 # atmospheric aerosol loading in Aerosol optical depth
        4000 # freshwater use in km3
        14.5 # stratospheric ozone depletion in Dobson units
        25 # land-system change in %
        ];

A=[     1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
        -1.15	1	1	0	0	0	0	0	0	0	0	0	0	0	0	0
        -2.2	0	0	1	1	1	0	0	0	0	0	0	0	0	0	0
        0	0	0	-0.23	0	0	1	1	1	1	1	0	0	0	0	0
        0	0.6	0.6	0	0	0	-1	-1	-1	-1	-1	0	0	-1	0	0
        0	0	0	0	-1.11	0	0	0	0	0	0	1	0	0	0	0
        0	0	0	0	0	-0.25	0	0	0	0	0	0	1	0	0	0
        -0.077	0	0	0	0	0	0	0	0	0	0	0	-0.02	0	1	0
        -0.345	0	0	0	0	0	-0.12	-0.24	-0.36	-0.48	-0.6	0	-0.1	0	0	1]


B=[ 0	0.061426004	0.121426004	0	0.22664517	0	0	0	0	0	0	0.032078656	0.150472663	0	1.095184111	0.057554402
    0	0.000132928	0.000132928	0	0.000146545	0	0	0	0	0	0	0.001495279	0.00025586	0	0.000915211	6.96793E-05
    0	0.000122852	0.000122852	0	5.66613E-05	0	0	0	0	0	0	1.60393E-05	7.52363E-05	0	0.000547592	2.87772E-05
    0	0.0002	0.0008	0	0	0	0	0	0	0	0	0	0	0	0.0002	0
    0	0	0	0.00004	0.0000015	0.00004	0	0	0	0	0	0	0	0.0001	0.0003	0.00005
    0	0.4	0.4	0	0	0	0	0	0	0	0	0	0	0	0.002	0
    0	0.3	0.3	0	0	0	0	0	0	0	0	0	0	0	0	0
    0	1000	1000	0	0	0	0	0	0	0	0	0	0	0	0	0
    0	0.006	0.001	0	0	0	0	0	0	0	0	0	0	0	0	0 ]

Q=[ 0.000235	0.00159	0.0464	0	0	0	0	0	0
    5.46982E-05	0.000150079	0	0	0	0	0	0	0
    0.000203008	0.006902256	0.060496241	0	0	0	0	0.0000007	0
    0	0	0	0	0	0	0	0	1
    0	0	0	0.280666539	0	0	0	0	0
    0	0	0	0	0.0108	0	0	0	0
    0	0	0	0	0	1	0	0	0
    0	0	0.141	0	0	0	0	0	0
    0	0	0	0	0	0	1.5625E-06	0	0]

f=[ 1
    0
    0
    0
    0
    0
    0
    0
    0];


c= [10
    10
    0.1
    0.1
    0.1
    0.1
    0.1
    10
    10
    10
    10];

F=[ 1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
    0	0.0004	0.0004	0	0	0	0	0	0	0	0	0	0.00008	0	0	0
    0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0
    0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0
    0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0
    0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0
    0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0
    0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0
    0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0
    0	0	0	0	0	0	0	0	0	0	0	0	0	0	0.9504	0
    0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1];
    ;



    ## Process intensity matrix
b=[2] # CO2 concentration
bꜝ= setdiff(1:10, b); #removed from the set

Λ = (Q*B)
# reordering the arrays
Λ° = zeros(10,length(processes))
Λ°[1,:] = Λ[1,:] # "Climate change - energy imbalance in W/m2"
Λ°[3,:] = Λ[2,:] # "Ocean acidification in Ωarag"
Λ°[10,:] = Λ[3,:] # "Change in biosphere integrity in %"
Λ°[7,:] = Λ[4,:] # "Nitrogen cycle in Tg"
Λ°[6,:] = Λ[5,:] # "Phosphorus cycle in Tg"
Λ°[4,:] = Λ[6,:] # "Atmospheric aerosol loading in Aerosol optical depth"
Λ°[5,:] = Λ[7,:] # "Freshwater use in km3"
Λ°[8,:] = Λ[8,:] # "Stratospheric ozone depletion in Dobson units"
Λ°[9,:] = Λ[9,:] # "Land-system change in %"
Λ=Λ°[bꜝ,:]


Q° = zeros(10,sparse(B).m)
Q°[1,:] = Q[1,:] # "Climate change - energy imbalance in W/m2"
Q°[3,:] = Q[2,:] # "Ocean acidification in Ωarag"
Q°[10,:] = Q[3,:] # "Change in biosphere integrity in %"
Q°[7,:] = Q[4,:] # "Nitrogen cycle in Tg"
Q°[6,:] = Q[5,:] # "Phosphorus cycle in Tg"
Q°[4,:] = Q[6,:] # "Atmospheric aerosol loading in Aerosol optical depth"
Q°[5,:] = Q[7,:] # "Freshwater use in km3"
Q°[8,:] = Q[8,:] # "Stratospheric ozone depletion in Dobson units"
Q°[9,:] = Q[9,:] # "Land-system change in % %"
Q=Q°[bꜝ,:]


Δxᵖᵇ° = zeros(10)
Δxᵖᵇ°[1] = Δxᵖᵇ[1] # "Climate change - energy imbalance in W/m2"
Δxᵖᵇ°[3] = Δxᵖᵇ[2] # "Ocean acidification in Ωarag"
Δxᵖᵇ°[10] = Δxᵖᵇ[3] # "Change in biosphere integrity in %"
Δxᵖᵇ°[7] = Δxᵖᵇ[4] # "Nitrogen cycle in Tg"
Δxᵖᵇ°[6] = Δxᵖᵇ[5] # "Phosphorus cycle in Tg"
Δxᵖᵇ°[4] = Δxᵖᵇ[6] # "Atmospheric aerosol loading in Aerosol optical depth"
Δxᵖᵇ°[5] = Δxᵖᵇ[7] # "Freshwater use in km3"
Δxᵖᵇ°[8] = Δxᵖᵇ[8] # "Stratospheric ozone depletion in Dobson units"
Δxᵖᵇ°[9] = Δxᵖᵇ[9] # "Land-system change in
Δxᵖᵇ = Δxᵖᵇ°[bꜝ]

# boundaries = boundaries[bꜝ]
catnames_ticks = catnames_ticks[bꜝ]
catnames_ticks = replace.(catnames_ticks, r"\n" => " ")
𝚪ᵦ=𝚪ᵦ[bꜝ,bꜝ]
𝚪ₕ=𝚪ₕ[bꜝ,bꜝ]