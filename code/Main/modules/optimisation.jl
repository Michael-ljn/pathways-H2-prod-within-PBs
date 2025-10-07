# Main script for the publication "Pathways to global hydrogen production within planetary boundaries"
# - Author: Michaël Lejeune⁺[a,b], Sami Kara [a,b],Michael Zwicky Hauschild [d], Rahman Daiyan [b,c], 
# - Code maintainer author⁺ email: m.lejeune@unsw.edu.au
# - Affiliations: 
    ## - a. Sustainability in Manufacturing and Life Cycle Engineering Research Group, School of Mechanical and Manufacturing Engineering, The University of New South Wales, Sydney 2052, Australia. 
    ## - b. Australian Research Council, Training Centre for the Global Hydrogen Economy, Sydney 2052, Australia. 
    ## - c. School of Minerals and Energy Engineering, The University of New South Wales, Sydney 2052, Australia. 
    ## - d. Centre for Absolute Sustainability, Technical University of Denmark, Kgs, Lyngby, Denmark.
module optimisation
    export opti,𝐏,OptimisationStructb
    using JLD2
    include("../utils/main_utils.jl")
    include("../data/namings.jl")
    include("../../Utils/general_utils/ssp_utils.jl")
    @load "../Source data/03_additional_data/1_00_total_human_impact/data_interaction_matrices.jld2"
    @load "../Source data/02_results/main/Fig2/ensemble.jld"
    df=df_h2
    using lce, .TcmUtils #internal Dependencies
    using JuMP, CPLEX, LinearAlgebra, Statistics, DataFrames, JLD2, Distributions, SparseArrays #external dependencies
    import Statistics:quantile
    # Operators: we keep the math as close to that of the paper.
        ⊙ = .* # elementwise multiplication - Hadamard product
        ⊘ = ./ # elementwise division - Hadamard division
        ⊕ = .+ # elementwise addition - Hadamard sum
        ⊖ = .- # elementwise subtraction - Hadamard difference
        ∑ = sum # summation operator
        function quantile(a::Matrix{Float64}, q::Float64; dims::Int64)
            return mapslices(x -> quantile(x, q), a; dims=dims)|> vec
        end
        function quantile(a::Array{Float64, 3}, q::Float64; dims::Int64)
            return mapslices(x -> quantile(x, q), a; dims=dims)
        end
    #end

    if isfile("./main/modules/pre_optimisation.jld")
        @info "loading cache data"
        @load "./main/modules/pre_optimisation.jld"
    else
        @info "creating cache data"
        include("./pre_optimisation.jl")
        using .pre_optimisation #load the pre-optimisation module.
        @load "./main/modules/pre_optimisation.jld"
    end
    
    ## Ratio solar wind fluctuations
        rsolarwindmed=median(getVals("Secondary Energy|Electricity|Wind",df=df)./getVals("Secondary Energy|Electricity|Solar",df=df),dims=1)[(2025:5:2050).-2019]
        rsolarmax=maximum(getVals("Secondary Energy|Electricity|Wind",df=df)./getVals("Secondary Energy|Electricity|Solar",df=df),dims=1)[(2025:5:2050).-2019]
        rsolarmin=minimum(getVals("Secondary Energy|Electricity|Wind",df=df)./getVals("Secondary Energy|Electricity|Solar",df=df),dims=1)[(2025:5:2050).-2019];
        δwindsol=TriangularDist.(rsolarmin, rsolarmax, rsolarwindmed)
    ## end
    

    𝐏=OptiData.project
    δ𝐀 = OptiData.δ𝐀  #technosphere matrix
    δ𝐁 = OptiData.δ𝐁  #biosphere matrix
    δ𝐜 = OptiData.δ𝐜ᵗ #constrains
    𝛚 = OptiData.𝛚 # allocated space
    @load "main/modules/Qmatrix.jld2" 𝐐
    
    𝐟 = OptiData.𝐟  #demand vector
    𝚪 = Matrix(𝚪ᵦ) #Matrix(𝚪ₕ) #interaction matrix

    #elementary flows keys represented by 𝖊 `\bfrake` 
    𝖊ᴴ² = getBio("Hydrogen","air, unspecified",project=𝐏).key
    
    ### reference flow keys, represented by a variable 𝕴 `\bfrakI` 
    𝕴ᴰᴬᶜ = getAct(:DAC,project=𝐏).ref_row
    𝕴ᴴ² = getAct(:hydrogen,project=𝐏).ref_row
    𝕴ᴱᴸⱽ = getAct(:electricityLV,project=𝐏).ref_row
    𝕴ᴱᴴⱽ = getAct(:electricityHV,project=𝐏).ref_row

    ## Sets of processes are represented by the 𝖘 `\bfraks`

    """
    # Function to create a new set of processes based on a vector of symbols.
    """
    function newSet(vec::Vector{Symbol})
        𝖘=[v.second for v in getTcmKey(vec,𝐏)]
        return 𝖘
    end

    𝖘⁺  = getTcmChoices(𝐏,all_keys=true)  #set of process choice indices
    𝖘ᴴ² = getTcmChoices(:hydrogen ,𝐏)    #set of hydrogen production process indices
    𝖘ᴱᴸⱽ = [getTcmKey("electricity production, photovoltaic, 570kWp open ground installation, multi-Si","RoW",𝐏)] #set of electricity high voltage indices
    𝖘ᴱᴴⱽ = getTcmChoices(:electricityHV,𝐏) #set of electricity low voltage indices
 

    ## sets
    𝖘ᴺᴳ = newSet([:SMR,:hydrogen_pyrolysis])
    𝖘ᴺᴳ⁻ᶜᶜˢ = newSet([:hydrogen_SMRccs,:hydrogen_bSMRccs])

    𝖘ᶠᵒˢˢⁱˡ⁻ᶜᶜˢ= newSet([:hydrogen_SMRccs,:hydrogen_coalccs])
    𝖘ˢᵒᵉᶜ = newSet([:hydrogen_SOEC_steam,:hydrogen_SOEC_elec])
    𝖘ᵉˡᵉᶜᵗʳᵒˡʸˢⁱˢ = newSet([:hydrogen_PEM,:hydrogen_AE,:hydrogen_SOEC_steam,:hydrogen_SOEC_elec]) 

    𝖘ᵇᶦᵒ= newSet([:hydrogen_BioCccs,:hydrogen_bSMRccs,:hydrogen_bSMR,:hydrogen_BioG]) #set of hydrogen bio processes indices
    𝖘ᵇᶦᵒ⁻ᶜᶜˢ = newSet([:hydrogen_bSMRccs,:hydrogen_BioCccs])
    𝖘ᵇᶦᵒ⁻ʷᵒ⁻ᶜᶜˢ = newSet([:hydrogen_bSMR,:hydrogen_BioG])

    𝖘ᵈᵃᶜ=newSet([:DAC_heatpump,:DAC_steam])

    """
    quick function to get the electricity sets.
    """
    function electricity_sets()
        𝖘ᴱᴴⱽ = getTcmChoices(:electricityHV,𝐏) 
        PV_key=getTcmKey("electricity production, photovoltaic, 570kWp open ground installation, multi-Si","RoW",𝐏)
        𝖘ᴱ=vcat(𝖘ᴱᴴⱽ,[PV_key])
        act_to_tcm=Dict([x.second.act =>x.first for x ∈ pairs(filter(j -> j[1] in 𝖘ᴱ, getTcmAct(𝐏)))]...)
        res_elect_to_tcm = Dict(Symbol(process_names[k]) => v for (k, v) in act_to_tcm if haskey(process_names, k))

        𝖘oil_coal=[res_elect_to_tcm[i] for i in [:E_Oil,:E_Coal_SC,:E_Coal]]
        𝖘lignite_peat=[res_elect_to_tcm[i] for i in [:E_Lignite,:E_Lignite_IGCC,:E_Peat]]
        𝖘gas=[res_elect_to_tcm[i] for i in [:E_NG,:E_Gas_10MW,:E_NGccs]]
        𝖘ⁿᵘᶜˡᵉᵃʳ=[res_elect_to_tcm[i] for i in [:E_Nuclear_PWR,:E_Nuclear_PWR_HWM,:E_Nuclear_BWR]]
        𝖘ᴱᴸ⁻ᵇᶦᵒ=[res_elect_to_tcm[i] for i in [:E_Wood_Future]]
        𝖘solar_wind=[res_elect_to_tcm[i] for i in [:E_PV,:E_Solar_Thermal,:E_Wind_Onshore]]
        𝖘hydro=[res_elect_to_tcm[i] for i in [:E_Hydro]]
        𝖘geothermal=[res_elect_to_tcm[i] for i in [:E_Geothermal]]

        return 𝖘oil_coal,𝖘lignite_peat,𝖘gas,𝖘ⁿᵘᶜˡᵉᵃʳ,𝖘ᴱᴸ⁻ᵇᶦᵒ,𝖘solar_wind,𝖘hydro,𝖘geothermal
    end
    𝖘oil_coal,𝖘lignite_peat,𝖘gas,𝖘ⁿᵘᶜˡᵉᵃʳ,𝖘ᴱᴸ⁻ᵇᶦᵒ,𝖘solar_wind,𝖘hydro,𝖘geothermal= electricity_sets()
    
    𝖘ᴱ=vcat([𝖘oil_coal,𝖘lignite_peat,𝖘gas,𝖘ⁿᵘᶜˡᵉᵃʳ,𝖘ᴱᴸ⁻ᵇᶦᵒ,𝖘solar_wind,𝖘hydro,𝖘geothermal]...)
    𝖘ᴿᴱ°=vcat([𝖘ⁿᵘᶜˡᵉᵃʳ[1],𝖘solar_wind,𝖘hydro,𝖘geothermal]...)
    𝖘ᴿᴱ=vcat([𝖘ⁿᵘᶜˡᵉᵃʳ,𝖘solar_wind,𝖘hydro,𝖘geothermal]...)
    𝖘ᴿᴱ

    # ### Efficiencies
        #     ### FIXME: add the indices.
        #     𝖘ᵉ #create the set of electrical efficiency gain of hydrogen technologies.
        #     𝛈ᵉ # corresponding vector to account for efficiency gains. 
        #     iᵉ # this is where the electricity is produced from choices.
        #     𝐀[iᵉ,𝖘ᵉ] = 𝐀[i_electicity,𝖘ᵉ] ⊘ 𝛈ᵉ #efficiency gains accounted for.

        #     # 𝖘ᵐ #create the set of materal efficiency gains for technologies.
        #     # 𝛈ᵐ # corresponding vector to account for efficiency gains. 
        #     # iᵐ # this is where the electricity is produced from choices.
        #     # 𝐀[iᵐ,𝖘ᵐ] = 𝐀[iᵐ,𝖘ᵐ] ⊘ 𝛈ᵐ #efficiency gains accounted for.
    # ## end

    """
    function to truncate the constrain vector to avoid unfeasbility issues.
    """
    function sample_trunc_q65_q95(arr::AbstractArray{<:Distribution}, y::Int)
        out = Vector{Float64}(undef, size(arr, 1))
        for i in 1:size(arr, 1)
            dist = arr[i, 1, y]
            if dist isa Dirac
                out[i] = dist.value
            else
                a = quantile(dist, 0.65)   # 65th percentile
                b = quantile(dist, 0.95)  # 95th percentile
                out[i] = rand(Truncated(dist, a, b))
            end
        end
        return out
    end

    #TODO: add fluctuations of efficiencies for electrolysis.
    η_electrolysis =[0.873239437	0.929577465	0.943661972	0.957746479	0.971830986	1
                    0.893333333	0.906666667	0.933333333	0.96	0.973333333	1
                    0.94047619	0.964285714	0.964285714	0.976190476	0.988095238	1
                    0.94047619	0.964285714	0.964285714	0.976190476	0.988095238	1]#.*0.7

    

    """
    # Function to minimise the planetary footprint of hydrogen production.

    ## Description
    > This function minimises the planetary footprint of hydrogen production by optimising the scale of technologies involved in the choices. It uses the CPLEX solver to find the optimal solution.
    """
    function opti(;#inputs
                    δ𝐀=δ𝐀,    # i × j × yr
                    δ𝐁=δ𝐁,    # e × j × yr
                    δ𝐜=δ𝐜,     # j× 1 × yr
                    δ𝛚=𝛚,     # z × 1 × yr
                    #parameters
                    dac::Union{Float64,Int}=0, #this is for integrating direct air capture in the optimisation.
                    h2_leak::Union{Float64,Int}=0,
                    stochastic=false,
                    samples=100,
                    interactions=false,
                    human_interact=false,
                    climate_impact=false,
                    biosphere_integrity_impact=false,
                    impact_selection=nothing,
                    result_format=:pressure,
                    full_electrolysis=false, # if true, we only allow one electrolysis technology to be selected.
                    full_biomass=false, # if true, we only allow one biomass technology to be selected.
                    full_fossil_ccs=false,
                    full_renewables=false, # if true, we only allow one renewable technology to be selected.
                    contrib_year=nothing,
                    opti_dac=false, 
                    q=0.95,
                    )

        if human_interact
            𝚪 = Matrix(𝚪ₕ)
        else
            𝚪 = Matrix(𝚪ᵦ)
        end
        yr=6
         
        # Space allocation for results.
        if stochastic
            𝐗 = zeros(10,samples,yr) # pressure -> response
            𝐃 = zeros(10,samples,yr) # pressure only
            𝐒 = zeros(size(δ𝐀,2),samples,yr) # scale of technologies
            𝐀° = zeros(size(δ𝐀,1),size(δ𝐀,2),samples,yr)
            𝐁° = zeros(size(δ𝐁,1),size(δ𝐁,2),samples,yr)
            for y in 1:1:yr
                
                for i in 1:samples
                    𝐀 = rand.(δ𝐀)[:,:,y]
                    𝐁 = rand.(δ𝐁)[:,:,y]
                    𝐀[𝕴ᴱᴸⱽ,[106,90,113,114]]=𝐀[𝕴ᴱᴸⱽ,[106,90,113,114]].*η_electrolysis[:,y] #update electrolysis efficiencies
                    r_solarwind=rand.(δwindsol)[y]
                    if full_biomass || full_fossil_ccs || full_electrolysis
                         𝐜 = quantile.(δ𝐜,q)[:,1,y]
                    else
                        𝐜 = sample_trunc_q65_q95(δ𝐜,y)
                    end
                    𝛚 = rand.(δ𝛚)[:,1,y]

                    𝖘 = 1:1:size(𝐀,2)
                    𝐠ᴴ² = zeros(size(𝐁,1))
                    𝐠ᴴ²[𝖊ᴴ²] = h2_leak
                    𝐜 = 𝐜 ⊙ (1+h2_leak)

                    model=Model(optimizer_with_attributes(CPLEX.Optimizer))
                    set_silent(model)

                    # Variables
                    @variable(model, 𝐬[1:size(𝐀,2)]) # 𝐬 [scale unit × kgH₂⁻¹] should be as long as the processes in the technosphere.
                    @variable(model, 0 ≤ 𝛇 ≤ 15)
                    @variable(model, 𝐟[1:size(𝐀,1)])

                    # Expressions
                    @expression(model, 𝐠, 𝐠ᴴ² ⊕ 𝐁*𝐬) # 𝐠 = 𝐠ᴴ²+𝐐𝐁𝐬, Here we add potential hydrogen emissions from 0 to 0.3
                    @expression(model, 𝐝, 𝐐*𝐠 ⊘ 𝛚) # 𝐝 = 𝐐𝐠 ⊘ 𝛚 -> Direct normalised impact.   

                    if  interactions
                        @expression(model, 𝐱, 𝚪*𝐝) # 𝐱 = 𝚪𝐝 -> normalised state variables with interactions 
                    else
                        @expression(model, 𝐱, 𝐝) # 𝐱=𝐝 -> normalised state variables without interactions 
                    end 

                    
                    if climate_impact
                        @objective(model, Min, 𝐱[1])# here we only consider the climate impact.

                    elseif biosphere_integrity_impact
                            @objective(model, Min, 𝐱[10])# here we only consider the biosphere integrity impact
                    elseif impact_selection ≠ nothing
                            @objective(model, Min, sum(𝐱[impact_selection])) # here we consider a custom selection of impacts.
                    else
                            # objective function
                            @objective(model, Min, 𝐱) # Multi objective optimisation.
                    end

                    # constraints
                    @constraint(model, 𝐟[Not(vcat(𝕴ᴰᴬᶜ,𝕴ᴴ²))] .== 0)
                    @constraint(model, 𝐟[𝕴ᴴ²] == (1+h2_leak))

                    if opti_dac
                        # @info "optimising DAC"
                        @constraint(model, 𝐟[𝕴ᴰᴬᶜ] == 𝛇)
                    else
                        @constraint(model, 𝐟[𝕴ᴰᴬᶜ] == dac)
                    end


                    @constraint(model, 𝐀*𝐬 == 𝐟) # Here we impose that hydrogen and some CCS if selected need to be produced
                    @constraint(model, 𝐬[𝖘⁺] ≥ 0) # define the set 𝐬⁺ of processes involved in choices where 𝐬 cannot be negative.
                    

                    if full_renewables

                        𝖘ᴱᴸⱽ⁻ = 𝐀[𝕴ᴱᴸⱽ,𝖘] .< 0 #electricty consumption only
                        𝖘ᴱᴴⱽ⁻ = 𝐀[𝕴ᴱᴴⱽ,𝖘] .< 0 #electricty consumption only

                        cs=∑(𝐜[𝖘ᴿᴱ])/ ∑(𝐜[𝖘ᴿᴱ°])
                        ca=𝐜[𝖘ᴿᴱ].+0.1 #here we add a bit of flexibility to avoid numerical issues.
                        𝐜[𝖘ᴱᴸⱽ]= zeros(length(𝖘ᴱᴸⱽ))
                        𝐜[𝖘ᴱᴴⱽ]= zeros(length(𝖘ᴱᴴⱽ))
                        𝐜[𝖘ᴿᴱ] = ca
                    
                        @expression(model, 𝐜ᴱᴴⱽ, ⊖(𝐀[𝕴ᴱᴴⱽ,𝖘ᴱᴴⱽ⁻]' * 𝐬[𝖘ᴱᴴⱽ⁻]) ⊙ (𝐜[𝖘ᴱᴴⱽ] ⊙ cs))
                        @expression(model, 𝐜ᴱᴸⱽ, ⊖(𝐀[𝕴ᴱᴸⱽ,𝖘ᴱᴸⱽ⁻]' * 𝐬[𝖘ᴱᴸⱽ⁻]) ⊙ (𝐜[𝖘ᴱᴸⱽ] ⊙ cs))

                        @constraint(model, 𝐬[𝖘ᴱᴴⱽ] ≤ 𝐜ᴱᴴⱽ)
                        @constraint(model, 𝐬[𝖘ᴱᴸⱽ] ≤ 𝐜ᴱᴸⱽ)

                        @constraint(model, ∑(𝐬[𝖘ⁿᵘᶜˡᵉᵃʳ]) ≤ 𝐜[𝖘ⁿᵘᶜˡᵉᵃʳ][1])

                        @constraint(model, 𝐬[𝖘solar_wind[1]]*r_solarwind == 𝐬[𝖘solar_wind[3]])

                    else
                        #constraining electricty low volatge.
                        𝖘ᴱᴸⱽ⁻ = 𝐀[𝕴ᴱᴸⱽ,𝖘] .< 0 #electricty consumption only
                        @expression(model, 𝐜ᴱᴸⱽ, ⊖(𝐀[𝕴ᴱᴸⱽ,𝖘ᴱᴸⱽ⁻]' * 𝐬[𝖘ᴱᴸⱽ⁻]) ⊙ 𝐜[𝖘ᴱᴸⱽ]) # constraint based on the total consumption of the system

                        @constraint(model, 𝐬[𝖘ᴱᴸⱽ] ≤ 𝐜ᴱᴸⱽ)

                        #constraining electricty high voltage.
                        𝖘ᴱᴴⱽ⁻ = 𝐀[𝕴ᴱᴴⱽ,𝖘] .< 0 #electricty consumption only
                        @expression(model, 𝐜ᴱᴴⱽ, ⊖(𝐀[𝕴ᴱᴴⱽ,𝖘ᴱᴴⱽ⁻]' * 𝐬[𝖘ᴱᴴⱽ⁻]) ⊙ 𝐜[𝖘ᴱᴴⱽ]) # constraint based on the total consumption of the system
                        @constraint(model, 𝐬[𝖘ᴱᴴⱽ] ≤ 𝐜ᴱᴴⱽ)
                        @constraint(model, ∑(𝐬[𝖘ⁿᵘᶜˡᵉᵃʳ]) ≤ 𝐜[𝖘ⁿᵘᶜˡᵉᵃʳ][1])
                        @constraint(model, ∑(𝐬[𝖘gas]) ≤ 𝐜[𝖘gas][1])

                    end

                    
                    if full_electrolysis
                        𝐜ᵉˡᵉᶜᵗʳᵒˡʸˢⁱˢ = 𝐜[𝖘ᵉˡᵉᶜᵗʳᵒˡʸˢⁱˢ] ⊘ ∑(𝐜[𝖘ᵉˡᵉᶜᵗʳᵒˡʸˢⁱˢ][1:3]) ⊙ (1+h2_leak)
                        𝐜[𝖘ᴴ²]= zeros(length(𝖘ᴴ²))
                        𝐜[𝖘ᵉˡᵉᶜᵗʳᵒˡʸˢⁱˢ]= 𝐜ᵉˡᵉᶜᵗʳᵒˡʸˢⁱˢ
                        @constraint(model, 𝐬[𝖘ᴴ²] ≤ 𝐜[𝖘ᴴ²])
                        @constraint(model, ∑(𝐬[𝖘ˢᵒᵉᶜ]) ≤ 𝐜[𝖘ˢᵒᵉᶜ][1])
                    elseif full_biomass
                        𝐜ᵇᶦᵒ = 𝐜[𝖘ᵇᶦᵒ] ⊘ (∑(𝐜[𝖘ᵇᶦᵒ][2:3])) ⊙ (1+h2_leak)
                        𝐜[𝖘ᴴ²] = zeros(length(𝖘ᴴ²))
                        𝐜[𝖘ᵇᶦᵒ] = 𝐜ᵇᶦᵒ
                        # println(𝐜[𝖘ᵇᶦᵒ])
                        @constraint(model, 𝐬[𝖘ᴴ²] ≤ 𝐜[𝖘ᴴ²])
                        @constraint(model, ∑(𝐬[𝖘ᵇᶦᵒ⁻ᶜᶜˢ]) ≤ 𝐜[𝖘ᵇᶦᵒ⁻ᶜᶜˢ][2])
                        # @constraint(model, ∑(𝐬[𝖘ᵇᶦᵒ⁻ʷᵒ⁻ᶜᶜˢ]) ≤ 𝐜[𝖘ᵇᶦᵒ⁻ʷᵒ⁻ᶜᶜˢ][1])
                    
                    elseif full_fossil_ccs
                        𝐜ᶠᵒˢˢⁱˡ⁻ᶜᶜˢ = 𝐜[𝖘ᶠᵒˢˢⁱˡ⁻ᶜᶜˢ]⊘ ∑(𝐜[𝖘ᶠᵒˢˢⁱˡ⁻ᶜᶜˢ]) ⊙ (1+h2_leak)
                        𝐜[𝖘ᴴ²] = zeros(length(𝖘ᴴ²))
                        𝐜[𝖘ᶠᵒˢˢⁱˡ⁻ᶜᶜˢ] = 𝐜ᶠᵒˢˢⁱˡ⁻ᶜᶜˢ
                        @constraint(model, 𝐬[𝖘ᴴ²] ≤ 𝐜[𝖘ᴴ²])
                    else
   
                        @constraint(model, 𝐬[𝖘ᴴ²] ≤ 𝐜[𝖘ᴴ²])
                        @constraint(model, ∑(𝐬[𝖘ⁿᵘᶜˡᵉᵃʳ]) ≤ 𝐜[𝖘ⁿᵘᶜˡᵉᵃʳ][1])
                        @constraint(model, ∑(𝐬[𝖘ᴺᴳ⁻ᶜᶜˢ]) ≤ 𝐜[𝖘ᴺᴳ⁻ᶜᶜˢ][1])
                        @constraint(model, ∑(𝐬[𝖘gas]) ≤ 𝐜[𝖘gas][1])
                        @constraint(model, ∑(𝐬[𝖘ˢᵒᵉᶜ]) ≤ 𝐜[𝖘ˢᵒᵉᶜ][1]) 
                        @constraint(model, ∑(𝐬[𝖘ᵇᶦᵒ⁻ᶜᶜˢ]) ≤ 𝐜[𝖘ᵇᶦᵒ⁻ᶜᶜˢ][1])
                        @constraint(model, ∑(𝐬[𝖘ᵇᶦᵒ⁻ʷᵒ⁻ᶜᶜˢ]) ≤ 𝐜[𝖘ᵇᶦᵒ⁻ʷᵒ⁻ᶜᶜˢ][1])
                    end

                    
                    # Optimisation
                    optimize!(model)
                    if !is_solved_and_feasible(model)
                        error("Solver did not find an optimal solution")
                    end
                    # Collecting results
                    𝐗[:,i,y] = value.(𝐱)
                    𝐃[:,i,y] = value.(𝐝)
                    𝐒[:,i,y] = value.(𝐬)
                    𝐀°[:,:,i,y] = 𝐀
                    𝐁°[:,:,i,y] = 𝐁
                end
                end

                if result_format==:scale
                        return 𝐒

                elseif result_format==:response
                            return 𝐗
        
                elseif result_format==:pressure
                        return 𝐃

                elseif result_format==:overconstraint
                        return value.(𝛇)
                end

        else

            𝐗 = zeros(10,yr) # pressure -> response
            𝐃 = zeros(10,yr) # pressure only
            𝐒 = zeros(size(δ𝐀,2),yr) # scale of technologies
            𝐆 = zeros(size(δ𝐁,1),yr)
            𝐇 = nothing
            𝛀 = nothing
            ζ = zeros(1,6)

            for y in 1:yr
                𝐀=median.(δ𝐀)[:,:,y]
                𝐁=median.(δ𝐁)[:,:,y]
                𝐜=quantile.(δ𝐜,q)[:,1,y]
                𝛚=median.(δ𝛚)[:,1,y]
                𝖘 = 1:1:size(𝐀,2)
                𝐠ᴴ² = zeros(size(𝐁,1))
                𝐠ᴴ²[𝖊ᴴ²] = h2_leak
                r_solarwind=modes.(δwindsol)[y]
                𝐜 = 𝐜 ⊙ (1+h2_leak)

                𝐀[𝕴ᴱᴸⱽ,[106,90,113,114]]=𝐀[𝕴ᴱᴸⱽ,[106,90,113,114]].*η_electrolysis[:,y]

                model=Model(optimizer_with_attributes(CPLEX.Optimizer))
                set_silent(model)

                # Variables
                @variable(model, 𝐬[1:size(𝐀,2)]) # 𝐬 [scale unit × kgH₂⁻¹] should be as long as the processes in the technosphere.
                @variable(model, 𝐟[1:size(𝐀,1)])
                
                # Expressions
                @expression(model, 𝐠, 𝐠ᴴ² ⊕ 𝐁*𝐬) # 𝐠 = 𝐠ᴴ²+𝐁𝐬, Here we add potential hydrogen emissions from 0 to 0.3
                @expression(model, 𝐝, 𝐐*𝐠 ⊘ 𝛚) # 𝐝 = 𝐐𝐠 ⊘ 𝛚 -> Direct normalised impact.   

                if  interactions
                    @expression(model, 𝐱, 𝚪*𝐝) # 𝐱 = 𝚪𝐝 -> normalised state variables with interactions 
                else
                    @expression(model, 𝐱, 𝐝) # 𝐱=𝐝 -> normalised state variables without interactions 
                end 


                # unused expression to track costs and or materials.
                #@expression(model, 𝐢, 𝚵*𝐬) # 𝐢 = 𝚵*𝐬 with 𝚵 elements in [$ × kgH₂⁻¹] produced. 𝐢  the total investments in [$]
                #@expression(model, 𝐦, 𝐌*𝐬) # 𝐦 = 𝐌*𝐬 with 𝐌 elements in [unit_material × kgH₂⁻¹] produced. 𝐦 in [unit_material] used

                if climate_impact
                        @objective(model, Min, 𝐱[1])# here we only consider the climate impact.

                elseif biosphere_integrity_impact
                        @objective(model, Min, 𝐱[10])# here we only consider the biosphere integrity impact
                elseif impact_selection ≠ nothing
                        @objective(model, Min, sum(𝐱[impact_selection])) # here we consider a custom selection of impacts.
                else
                        # objective function
                        @objective(model, Min, 𝐱) # Multi objective optimisation.
                end

                if opti_dac
                    # @info "optimising DAC"
                    @variable(model, 0 ≤ 𝛇 ≤ 15)
                    @constraint(model, 𝐟[𝕴ᴰᴬᶜ] == 𝛇)
                else
                    # @info "DAC fixed"
                    @constraint(model, 𝐟[𝕴ᴰᴬᶜ] == dac)
                end
                
                # constraints
                @constraint(model, 𝐟[Not(vcat(𝕴ᴰᴬᶜ,𝕴ᴴ²))] .== 0)
                @constraint(model, 𝐟[𝕴ᴴ²] == (1+h2_leak))
                @constraint(model, 𝐀*𝐬 == 𝐟) # Here we impose that hydrogen and some DACS if selected need to be produced
                @constraint(model, 𝐬[𝖘⁺] ≥ 0) # define the set 𝐬⁺ of processes involved in choices where 𝐬 cannot be negative.
                
                
                if full_renewables

                    𝖘ᴱᴸⱽ⁻ = 𝐀[𝕴ᴱᴸⱽ,𝖘] .< 0 #electricty consumption only
                    𝖘ᴱᴴⱽ⁻ = 𝐀[𝕴ᴱᴴⱽ,𝖘] .< 0 #electricty consumption only

                    cs=∑(𝐜[𝖘ᴿᴱ])/ ∑(𝐜[𝖘ᴿᴱ°])
                    ca=𝐜[𝖘ᴿᴱ].+0.1 #here we add a bit of flexibility to avoid numerical issues.
                    𝐜[𝖘ᴱᴸⱽ]= zeros(length(𝖘ᴱᴸⱽ))
                    𝐜[𝖘ᴱᴴⱽ]= zeros(length(𝖘ᴱᴴⱽ))
                    𝐜[𝖘ᴿᴱ] = ca
                    

                    @expression(model, 𝐜ᴱᴴⱽ, ⊖(𝐀[𝕴ᴱᴴⱽ,𝖘ᴱᴴⱽ⁻]' * 𝐬[𝖘ᴱᴴⱽ⁻]) ⊙ (𝐜[𝖘ᴱᴴⱽ] ⊙ cs))
                    @expression(model, 𝐜ᴱᴸⱽ, ⊖(𝐀[𝕴ᴱᴸⱽ,𝖘ᴱᴸⱽ⁻]' * 𝐬[𝖘ᴱᴸⱽ⁻]) ⊙ (𝐜[𝖘ᴱᴸⱽ] ⊙ cs))

                    @constraint(model, 𝐬[𝖘ᴱᴴⱽ] ≤ 𝐜ᴱᴴⱽ)
                    @constraint(model, 𝐬[𝖘ᴱᴸⱽ] ≤ 𝐜ᴱᴸⱽ)

                    @constraint(model, ∑(𝐬[𝖘ⁿᵘᶜˡᵉᵃʳ]) ≤ 𝐜[𝖘ⁿᵘᶜˡᵉᵃʳ][1])
                    @constraint(model, 𝐬[𝖘solar_wind[1]]*r_solarwind[1] == 𝐬[𝖘solar_wind[3]])

                else
                    #constraining electricty low volatge.
                    𝖘ᴱᴸⱽ⁻ = 𝐀[𝕴ᴱᴸⱽ,𝖘] .< 0 #electricty consumption only
                    @expression(model, 𝐜ᴱᴸⱽ, ⊖(𝐀[𝕴ᴱᴸⱽ,𝖘ᴱᴸⱽ⁻]' * 𝐬[𝖘ᴱᴸⱽ⁻]) ⊙ 𝐜[𝖘ᴱᴸⱽ]) # constraint based on the total consumption of the system

                    @constraint(model, 𝐬[𝖘ᴱᴸⱽ] ≤ 𝐜ᴱᴸⱽ)

                    #constraining electricty high voltage.
                    𝖘ᴱᴴⱽ⁻ = 𝐀[𝕴ᴱᴴⱽ,𝖘] .< 0 #electricty consumption only
                    @expression(model, 𝐜ᴱᴴⱽ, ⊖(𝐀[𝕴ᴱᴴⱽ,𝖘ᴱᴴⱽ⁻]' * 𝐬[𝖘ᴱᴴⱽ⁻]) ⊙ 𝐜[𝖘ᴱᴴⱽ]) # constraint based on the total consumption of the system
                    @constraint(model, 𝐬[𝖘ᴱᴴⱽ] ≤ 𝐜ᴱᴴⱽ)
                    @constraint(model, ∑(𝐬[𝖘ⁿᵘᶜˡᵉᵃʳ]) ≤ 𝐜[𝖘ⁿᵘᶜˡᵉᵃʳ][1])
                    @constraint(model, ∑(𝐬[𝖘gas]) ≤ 𝐜[𝖘gas][1])

                end

                if full_electrolysis
                    𝐜ᵉˡᵉᶜᵗʳᵒˡʸˢⁱˢ = (𝐜[𝖘ᵉˡᵉᶜᵗʳᵒˡʸˢⁱˢ] ⊘ ∑(𝐜[𝖘ᵉˡᵉᶜᵗʳᵒˡʸˢⁱˢ][1:3])) ⊙ (1+h2_leak)
                    𝐜[𝖘ᴴ²]= zeros(length(𝖘ᴴ²))
                    𝐜[𝖘ᵉˡᵉᶜᵗʳᵒˡʸˢⁱˢ]= 𝐜ᵉˡᵉᶜᵗʳᵒˡʸˢⁱˢ
                    @constraint(model, 𝐬[𝖘ᴴ²] ≤ 𝐜[𝖘ᴴ²])
                    @constraint(model, ∑(𝐬[𝖘ˢᵒᵉᶜ]) ≤ 𝐜[𝖘ˢᵒᵉᶜ][1])
                elseif full_biomass

                    𝐜ᵇᶦᵒ = (𝐜[𝖘ᵇᶦᵒ] ⊘ ∑(𝐜[𝖘ᵇᶦᵒ][2:3])) ⊙ (1+h2_leak)

                    𝐜[𝖘ᴴ²] = zeros(length(𝖘ᴴ²))
                    𝐜[𝖘ᵇᶦᵒ] = 𝐜ᵇᶦᵒ

                    @constraint(model, ∑(𝐬[𝖘ᵇᶦᵒ⁻ᶜᶜˢ]) ≤ 𝐜[𝖘ᵇᶦᵒ⁻ᶜᶜˢ][1])
                    @constraint(model, ∑(𝐬[𝖘ᵇᶦᵒ⁻ʷᵒ⁻ᶜᶜˢ]) ≤ 𝐜[𝖘ᵇᶦᵒ⁻ʷᵒ⁻ᶜᶜˢ][1])
                    @constraint(model, 𝐬[𝖘ᴴ²] ≤ 𝐜[𝖘ᴴ²])

                elseif full_fossil_ccs
                    𝐜ᶠᵒˢˢⁱˡ⁻ᶜᶜˢ = (𝐜[𝖘ᶠᵒˢˢⁱˡ⁻ᶜᶜˢ]⊘ ∑(𝐜[𝖘ᶠᵒˢˢⁱˡ⁻ᶜᶜˢ])) ⊙ (1+h2_leak)
                    𝐜[𝖘ᴴ²] = zeros(length(𝖘ᴴ²))
                    𝐜[𝖘ᶠᵒˢˢⁱˡ⁻ᶜᶜˢ] = 𝐜ᶠᵒˢˢⁱˡ⁻ᶜᶜˢ
                    @constraint(model, 𝐬[𝖘ᴴ²] ≤ 𝐜[𝖘ᴴ²])
                else
                    @constraint(model, 𝐬[𝖘ᴴ²] ≤ 𝐜[𝖘ᴴ²])
                    @constraint(model, ∑(𝐬[𝖘ˢᵒᵉᶜ]) ≤ 𝐜[𝖘ˢᵒᵉᶜ][1]) 
                    @constraint(model, ∑(𝐬[𝖘ᵇᶦᵒ⁻ᶜᶜˢ]) ≤ 𝐜[𝖘ᵇᶦᵒ⁻ᶜᶜˢ][1])
                    @constraint(model, ∑(𝐬[𝖘ᵇᶦᵒ⁻ʷᵒ⁻ᶜᶜˢ]) ≤ 𝐜[𝖘ᵇᶦᵒ⁻ʷᵒ⁻ᶜᶜˢ][1])
                end
                

                optimize!(model)
                if !is_solved_and_feasible(model)
                    # solution_summary(model)
                    error("Solver did not find an optimal solution")
                end

                𝐗[:,y] = value.(𝐱)
                𝐃[:,y] = value.(𝐝)
                𝐒[:,y] = value.(𝐬)
                𝐆[:,y] = value.(𝐠)
                if opti_dac
                    ζ[1,y] = value.(𝛇)
                end
                if !isnothing(contrib_year)
                    if y==(contrib_year-2020)/5
                        𝐇 = 𝐐*𝐁*diagm(value.(𝐬))
                        𝛀 = 𝛚
                    end
                end
            end

            if result_format==:LCA
                return 𝐐*𝐆

            elseif result_format==:contribution
                if interactions
                    𝐃° = 𝐇 ⊘ 𝛀
                    𝐗° = 𝚪*𝐃°
                    𝐗° = 𝐗° ⊘ sum(𝐗°, dims=2) # normalise contributions
                    return  𝐗°
                else
                    𝐇°=𝐇 ⊘ sum(𝐇, dims=2)
                    return  𝐇°
                end

            elseif result_format==:scale
                return 𝐒

            elseif result_format==:response
                return 𝐗
            elseif result_format==:pressure
                return 𝐃
            elseif result_format==:dac
                return ζ
            end
        end
    end    
end

#TODO: delete(model, c) and unregister(model, :c) for constraints might be faster than rebuilding the model every time.
# using .optimisation #export the module to the main module.