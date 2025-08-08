using Revise
include("./init.jl")
include("./constraints.jl")
### Known issues   
    ## FIXME: before running the code below, somehow initial background activities have to be initialised. Likely because NewAct!() excludes lci creation which should be done by NewAct() only. 
## End

## Project initialisation
    years=2025:5:2050;

    scenarios=["REMIND-SSP1-Pkbudg500",
                "REMIND-SSP2-Pkbudg500",
                "REMIND-SSP5-Pkbudg500",
                "IMAGE-SSP2-1.9",
                "TIAM-UCL-SSP2-1.9"
                ]

    ini_scenario=["REMIND"=>1
                "REMIND"=>2
                "REMIND"=>5
                # "IMAGE"=>2 #FIXEME: this model has a dimension issue
                # "TIAM-UCL"=>2 #FIXEME: this model has a dimension issue but it is not an important model for the analysis.
                ]
    ## Here we initialise the project. The dimensions are scenarios × years -> 5×6=30
    𝐏=[initProject("natcom",model=x.first,RCP=1.9,SSP=x.second,year=y) for x ∈ ini_scenario, y ∈ years]
## end

𝐏°=𝐏

#Run any background activity to initialise the matrix LU factorisation, part of the stuff to fix. 
    liquid_storage_tank_14447.(𝐏)
# end


clear.(𝐏°)
DAC.(𝐏°)
model.(𝐏°)
cm=ChoiceModel.(𝐏°)

Tcm!(𝐏°[2,2])[:technosphere]
Tcm!(𝐏°[1,2])[:choice_map]
Tcm!(𝐏°[2,2])[:map]
Tcm!(𝐏°[2,2])[:exchanges]

A°=cm[3,5][2]
A°.n-A°.m



length(𝖘ᵗ)
𝐜ᵗ=ones(A°.n,6)

𝐜ᵗ[𝖘ᵗ,:]





saveProject.(𝐏°)


## Step 1: Get the constraints for each of the variables involved. Use the IEA set. make a rangge of uncertainty.

    #𝐬[tech]=𝐜[tech]



filter(x -> x[1] in [7911,6935], Tcm!(𝐏°[2,2])[:exchanges])



𝔰 = getTcmChoices(𝐏°[2,2],all_keys=true)
length(𝔰)

𝖘ᵗ=Tcm!(𝐏°[1,2])[:choice_map][:hydrogen]
act_to_tcm=[x.second.key =>x.first for x ∈ pairs(filter(j -> j[1] in 𝖘ᵗ, Tcm!(𝐏°[2,2])[:map]))]





processs=("electricity production, oil","RoW")
aa=getTcmChoices(:hydrogen,𝐏°[2,2])

bb=[(x.act,x.loc) for x ∈ getTcmAct(aa,𝐏°[2,2])]




getTcmKey(processs,𝐏°[2,2])
getTcmKey([6935,1283],𝐏°[2,2])
getTcmAct(7,𝐏°[2,2])
getTcmChoices(𝐏°[2,2],all_keys=true)
