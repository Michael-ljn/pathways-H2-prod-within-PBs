# This module can be ran once. It's purpose it to generate a struct containing everything we need without keeping in memory a lot of unnecessary data. 
module pre_optimisation
    export OptimisationStructb
    include("./constraints.jl")
    include("../utils/main_utils.jl")
    include("../data/namings.jl")
    include("inventories.jl")

    using lce, .constrains, .TcmUtils, .inventories #internal Dependencies
    using LinearAlgebra, Statistics, DataFrames, JLD2, Distributions,SparseArrays #external dependencies
    using JLD2
    @load "../Source data/02_results/main/Fig2/aSOS.jld"
    @load "../Source data/03_additional_data/1_00_total_human_impact/data_interaction_matrices.jld2"

    # if isfile("./pre_optimisation.jld")
        ⊙ = .*  # Define ⊙ as an alias for element-wise multiplication - Hadamard product
        ⊘ = ./  # Define ⊘ as an alias for element-wise division - Hadamard division
        
        struct OptimisationStructb
            project
            δ𝐀
            δ𝐁
            δ𝐜ᵗ
            𝛚
            𝐐
            𝐟
            𝚪
        end

        """
        Project initialisation function.
        """
        function ini()
                @info "projects are now loading"
                years=2025:5:2050;
                ini_scenario=["REMIND"=>1
                            "REMIND"=>2
                            "REMIND"=>5
                            # "IMAGE"=>2 #FIXEME: this model has a dimension issue
                            # "TIAM-UCL"=>2 #FIXEME: this model has a dimension issue but it is not an important model for the analysis.
                            ]
                ## Here we initialise the project. The dimensions are scenarios × years -> 5×6=30
                return [initProject("natcom",model=x.first,RCP=1.9,SSP=x.second,year=y) for x ∈ ini_scenario, y ∈ years]
        end 

        𝐏=ini()

        """
        # Internal function to generate δ𝐀,δ𝐁 matrices.
        """
        function _generate_matrices(p; save=true)
                LCI.(p) # compute the inventories.
                if save
                    saveProject.(p) # save projects for reuse. 
                end
                return ChoiceModel.(p)
        end 

        """
        # Function to generate the technology constraint vector for the optimisation problem.
        ## Description
        >This function generates the technology constraint vector for the optimisation problem. It is used to constrain the scale of technologies involved in the choices.
        ## Methods
        """
        function tech_constrain(p=𝐏[1,1])
            δc_PEM, δc_AE, δc_SOEC, δc_biomass_h2, δc_bioccs_h2, δc_NG, δc_NGccs, δc_Coal, δc_Coalccs = constrains.H2_constrains()

            δc_biomass_electricity,δc_gas_electricity_CC, δc_gas_electricity_noCC, δc_coal_electricity, δc_hydro_electricity, δc_nuclear_electricity, δc_wind_electricity, δc_solar_electricity, δc_solar_PV_electricity, δc_CSP_electricity, δc_geothermal_electricity = constrains.electricity_constraints()

            𝖘=getTcmChoices(p,all_keys=true) # set of choices
            PV_key=getTcmKey("electricity production, photovoltaic, 570kWp open ground installation, multi-Si","RoW",𝐏[1,1])
            𝖘=vcat(𝖘,[PV_key]) #creation of an electricity set.
            act_to_tcm=Dict([x.second.act =>x.first for x ∈ pairs(filter(j -> j[1] in 𝖘, getTcmAct(p)))]...)
            res_elect_to_tcm = Dict(Symbol(process_names[k]) => v for (k, v) in act_to_tcm if haskey(process_names, k))

            # assign activity keys to the uncertainty matrices
            act_to_uncertainty= Dict(
                                    :MP => δc_NG,
                                    :SMR => δc_NG,
                                    :bioSMR => δc_NG,

                                    :bioSMRccs => δc_NGccs,
                                    :SMRccs => δc_NGccs,
                                    
                                    :CG => δc_Coal,
                                    :CGccs => δc_Coalccs,
                                    
                                    :bioGccs => vec(δc_bioccs_h2),
                                    :bioG => δc_biomass_h2,
                                    :bioSMR => δc_biomass_h2,

                                    :SOECsteam => δc_SOEC,
                                    :SOECelectricity => δc_SOEC,
                                    :AEC => δc_AE,
                                    :PEM => δc_PEM,
                                    :E_Nuclear_PWR=> δc_nuclear_electricity,                                 
                                    :E_NGccs=> δc_gas_electricity_CC,
                                    :E_Coal=> δc_coal_electricity,
                                    :E_Coal_SC=>  δc_coal_electricity,
                                    :E_Nuclear_PWR_HWM=> δc_nuclear_electricity, 
                                    :E_Gas_10MW=> δc_gas_electricity_noCC,
                                    :E_NG=> δc_gas_electricity_noCC,
                                    :E_Hydro=> δc_hydro_electricity,
                                    :E_Wind_Onshore=> δc_wind_electricity ,
                                    :E_Nuclear_BWR=>δc_nuclear_electricity ,
                                    :E_Wood_Future=> δc_biomass_electricity,
                                    :E_Solar_Thermal=> δc_CSP_electricity,
                                    :E_PV=> δc_solar_electricity,
                                    :E_Geothermal=> δc_geothermal_electricity,
                                    )


                # update constrain vector.
                cm=ChoiceModel(p)[2]
                δ𝐜ᵗ= Matrix{UnivariateDistribution}(undef,cm.n,1)
                δ𝐜ᵗ.=Dirac(1)
                δ𝐜ᵗ=cat([δ𝐜ᵗ for _ in 1:6]..., dims=3)

                for y in 1:6
                    for (key,u) in pairs(act_to_uncertainty)
                        k=res_elect_to_tcm[key]
                        δ𝐜ᵗ[k,1,y]=u[y]
                    end
                end
                return δ𝐜ᵗ 
        end

        _generate_matrices(𝐏)

        ### Non mutable variables to read but not as constraints.
        δ𝐀,δ𝐁 = ChoiceModel(𝐏)
        δ𝐜ᵗ=tech_constrain()
        𝛚 = reshape(δ𝛀ᴾᵇ,10,1,6)
        𝐐 = Characterisation!().Matrix
        𝐟 =  spzeros(size(δ𝐀,1))
        𝚪=𝚪ᵦ
        @info "pre-optimisation data saving"
        saveProject(𝐏[1,1])

        OptiData=OptimisationStructb(𝐏[1,1], δ𝐀, δ𝐁, δ𝐜ᵗ, 𝛚, 𝐐, 𝐟, 𝚪)

        @save "./main/modules/pre_optimisation.jld" OptiData
end