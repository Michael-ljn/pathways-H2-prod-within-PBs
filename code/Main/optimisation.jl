
include("./main_utils.jl")

⊘(a, b) = a ./ b # written `\oslash``. Here we simply register it so the formulations in the optimisation model matches that of the paper.
∑(a) = sum(a) # written `\sum``

global Δs =zeros(4);

## Main optimisation function
    """
    ## optimisation function

    >> internal optimisation function to minimise the impact on planetary boudaries. It is used directly in the opti() function.


    ## Methods
    """
    function opti!(p, # this is the project
                    𝛚,  # the allocated safe operating space per unit of hydrogen should be a 1x10 vector
                    𝛈_electrolysis,

                    # all constrains
                    c_biomass_electricity = nothing,
                    c_gas_electricity = nothing,
                    c_gas_electricity_CC = nothing,
                    c_gas_electricity_noCC = nothing,
                    c_coal_electricity = nothing,
                    c_oil_electricity = nothing,
                    c_geothermal_electricity = nothing,
                    c_hydro_electricity = nothing,
                    c_nuclear_electricity = nothing,
                    c_wind_electricity = nothing,
                    c_solar_electricity = nothing,
                    c_solar_PV = nothing,
                    c_electricity_CSP = nothing,
                    c_coalccs = nothing,
                    c_coal = nothing,
                    c_gasccs = nothing,
                    c_gas = nothing,
                    c_biomassccs = nothing,
                    c_biomass = nothing,
                    c_electrolysis = nothing,
                    c_pem = nothing,
                    c_aec = nothing,
                    c_soec = nothing,
                    delta=nothing,
                    r_solar_wind=nothing,
                    ccs=nothing,
                    ;
                    #Constants
                    interactions=nothing,
                    result_format="impact",
                    focus=𝚲b,
                    𝚲=𝚲b,
                    )
        


        ## Stochastic run or not.

            𝐀=Tcm!(p)[:technosphere]
            𝐁=Tcm!(p)[:biosphere]
            𝐐=Characterisation!(p)
            𝐟=f(p)
            
        ## 

    
        ### setting the references flows
            𝐟[16]=ccs #Here we set what should be the necessary carbon to be captured via DAC
            𝐟[end]=1  # Here we set the production as 1kgH₂
        ## end

        ### Efficiencies
            ### FIXME: add the indices.
            𝖘ᵉ #create the set of electrical efficiency gain for technologies.
            𝛈ᵉ # corresponding vector to account for efficiency gains. 
            iᵉ # this is where the electricity is produced from choices.
            𝐀[iᵉ,𝖘ᵉ] = 𝐀[i_electicity,𝖘ᵉ] ⊘ 𝛈ᵉ #efficiency gains accounted for.

            𝖘ᵐ #create the set of materal efficiency gains for technologies.
            𝛈ᵐ # corresponding vector to account for efficiency gains. 
            iᵐ # this is where the electricity is produced from choices.
            𝐀[iᵐ,𝖘ᵐ] = 𝐀[iᵐ,𝖘ᵐ] ⊘ 𝛈ᵐ #efficiency gains accounted for.
        ## end




        model=Model(optimizer_with_attributes(CPLEX.Optimizer))
        set_silent(model)

        # Variables
            @variable(model, 𝐬[1:𝐀.n]) # 𝐬 [scale unit × kgH₂⁻¹] should be as long as the processes in the technosphere.
            @variable(model, 𝛇[1:𝐀.n] .≥ 0) # 𝛇 [scale unit × kgH₂⁻¹] is the oversupply parameter when we require more wind or solar energy than the model allows. 
        # end 

        # Expressions
            @expression(model, 𝐠, 𝐁*𝐬) # The reason why we made this intermediate step is because the processes are not uniform accross scenarios for montecarlo analysis. Hence the only common dimension is the list of elementary flows which has the same length accross all scenarios. 

            @expression(model, 𝐝, 𝐐*𝐠 ⊘ 𝛚) # 𝐝 = 𝐐*𝐠 ⊘ 𝛚 -> Direct normalised impact.   

            if !isnothing(interactions)
                @expression(model, 𝐱, 𝚪*𝐝) # 𝐱 = 𝚪𝐝 -> normalised state variables with interactions 
            else
                @expression(model, 𝐱, 𝐝) # 𝐱=𝐝 -> normalised state variables without interactions 
            end 

            # Here we define useful expressions to extract from the model. if we want for instance to track the costs or material use.

            # @expression(model, 𝐢, 𝚵*𝐬) # 𝐢 = 𝚵*𝐬 with 𝚵 elements in [$ × kgH₂⁻¹] produced. 𝐢  the total investments in [$]

            # @expression(model, 𝐦, 𝐌*𝐬) # 𝐦 = 𝐌*𝐬 with 𝐌 elements in [unit_material × kgH₂⁻¹] produced. 𝐦 in [unit_material] used
        # end 

        @objective(model, Min, 𝐱) # Multi objective optimisation.
        

        @constraint(model, 𝐀*𝐬 .== 𝐟) # Here we impose that hydrogen and some CCS if selected need to be produced
        
        # define the set 𝐬⁺ of processes involved in choices where 𝐬 cannot be negative.
        𝖘⁺= 𝖘ᵗ = vcat([s for s in values(TCM(p)[:choice_map])]...) 
        @constraint(model, 𝐬[𝖘⁺] ≥ 0)


        # now we constrain the scale of techologies involved in the choices, that's using the same set as above 𝖘⁺= 𝖘ᵗ
        𝐜ᵗ=ones(lenght(𝖘ᵗ))

        @constraint(model, 𝐬[𝖘ᵗ] ≤ 𝐜ᵗ) # 𝐜ᵗ is the scale constrain vector for each of the processes involved.



        # now we constrain the scale of techologies and we need to group technologies according to scenarios.
        𝐜ᵍ=ones(lenght(𝖘ᵍ))


        @constraint(model, ∑(𝐬[𝖘ᵍ]) ≤ 𝐜ᵍ) # 𝐜ᵍ is the scale constrain vector for group of technologies



















        #Electricity per kg of hydrogen
            # # # Electricity from biomass: SE|Electricity|+|Biomass
            j_elect_wood=getTcmKey!("electricity production, wood, future","GLO")


            @constraint(model, 𝐬[j_elect_wood] ≤ c_biomass_electricity)
                        
            ## Electricity from gas: ∑ = SE|Electricity|+|Gas 
                ## indices
                    j_elect_NGfired=getTcmKey!("electricity production, at natural gas-fired combined cycle power plant, post, pipeline 200km, storage 1000m","World")
                    j_elect_NG = getTcmKey!("electricity production, natural gas, 10MW","CH")
                ## end

            @constraint(model, 𝐬[j_elect_NGfired] + 𝐬[j_elect_NG] ≤ c_gas_electricity)

            ## indices
                j_=getTcmKey!("electricity production, at natural gas-fired combined cycle power plant, post, pipeline 200km, storage 1000m","World")
            ## end

            # SE|Electricity|Gas|+|w/ CC
            
            @constraint(model, 𝐬[] ≤ c_gas_electricity_CC)
            
            # SE|Electricity|Gas|+|w/o CC
            @constraint(model, 𝐬[getTcmKey!("electricity production, natural gas, 10MW","CH")] ≤ c_gas_electricity_noCC)

            # # Electricity from coal: ∑ = SE|Electricity|+|Coal
            @constraint(model,
            𝐬[getTcmKey!("electricity production, hard coal","RoW")]  ≤ c_coal_electricity)

            # # Electricity from oil: ∑= "SE|Electricity|Oil|w/o CC"
            @constraint(model, 𝐬[getTcmKey!("electricity production, oil","RoW")] ≤ c_oil_electricity)

            # Electricity from geothermal: ∑ = SE|Electricity|+|Geothermal
            @constraint(model, 𝐬[getTcmKey!("electricity production, deep geothermal","RoW")] ≤ c_geothermal_electricity)

            #Electricity from hydro: ∑ = SE|Electricity|+|Hydro
            @constraint(model,
            𝐬[getTcmKey!("electricity production, hydro, run-of-river","RoW")] ≤ c_hydro_electricity)

            # Electricity from nuclear: ∑ =SE|Electricity|+|Nuclear
            @constraint(model,
            𝐬[getTcmKey!("electricity production, nuclear, boiling water reactor","RoW")] +
            𝐬[getTcmKey!("electricity production, nuclear, pressure water reactor, heavy water moderated","RoW")]+ 𝐬[getTcmKey!("electricity production, nuclear, pressure water reactor","RoW")] ≤ c_nuclear_electricity)


            # #Electricity from wind: SE|Electricity|+|Wind
            @constraint(model, 𝐬[getTcmKey!("electricity production, wind, >3MW turbine, onshore","RoW")] ≤ (1+ζ[getTcmKey!("electricity production, wind, >3MW turbine, onshore","RoW")])*c_wind_electricity)

            # #Electricity from solar: ∑ = SE|Electricity|+|Solar
            @constraint(model, 𝐬[getTcmKey!("electricity production, photovoltaic, 570kWp open ground installation, multi-Si","RoW")] ≤ (1+ζ[getTcmKey!("electricity production, photovoltaic, 570kWp open ground installation, multi-Si","RoW")])*c_solar_PV)

            # here we set proportions between wind and solar.
            @constraint(model, 𝐬[getTcmKey!("electricity production, photovoltaic, 570kWp open ground installation, multi-Si","RoW")] *r_solar_wind .== 𝐬[getTcmKey!("electricity production, wind, >3MW turbine, onshore","RoW")])

            

            # # # Electricity from CSP: ∑ =  "SE|Electricity|Solar|+|CSP"
            @constraint(model, 𝐬[getTcmKey!("electricity production, solar thermal parabolic trough, 50 MW","RoW")] ≤ c_electricity_CSP)

        # Constrained supply of hydrogen per production method
            # Hydrogen from electrolysis

                @constraint(model, 𝐬[getTcmKey!(:hydrogen_PEM)] ≤ c_pem)  # PEM electrolysis
                @constraint(model, 𝐬[getTcmKey!(:hydrogen_AE)] ≤ c_aec)  # AEC electrolysis
                @constraint(model, 𝐬[getTcmKey!(:hydrogen_SOEC_steam)]+
                𝐬[getTcmKey!(:hydrogen_SOEC_elec)] ≤ c_soec) # let the model choice which one to use

                # forcing a development ratio between PEM and AEC
                # @constraint(model, 𝐬[getTcmKey!(:hydrogen_AE)]*(c_aec/c_pem) == 𝐬[getTcmKey!(:hydrogen_PEM)])

                # imposing material constraints on iridium for PEM electrolysis
                # @constraint(model, 𝐬[getTcmKey°("platinum group metal, extraction and refinery operations", "ZA")] ≤ c_Ir)#kgIR/kgH2
        
                @constraint(model, 
                𝐬[getTcmKey!(:hydrogen_PEM)]+𝐬[getTcmKey!(:hydrogen_AE)]+𝐬[getTcmKey!(:hydrogen_SOEC_steam)]+𝐬[getTcmKey!(:hydrogen_SOEC_elec)] ≤ c_electrolysis) #∑ of electrolysis ratios should be less than the total 

            # hydrogen from gas constraints
                # SE|Hydrogen|Gas|+|w/o CC
                @constraint(model, 𝐬[getTcmKey!(:SMR)] + 𝐬[getTcmKey!(:hydrogen_pyrolysis)] ≤ c_gas) 
            
                # SE|Hydrogen|Gas|+|w/ CC
                @constraint(model, 𝐬[getTcmKey!(:hydrogen_SMRccs)] ≤ c_gasccs)  # hydrogen production, steam methane reforming, with CCS

            # hydrogen from biomass constraints
                #  SE|Hydrogen|Biomass|+|w/ CC # via biogas reforming
                @constraint(model, 𝐬[getTcmKey!(:hydrogen_bSMRccs)]+𝐬[getTcmKey!(:hydrogen_BioCccs)] ≤ c_biomassccs)  # hydrogen production, steam methane reforming, from biomethane, with CC
                
                #  SE|Hydrogen|Biomass|+|w/o CC via biogas reforming
                @constraint(model, 𝐬[getTcmKey!(:hydrogen_bSMR)] ≤ c_biomass)  # hydrogen production, steam methane reforming, from biomethane

            # Hydrogen from coal constraints
            #   SE|Hydrogen|Coal|+|w/ CC
                @constraint(model, 𝐬[getTcmKey!(:hydrogen_coalccs)] ≤ c_coalccs)  # hydrogen production, coal gasification, with CCS

            #   SE|Hydrogen|Coal|+|w/o CC
                @constraint(model, 𝐬[getTcmKey!(:hydrogen_coal)] ≤ c_coal)  # hydrogen production, coal gasification

        
        if delta==1
            global Δs =zeros(A(p).n)
        end


        # RUN
        optimize!(model)
        if !is_solved_and_feasible(model)
            error("Solver did not find an optimal solution")
        end
        global Δs = value.(𝐬) # This global parameter stores the result for this given year to be used in the next loop.

        # s_res=value.(𝐬).+value.(ζ)
        if result_format=="contrib"
            return  𝚲(p)*diagm(value.(𝐬))
        # elseif result_format=="stressors"
        #         return 𝚲(p)*diagm(value.(𝐬))
        elseif result_format=="scale"
            return value.(𝐬)

        elseif result_format=="ASR"
            if !isnothing(interactions)
                return interactions*((𝚲(p)*value.(𝐬))./𝛚')
            else
                return ((𝚲(p)*value.(𝐬))./𝛚')
            end
        elseif result_format=="impact"
            return 𝚲(p)*value.(𝐬)
        elseif result_format=="oversupply"
            return Dict(
                :wind => value.(ζ)[getTcmKey!("electricity production, wind, >3MW turbine, onshore","RoW")]*c_wind_electricity, 
                :solar => value.(ζ)[getTcmKey!("electricity production, photovoltaic, 570kWp open ground installation, multi-Si","RoW")]*c_solar_PV
                )
        elseif result_format=="sensitivity" #not working
            return lp_sensitivity_report(model)
        end
    end




### Broacaster 
    """
    # Optimisation function for broadcasting accross scenarios. 

    >simplified function to call the optimisation problem and use keyword arguments. 

    >Results can be return in several format such as :ASR, :impact, :scale, :contrib.


    ## Keyword arguments: 

    >- result_format: Symbol=:ASR, :impact, :scale, :contrib
    >- interactions: Symbol=:biophysical, :full
    >- 𝛚: Symbol=:median, :upper, :lower

    >The following parameters are 6x3 matrices representing the 6 years of assessment and 3 SSP scenarios.


    >- Technological variables:
    >- 𝛈_electrolysis: Matrix of electrolysis efficiencies


    ## Constraint variables:

    - The electricity source is constrained as follows:

    >>- c_biomass_electricity: Matrix to constrain electricity from biomass
    >>- c_gas_electricity: Matrix to constrain electricity from gas
    >>- c_gas_electricity_CC: Matrix to constrain electricity from gas with CCS
    >>- c_gas_electricity_noCC: Matrix to constrain electricity from gas without CCS
    >>- c_coal_electricity: Matrix to constrain electricity from coal
    >>- c_oil_electricity: Matrix to constrain electricity from oil
    >>- c_geothermal_electricity: Matrix to constrain electricity from geothermal
    >>- c_hydro_electricity: Matrix to constrain electricity from hydro
    >>- c_nuclear_electricity: Matrix to constrain electricity from nuclear
    >>- c_wind_electricity: Matrix to constrain electricity from wind
    >>- c_solar_electricity: Matrix to constrain electricity from solar
    >>- c_solar_PV_electricity: Matrix to constrain electricity from solar PV
    >>- c_CSP_electricity: Matrix to constrain electricity from CSP

    - Hydrogen production technologies are constrained as follows:

    >>- c_coalccs: Matrix to constrain production hydrogen from coal with CCS
    >>- c_coal: Matrix to constrain production hydrogen from coal without CCS
    >>- c_gasccs: Matrix to constrain production hydrogen from gas with CCS
    >>- c_gas: Matrix to constrain production hydrogen from gas without CCS
    >>- c_biomassccs: Matrix to constrain production hydrogen from biomass with CCS
    >>- c_biomass: Matrix to constrain production hydrogen from biomass without CCS
    >>- c_electrolysis: Matrix to constrain production hydrogen from electrolysis
    >>- C_PEM: Matrix to constrain production hydrogen from PEM electrolysis
    >>- C_AEC: Matrix to constrain production hydrogen from AEC electrolysis
    >>- C_SOEC: Matrix to constrain production hydrogen from SOEC electrolysis


    ## Other constraints:

    >>- delta: a dummy parameter for the initial year of the optimisation problem.

    ## Methods
    """
    function opti(
                # all keyword arguments           
                ;result_format::Symbol=:ASR,
                interactions::Union{Symbol,Nothing}=:biophysical,
                𝛚::Symbol=:median,
                𝛈_electrolysis=𝛈_electrolysis,
                c_biomass_electricity=c_biomass_electricity,
                c_gas_electricity=c_gas_electricity,
                c_gas_electricity_CC=c_gas_electricity_CC,
                c_gas_electricity_noCC=c_gas_electricity_noCC,
                c_coal_electricity=c_coal_electricity,
                c_oil_electricity=c_oil_electricity,
                c_geothermal_electricity=c_geothermal_electricity,
                c_hydro_electricity=c_hydro_electricity,
                c_nuclear_electricity=c_nuclear_electricity,
                c_wind_electricity=c_wind_electricity,
                c_solar_electricity=c_solar_electricity,
                c_solar_PV_electricity=c_solar_PV_electricity,
                c_CSP_electricity=c_CSP_electricity,
                c_coalccs=c_coalccs,
                c_coal=c_coal,
                c_gasccs=c_gasccs,
                c_gas=c_gas,
                c_biomassccs=c_biomassccs,
                c_biomass=c_biomass,
                c_electrolysis=c_electrolysis,
                C_PEM=C_PEM,
                C_AEC=C_AEC,
                C_SOEC=C_SOEC,
                delta_slope_max=0.47,
                delta_slope_min=0.41,
                CCS=zeros(size(c_electrolysis)),
                r_solar_wind=r_solar_wind
                )

        
            if 𝛚==:median
                𝛚=𝛚_med
            elseif 𝛚==:upper
                𝛚=𝛚_upper
            elseif 𝛚==:lower
                𝛚=𝛚_lower
            end


            if interactions==:biophysical
                interaction=𝛐
            elseif interactions==:full
                interaction=𝛄
            else
                interaction=nothing
            end

            delta=zeros(6,3)
            delta[1,:]=ones(3);
            Δsmax =zeros(3)


            resultat=opti!.(𝐏,𝛚,
                            𝛈_electrolysis,
                            # all constrains
                            c_biomass_electricity,
                            c_gas_electricity,
                            c_gas_electricity_CC,
                            c_gas_electricity_noCC,
                            c_coal_electricity,
                            c_oil_electricity,
                            c_geothermal_electricity,
                            c_hydro_electricity,
                            c_nuclear_electricity,
                            c_wind_electricity,
                            c_solar_electricity,
                            c_solar_PV_electricity,
                            c_CSP_electricity,
                            c_coalccs ,
                            c_coal ,
                            c_gasccs,
                            c_gas,
                            c_biomassccs,
                            c_biomass,
                            c_electrolysis,
                            C_PEM,
                            C_AEC,
                            C_SOEC,delta,r_solar_wind,
                            CCS,
                            ;
                            delta_slope_max=delta_slope_max,
                            delta_slope_min=delta_slope_min,
                            #Constants
                            interactions= interaction,
                            result_format=String(result_format), # ASR, impact, scale, contrib, variables
                            focus=𝚲b,
                            𝚲=𝚲b)
            return resultat
    end;
