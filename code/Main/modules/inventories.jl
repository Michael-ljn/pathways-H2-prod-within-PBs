########################  LIFE CYCLE INVENTORIES ########################
module inventories
    export LCI
    using lce
    ### 1. ELECTRICITY SOURCES
    ### 1.1 Background system electricity sources 
        #biomass
        wood_elect(p)=getAct("electricity production, wood, future","GLO",project=p);

        #gas
        gas_fired(p)=getAct("electricity production, at natural gas-fired combined cycle power plant","RER",project=p);

        gas_fired_ccs_post(p)=getAct("electricity production, at natural gas-fired combined cycle power plant, post, pipeline 200km, storage 1000m","World",project=p);

        gas_turbine(p)=getAct("electricity production, natural gas, 10MW","CH",project=p)

        # Hard coal
        hard_coal(p)=getAct("electricity production, hard coal","RoW",project=p)
        hard_coal_supcrit(p)=getAct("electricity production, hard coal, supercritical","ZA",project=p);

        # Oil
        oil(p)=getAct("electricity production, oil","RoW",project=p);

        # lignite
        lignite_fired(p)=getAct("electricity production, at lignite-fired IGCC power plant","World",project=p);
        lignite(p)=getAct("electricity production, lignite","RoW",project=p);

        #peat
        peat(p)=getAct("electricity production, peat","RoW",project=p);

        #hydrogen
        hydrogen_fired(p)=getAct("electricity production, from hydrogen-fired one gigawatt gas turbine","World",project=p);

        #geothermal
        geothermal(p)=getAct("electricity production, deep geothermal","RoW",project=p);

        # hydro
        hydro(p)=getAct("electricity production, hydro, run-of-river","RoW",project=p)
        # hydro_non_alpine(p)=getAct("electricity production, hydro, reservoir, non-alpine region","RoW",project=p); #from a reservoir we ignore this one.

        ## nuclear
        nuclear_pressure(p)=getAct("electricity production, nuclear, pressure water reactor","RoW",project=p)
        nuclear_boiling(p)=getAct("electricity production, nuclear, boiling water reactor","RoW",project=p)
        nuclear_pressure_heavy(p)=getAct("electricity production, nuclear, pressure water reactor, heavy water moderated","RoW",project=p);

        # wind
        wind(p)=getAct("electricity production, wind, >3MW turbine, onshore","RoW",project=p);

        # solar
        solar_thermal(p)=getAct("electricity production, solar thermal parabolic trough, 50 MW","RoW",project=p)
        solar_pv(p)=getAct("electricity production, photovoltaic, 570kWp open ground installation, multi-Si","RoW",project=p);

    ##

    ### 1.2  Choice of electricity HV
            elecHV(p)=newChoice([
                                wood_elect(p),
                                gas_fired(p),
                                gas_fired_ccs_post(p),
                                oil(p),
                                hard_coal(p),
                                hard_coal_supcrit(p),
                                lignite_fired(p),
                                lignite(p),
                                peat(p),
                                hydrogen_fired(p),
                                geothermal(p),
                                hydro(p),
                                nuclear_pressure(p),
                                nuclear_boiling(p),
                                nuclear_pressure_heavy(p),
                                wind(p),
                                gas_turbine(p),
                                solar_thermal(p)
                                ],
                                name="electricity energy choice high voltage",
                                reference_flow="electricity",
                                label=:electricityHV,
                                stage=:Operation,
                                category=:level2,
                                unit="kilowatt hour",
                                location="World",
                                project=p)
        
    ##
    ### 1.2  Choice of electricity MV
        η_transmission=0.95; # same as in ecoinvent

        # THECHNOSPHERE FLOWS
        #-----------------------------------------------------------------------------------------  
        transmission_HV(p) = getAct("transmission network construction, electricity, high voltage","CH",project=p);

        # BIOSPHERE FLOWS
        #-----------------------------------------------------------------------------------------  
        N2O(p)=getBio("Dinitrogen monoxide","air, unspecified",project=p);
        O3(p)=getBio("Ozone","air, unspecified",project=p);

        #ACTIVITY MODEL 
        #-----------------------------------------------------------------------------------------  
        electricityHV_MV(p)=newAct!( 
                                    name="electricity voltage transformation from high to medium voltage",
                                    label=:electricityHV_MV, 
                                    category=:operation,
                                    stage=:level2,
                                    reference_flow="electricity, medium voltage",
                                    unit="kilowatt hour",
                                    location="GLO",
                                    amount=1.0*η_transmission,
                                    project=p,
                                    
                                    #TECHNOSPHERE FLOWS
                                    #******************************************************  
                                    techflows=Dict(
                                                transmission_HV(p) => 6.58209848825026e-09, #kilometer
                                                elecHV(p) => 1.0, #kilowatt hour
                                                ),
                                    # BIOSPHERE FLOWS
                                    #*********************************************************  
                                    bioflows=Dict(
                                                N2O(p) => 5e-06, #kilogram
                                                O3(p) => 4.15772755242894e-06, #kilogram
                                                ))
            # so far we have created some annonymous functions, to trigger them we need to run it like that. 
        
        
    ## 
    ### 1.3 Electricity low voltage
        solar_PV(p)=getAct("electricity production, photovoltaic, 570kWp open ground installation, multi-Si","RoW",project=p);
        
        #ACTIVITY MODEL 
        #-----------------------------------------------------------------------------------------  
        electricityMV_LV(p)=newAct!(
                                name="electricity voltage transformation from medium to low voltage",
                                label=:electricityMV_LV, 
                                category=:operation,
                                stage=:level2,
                                reference_flow="electricity, medium voltage",
                                unit="kilowatt hour",
                                location="World",
                                amount=1*η_transmission,
                                project=p, #it will be 1 unit anyways but it divides the flows
                                
                                #TECHNOSPHERE FLOWS
                                #*************************************************************************************  
                                techflows=Dict(
                                            transmission_HV(p) => 6.58209848825026e-09, #kilometer
                                            electricityHV_MV(p) => 1, #kilometer
                                            ),
                                # BIOSPHERE FLOWS
                                #*************************************************************************************  
                                bioflows=Dict(
                                            N2O(p) => 0, #kilogram
                                            ));

        elecLV(p)=newChoice([solar_PV(p),electricityMV_LV(p)],
                    name="electricity low voltage choice",
                    reference_flow="electricity, low voltage",
                    label=:electricityLV,
                    stage=:Operation,
                    category=:level2,
                    unit="kilowatt hour",
                    location="World",project=p)
    ##
    ## End

    ### 2. Carbon capture and storage
        #carbon dioxide, captured from atmosphere and stored, with a solvent-based direct air capture system, 1MtCO2, with industrial steam heat, and grid electricity - World 

        # THECHNOSPHERE FLOWS
        #-----------------------------------------------------------------------------------------  
        tap_water_6575(p) = getAct("market for tap water", "RoW",project=p);
        potassium_hydroxide_7956(p) = getAct("market for potassium hydroxide", "GLO",project=p);
        limestone_10744(p) = getAct("market for limestone, crushed, for mill", "RoW",project=p);
        limestone_residue_14224(p) = getAct("treatment of limestone residue, inert material landfill", "RoW",project=p);
        spent_solvent_mixture_21007(p) = getAct("treatment of spent solvent mixture, hazardous waste incineration", "RoW",project=p);
        direct_air_capture_system_21333(p) = getAct("direct air capture system, solvent-based, 1MtCO2", "RER",project=p);
        direct_air_capture_system_21334(p) = getAct("treatment of direct air capture system, solvent-based, 1MtCO2", "RER",project=p);
        electricity_23949(p) = getAct("market group for electricity, medium voltage", "EUR",project=p);
        heat_26334(p) = getAct("market for heat, from steam, in chemical industry", "World",project=p);
        carbon_dioxide_26945(p) = getAct("carbon dioxide compression, transport and storage", "World",project=p);

        # BIOSPHERE FLOWS
        #-----------------------------------------------------------------------------------------  
        # Carbon_dioxide_in_air_2747(p) = getBio("Carbon dioxide, in air", "natural resource, in air",project=p);
        Carbon_dioxide_in_air_2747(p) = getBio("Carbon dioxide, non-fossil", "air, unspecified",project=p);
        # REPLACE THE CATEGORY AND STAGE 
        #-----------------------------------------------------------------------------------------  
        DAC_steam(p)=newAct!(
                                    name="carbon dioxide, captured from atmosphere and stored, with a solvent-based direct air capture system, 1MtCO2, with industrial steam heat, and grid electricity",
                                    label=:DAC_steam,
                                    category=:copied_default,
                                    stage=:copied_default,
                                    reference_flow="carbon dioxide, captured from atmosphere",
                                    unit="kilogram",
                                    location="World",
                                    amount=1.0,
                                    project=p,
                                    
                                    #TECHNOSPHERE FLOWS
                                    #*************************************************************************************  
                                    techflows=Dict(
                                                tap_water_6575(p) => 3.437, #kilogram
                                                potassium_hydroxide_7956(p) => 0.004, #kilogram
                                                limestone_10744(p) => 0.0035, #kilogram
                                                limestone_residue_14224(p) => -0.0035, #kilogram
                                                spent_solvent_mixture_21007(p) => -0.004, #kilogram
                                                direct_air_capture_system_21333(p) => 5.0e-11, #unit
                                                direct_air_capture_system_21334(p) => -5.0e-11, #unit
                                                elecLV(p) => 0.345, #kilowatt hour
                                                heat_26334(p) => 6.28, #megajoule
                                                carbon_dioxide_26945(p) => 1.0, #kilogram
                                                ),
                                    # BIOSPHERE FLOWS
                                    #*************************************************************************************  
                                    bioflows=Dict(
                                                Carbon_dioxide_in_air_2747(p) => -1.0, #kilogram
                                                                                            ))
                        ;
        #Carbon dioxide, captured from atmosphere and stored, with a solvent-based direct air capture system, 1MtCO2, with heat pump heat, and grid electricity - World 

        # THECHNOSPHERE FLOWS
        #-----------------------------------------------------------------------------------------  
        tap_water_6575(p) = getAct("market for tap water", "RoW",project=p);
        potassium_hydroxide_7956(p) = getAct("market for potassium hydroxide", "GLO",project=p);
        limestone_10744(p) = getAct("market for limestone, crushed, for mill", "RoW",project=p);
        limestone_residue_14224(p) = getAct("treatment of limestone residue, inert material landfill", "RoW",project=p);
        electricity_20072(p) = getAct("market group for electricity, medium voltage", "GLO",project=p);
        spent_solvent_mixture_21007(p) = getAct("treatment of spent solvent mixture, hazardous waste incineration", "RoW",project=p);
        direct_air_capture_system_21333(p) = getAct("direct air capture system, solvent-based, 1MtCO2", "RER",project=p);
        direct_air_capture_system_21334(p) = getAct("treatment of direct air capture system, solvent-based, 1MtCO2", "RER",project=p);
        electricity_23949(p) = getAct("market group for electricity, medium voltage", "EUR",project=p);
        carbon_dioxide_26945(p) = getAct("carbon dioxide compression, transport and storage", "World",project=p);

        # BIOSPHERE FLOWS
        #-----------------------------------------------------------------------------------------  
        Carbon_dioxide_in_air_2747(p) = getBio("Carbon dioxide, non-fossil", "air, unspecified",project=p);
        #getBio("Carbon dioxide, in air", "natural resource, in air",project=p);

        # REPLACE THE CATEGORY AND STAGE 
        #-----------------------------------------------------------------------------------------  
        DAC_heatpump(p)=newAct!(
                                    name="carbon dioxide, captured from atmosphere and stored, with a solvent-based direct air capture system, 1MtCO2, with heat pump heat, and grid electricity",
                                    label=:DAC_heatpump,
                                    category=:operation,
                                    stage=:level1,
                                    reference_flow="carbon dioxide, captured from atmosphere",
                                    unit="kilogram",
                                    location="World",
                                    amount=1.0,
                                    project=p,
                                    
                                    #TECHNOSPHERE FLOWS
                                    #*************************************************************************************  
                                    techflows=Dict(
                                                tap_water_6575(p) => 3.437, #kilogram
                                                potassium_hydroxide_7956(p) => 0.004, #kilogram
                                                limestone_10744(p) => 0.0035, #kilogram
                                                limestone_residue_14224(p) => -0.0035, #kilogram
                                                # electricity_20072(p) => 0.6015325670498085, #kilowatt hour
                                                spent_solvent_mixture_21007(p) => -0.004, #kilogram
                                                direct_air_capture_system_21333(p) => 5.0e-11, #unit
                                                direct_air_capture_system_21334(p) => -5.0e-11, #unit
                                                elecLV(p) => 0.345 + 0.6015325670498085, #kilowatt hour
                                                carbon_dioxide_26945(p) => 1.0, #kilogram
                            ),
                                    # BIOSPHERE FLOWS
                                    #*************************************************************************************  
                                    bioflows=Dict(
                                                Carbon_dioxide_in_air_2747(p) => -1.0, #kilogram # not characterised so we
                                                                                            ))
                                                                                                ;
        DAC(p)=newChoice([DAC_heatpump(p),DAC_steam(p)],
                            name="Choice of carbon removal via direct air capture",
                            reference_flow="carbon dioxide, captured from atmosphere",
                            label=:DAC,
                            stage=:operation,
                            category=:level0,
                            unit="kg",
                            location="World",
                            project=p)
    ## End

    ### 3. Hydrogen production
    ### 3.1 Steam methane reforming

        ### 3.1.1 from natural gas
            # THECHNOSPHERE FLOWS
            #-----------------------------------------------------------------------------------------  
            molybdenum_trioxide_443(p) = getAct("market for molybdenum trioxide", "GLO",project=p);
            chromium_oxide_458(p) = getAct("market for chromium oxide, flakes", "GLO",project=p);
            quicklime_2029(p) = getAct("market for quicklime, milled, packed", "RoW",project=p);
            chemical_factory_2368(p) = getAct("chemical factory construction, organics", "RoW",project=p);
            copper_oxide_2580(p) = getAct("market for copper oxide", "GLO",project=p);
            silica_sand_4471(p) = getAct("market for silica sand", "GLO",project=p);
            electricity_5180(p) = getAct("market group for electricity, high voltage", "RER",project=p);
            nickel_5598(p) = getAct("market for nickel, class 1", "GLO",project=p);
            natural_gas_11706(p) = getAct("market for natural gas, high pressure", "RoW",project=p);
            water_12449(p) = getAct("market for water, deionised", "RoW",project=p);
            zinc_oxide_13058(p) = getAct("market for zinc oxide", "GLO",project=p);
            liquid_storage_tank_14447(p) = getAct("market for liquid storage tank, chemicals, organics", "GLO",project=p);
            portafer_15775(p) = getAct("market for portafer", "GLO",project=p);
            aluminium_oxide_16596(p) = getAct("market for aluminium oxide, metallurgical", "RoW",project=p);
            zeolite_17195(p) = getAct("market for zeolite, powder", "GLO",project=p);
            magnesium_oxide_19528(p) = getAct("market for magnesium oxide", "GLO",project=p);

            # BIOSPHERE FLOWS
            #-----------------------------------------------------------------------------------------  
            Particulate_Matter_um_127(p) = getBio("Particulate Matter, < 2.5 um", "air, unspecified",project=p);
            Carbon_monoxide_fossil_153(p) = getBio("Carbon monoxide, fossil", "air, unspecified",project=p);
            Sulfur_dioxide_507(p) = getBio("Sulfur dioxide", "air, unspecified",project=p);
            Water_773(p) = getBio("Water", "water, unspecified",project=p);
            Pentane_942(p) = getBio("Pentane", "air, unspecified",project=p);
            Acetaldehyde_1042(p) = getBio("Acetaldehyde", "air, unspecified",project=p);
            Propionic_acid_1175(p) = getBio("Propionic acid", "air, unspecified",project=p);
            Carbon_dioxide_non_fossil_1252(p) = getBio("Carbon dioxide, non-fossil", "air, unspecified",project=p);
            Carbon_dioxide_fossil_1780(p) = getBio("Carbon dioxide, fossil", "air, unspecified",project=p);
            Nitrogen_oxides_1890(p) = getBio("Nitrogen oxides", "air, unspecified",project=p);
            Benzo_a_pyrene_2768(p) = getBio("Benzo(a)pyrene", "air, unspecified",project=p);
            Mercury_II_2851(p) = getBio("Mercury II", "air, unspecified",project=p);
            Water_cooling_unspecified_natural_origin_2946(p) = getBio("Water, cooling, unspecified natural origin", "natural resource, in water",project=p);
            Acetic_acid_3353(p) = getBio("Acetic acid", "air, unspecified",project=p);
            Toluene_3473(p) = getBio("Toluene", "air, unspecified",project=p);
            PAH_polycyclic_aromatic_hydrocarbons_3573(p) = getBio("PAH, polycyclic aromatic hydrocarbons", "air, unspecified",project=p);
            Butane_3666(p) = getBio("Butane", "air, unspecified",project=p);
            Formaldehyde_3857(p) = getBio("Formaldehyde", "air, unspecified",project=p);
            Propane_4257(p) = getBio("Propane", "air, unspecified",project=p);
            Methane_fossil_4384(p) = getBio("Methane, fossil", "air, unspecified",project=p);
            Dinitrogen_monoxide_4391(p) = getBio("Dinitrogen monoxide", "air, unspecified",project=p);
            Water_4539(p) = getBio("Water", "air, unspecified",project=p);
            Benzene_4564(p) = getBio("Benzene", "air, unspecified",project=p);
            #-----------------------------------------------------------------------------------------  
            hydrogen_SMR(p)=newAct!(
                            name="hydrogen production, steam methane reforming",
                            label=:SMR,
                            category=:operation,
                            stage=:level1,
                            reference_flow="hydrogen, gaseous, low pressure",
                            unit="kilogram",
                            location="World",
                            amount=1.0,
                            project=p,
                            #TECHNOSPHERE FLOWS
                            #*************************************************************************************  
                                techflows=Dict(
                                                molybdenum_trioxide_443(p) => 1.668e-5, #kilogram
                                                chromium_oxide_458(p) => 3.6e-5, #kilogram
                                                quicklime_2029(p) => 4.8e-5, #kilogram
                                                chemical_factory_2368(p) => 5.348319914762801e-10, #unit
                                                copper_oxide_2580(p) => 0.00036239999999999997, #kilogram
                                                # elecLV(p)=> 0, #kWh
                                                silica_sand_4471(p) => 1.1591999999999998e-5, #kilogram
                                                nickel_5598(p) => 0.00020292014459767036, #kilogram
                                                natural_gas_11706(p) => 4.369568777236091, #cubic meter
                                                water_12449(p) => 7.5384135551021, #kilogram
                                                zinc_oxide_13058(p) => 0.00037140000000000003, #kilogram
                                                liquid_storage_tank_14447(p) => 2.54628e-9, #unit
                                                portafer_15775(p) => 0.00031235999999999997, #kilogram
                                                aluminium_oxide_16596(p) => 0.0005327279999999999, #kilogram
                                                zeolite_17195(p) => 0.0008829015460672572, #kilogram
                                                magnesium_oxide_19528(p) => 2.796e-5, #kilogram
                                ),
                                # BIOSPHERE FLOWS
                                #*************************************************************************************  
                                bioflows=Dict(
                                                Particulate_Matter_um_127(p) => 6.135601701471486e-6, #kilogram
                                                Carbon_monoxide_fossil_153(p) => 6.44219235315761e-5, #kilogram
                                                Sulfur_dioxide_507(p) => 1.6872686102061067e-5, #kilogram
                                                Water_773(p) => 0.3712966050811322, #cubic meter
                                                Pentane_942(p) => 3.681419308079029e-5, #kilogram
                                                Acetaldehyde_1042(p) => 3.067655132745398e-8, #kilogram
                                                Propionic_acid_1175(p) => 6.135601701471484e-7, #kilogram
                                                Carbon_dioxide_non_fossil_1252(p) => 0.03519331946352898, #kilogram
                                                Carbon_dioxide_fossil_1780(p) => 8.887100467008121, #kilogram
                                                Nitrogen_oxides_1890(p) => 0.0005491236748165379, #kilogram
                                                Benzo_a_pyrene_2768(p) => 3.067655132745397e-10, #kilogram
                                                Mercury_II_2851(p) => 9.203256834216884e-10, #kilogram
                                                Water_cooling_unspecified_natural_origin_2946(p) => 0.38038158908113223, #cubic meter
                                                Acetic_acid_3353(p) => 4.601482699118097e-6, #kilogram
                                                Toluene_3473(p) => 6.135601701471486e-6, #kilogram
                                                PAH_polycyclic_aromatic_hydrocarbons_3573(p) => 3.0676551327453975e-7, #kilogram
                                                Butane_3666(p) => 2.1474168801179165e-5, #kilogram
                                                Formaldehyde_3857(p) => 3.067655132745398e-6, #kilogram
                                                Propane_4257(p) => 6.135601701471486e-6, #kilogram
                                                Methane_fossil_4384(p) => 6.135601701471486e-5, #kilogram
                                                Dinitrogen_monoxide_4391(p) => 3.067655132745398e-6, #kilogram
                                                Water_4539(p) => 0.009084983999999999, #cubic meter
                                                Benzene_4564(p) => 1.2270911966962279e-5, #kilogram
                                                ))
                                                ;
                                                
        ## end
        
        ### 3.1.2 from methane with CCS
            # THECHNOSPHERE FLOWS
            #-----------------------------------------------------------------------------------------  
            molybdenum_trioxide_443(p) = getAct("market for molybdenum trioxide", "GLO",project=p);
            chromium_oxide_458(p) = getAct("market for chromium oxide, flakes", "GLO",project=p);
            quicklime_2029(p) = getAct("market for quicklime, milled, packed", "RoW",project=p);
            chemical_factory_2368(p) = getAct("chemical factory construction, organics", "RoW",project=p);
            copper_oxide_2580(p) = getAct("market for copper oxide", "GLO",project=p);
            silica_sand_4471(p) = getAct("market for silica sand", "GLO",project=p);
            electricity_5180(p) = getAct("market group for electricity, high voltage", "RER",project=p);
            nickel_5598(p) = getAct("market for nickel, class 1", "GLO",project=p);
            natural_gas_11706(p) = getAct("market for natural gas, high pressure", "RoW",project=p);
            water_12449(p) = getAct("market for water, deionised", "RoW",project=p);
            zinc_oxide_13058(p) = getAct("market for zinc oxide", "GLO",project=p);
            diethanolamine_13356(p) = getAct("market for diethanolamine", "GLO",project=p);

            portafer_15775(p) = getAct("market for portafer", "GLO",project=p);
            aluminium_oxide_16596(p) = getAct("market for aluminium oxide, metallurgical", "RoW",project=p);
            zeolite_17195(p) = getAct("market for zeolite, powder", "GLO",project=p);
            magnesium_oxide_19528(p) = getAct("market for magnesium oxide", "GLO",project=p);
            carbon_dioxide_21240(p) = getAct("carbon dioxide, captured at hydrogen production plant, pre, pipeline 200km, storage 1000m", "RER",project=p);

            # BIOSPHERE FLOWS
            #-----------------------------------------------------------------------------------------  
            Particulate_Matter_um_127(p) = getBio("Particulate Matter, < 2.5 um", "air, unspecified",project=p);
            Carbon_monoxide_fossil_153(p) = getBio("Carbon monoxide, fossil", "air, unspecified",project=p);
            Sulfur_dioxide_507(p) = getBio("Sulfur dioxide", "air, unspecified",project=p);
            Water_773(p) = getBio("Water", "water, unspecified",project=p);
            Pentane_942(p) = getBio("Pentane", "air, unspecified",project=p);
            Acetaldehyde_1042(p) = getBio("Acetaldehyde", "air, unspecified",project=p);
            Propionic_acid_1175(p) = getBio("Propionic acid", "air, unspecified",project=p);
            Carbon_dioxide_non_fossil_1252(p) = getBio("Carbon dioxide, non-fossil", "air, unspecified",project=p);
            Carbon_dioxide_fossil_1780(p) = getBio("Carbon dioxide, fossil", "air, unspecified",project=p);
            Nitrogen_oxides_1890(p) = getBio("Nitrogen oxides", "air, unspecified",project=p);
            Benzo_a_pyrene_2768(p) = getBio("Benzo(a)pyrene", "air, unspecified",project=p);
            Mercury_II_2851(p) = getBio("Mercury II", "air, unspecified",project=p);
            Water_cooling_unspecified_natural_origin_2946(p) = getBio("Water, cooling, unspecified natural origin", "natural resource, in water",project=p);
            Acetic_acid_3353(p) = getBio("Acetic acid", "air, unspecified",project=p);
            Toluene_3473(p) = getBio("Toluene", "air, unspecified",project=p);
            PAH_polycyclic_aromatic_hydrocarbons_3573(p) = getBio("PAH, polycyclic aromatic hydrocarbons", "air, unspecified",project=p);
            Butane_3666(p) = getBio("Butane", "air, unspecified",project=p);
            Formaldehyde_3857(p) = getBio("Formaldehyde", "air, unspecified",project=p);
            Propane_4257(p) = getBio("Propane", "air, unspecified",project=p);
            Methane_fossil_4384(p) = getBio("Methane, fossil", "air, unspecified",project=p);
            Dinitrogen_monoxide_4391(p) = getBio("Dinitrogen monoxide", "air, unspecified",project=p);
            Water_4539(p) = getBio("Water", "air, unspecified",project=p);
            Benzene_4564(p) = getBio("Benzene", "air, unspecified",project=p);
            #-----------------------------------------------------------------------------------------  
            hydrogen_SMRccs(p)=newAct!(
                            name="hydrogen production, steam methane reforming, with CCS",
                            label=:hydrogen_SMRccs,
                            category=:operation,
                            stage=:level1,
                            reference_flow="hydrogen, gaseous, low pressure",
                            unit="kilogram",
                            location="World",
                            amount=1.0,
                            project=p,
                            
                            #TECHNOSPHERE FLOWS
                            #*************************************************************************************  
                            techflows=Dict(
                                        molybdenum_trioxide_443(p) => 1.668e-5, #kilogram
                                        chromium_oxide_458(p) => 3.6e-5, #kilogram
                                        quicklime_2029(p) => 4.8e-5, #kilogram
                                        chemical_factory_2368(p) => 5.347707144163827e-10, #unit
                                        copper_oxide_2580(p) => 0.00036239999999999997, #kilogram
                                        silica_sand_4471(p) => 1.1591999999999998e-5, #kilogram
                                        # electricity_5180(p) => 0.0, #kilowatt hour
                                        elecLV(p)=> 0, #kWh
                                        nickel_5598(p) => 0.00020292014459767036, #kilogram
                                        natural_gas_11706(p) => 4.30116813081211, #cubic meter
                                        water_12449(p) => 7.537549859911257, #kilogram
                                        zinc_oxide_13058(p) => 0.00037140000000000003, #kilogram
                                        diethanolamine_13356(p) => 0.0002094796786665977, #kilogram
                                        liquid_storage_tank_14447(p) => 2.54628e-9, #unit
                                        portafer_15775(p) => 0.00031235999999999997, #kilogram
                                        aluminium_oxide_16596(p) => 0.0005327279999999999, #kilogram
                                        zeolite_17195(p) => 0.0008829015460672572, #kilogram
                                        magnesium_oxide_19528(p) => 2.796e-5, #kilogram
                                        carbon_dioxide_21240(p) => 6.161167019605815, #kilogram
                                        ),
                                            # BIOSPHERE FLOWS
                            #*************************************************************************************  
                            bioflows=Dict(
                                        Particulate_Matter_um_127(p) => 5.606868388943634e-6, #kilogram
                                        Carbon_monoxide_fossil_153(p) => 5.887038699358714e-5, #kilogram
                                        Sulfur_dioxide_507(p) => 1.541868832840411e-5, #kilogram
                                        Water_773(p) => 0.3693603187961878, #cubic meter
                                        Pentane_942(p) => 3.36417429768375e-5, #kilogram
                                        Acetaldehyde_1042(p) => 2.803301033677894e-8, #kilogram
                                        Propionic_acid_1175(p) => 5.606868388943633e-7, #kilogram
                                        Carbon_dioxide_non_fossil_1252(p) => 0.03464240793796794, #kilogram
                                        Carbon_dioxide_fossil_1780(p) => 2.575816265531609, #kilogram
                                        Nitrogen_oxides_1890(p) => 0.000501803135821384, #kilogram
                                        Benzo_a_pyrene_2768(p) => 2.8033010336778933e-10, #kilogram
                                        Mercury_II_2851(p) => 8.410169422621528e-10, #kilogram
                                        Water_cooling_unspecified_natural_origin_2946(p) => 0.3803380077961878, #cubic meter
                                        Acetic_acid_3353(p) => 4.20495155051684e-6, #kilogram
                                        Toluene_3473(p) => 5.606868388943634e-6, #kilogram
                                        PAH_polycyclic_aromatic_hydrocarbons_3573(p) => 2.8033010336778935e-7, #kilogram
                                        Butane_3666(p) => 1.962363987892095e-5, #kilogram
                                        Formaldehyde_3857(p) => 2.8033010336778938e-6, #kilogram
                                        Propane_4257(p) => 5.606868388943634e-6, #kilogram
                                        Methane_fossil_4384(p) => 5.6068683889436346e-5, #kilogram
                                        Dinitrogen_monoxide_4391(p) => 2.8033010336778938e-6, #kilogram
                                        Water_4539(p) => 0.010977689, #cubic meter
                                        Benzene_4564(p) => 1.1213470456299422e-5, #kilogram
                                        ));
                            
                
        ## end
        
        ### 3.1.3 from biomethane
            # THECHNOSPHERE FLOWS
            #-----------------------------------------------------------------------------------------  
            molybdenum_trioxide_443(p) = getAct("market for molybdenum trioxide", "GLO",project=p);
            chromium_oxide_458(p) = getAct("market for chromium oxide, flakes", "GLO",project=p);
            quicklime_2029(p) = getAct("market for quicklime, milled, packed", "RoW",project=p);
            chemical_factory_2368(p) = getAct("chemical factory construction, organics", "RoW",project=p);
            copper_oxide_2580(p) = getAct("market for copper oxide", "GLO",project=p);
            silica_sand_4471(p) = getAct("market for silica sand", "GLO",project=p);
            electricity_5180(p) = getAct("market group for electricity, high voltage", "RER",project=p);
            nickel_5598(p) = getAct("market for nickel, class 1", "GLO",project=p);
            water_12449(p) = getAct("market for water, deionised", "RoW",project=p);
            zinc_oxide_13058(p) = getAct("market for zinc oxide", "GLO",project=p);

            portafer_15775(p) = getAct("market for portafer", "GLO",project=p);
            aluminium_oxide_16596(p) = getAct("market for aluminium oxide, metallurgical", "RoW",project=p);
            zeolite_17195(p) = getAct("market for zeolite, powder", "GLO",project=p);
            magnesium_oxide_19528(p) = getAct("market for magnesium oxide", "GLO",project=p);
            biomethane_25000(p) = getAct("biomethane production, from biogas upgrading, using amine scrubbing", "World",project=p);

            # BIOSPHERE FLOWS
            #-----------------------------------------------------------------------------------------  
            Particulate_Matter_um_127(p) = getBio("Particulate Matter, < 2.5 um", "air, unspecified",project=p);
            Carbon_monoxide_fossil_153(p) = getBio("Carbon monoxide, fossil", "air, unspecified",project=p);
            Sulfur_dioxide_507(p) = getBio("Sulfur dioxide", "air, unspecified",project=p);
            Water_773(p) = getBio("Water", "water, unspecified",project=p);
            Pentane_942(p) = getBio("Pentane", "air, unspecified",project=p);
            Acetaldehyde_1042(p) = getBio("Acetaldehyde", "air, unspecified",project=p);
            Propionic_acid_1175(p) = getBio("Propionic acid", "air, unspecified",project=p);
            Carbon_dioxide_non_fossil_1252(p) = getBio("Carbon dioxide, non-fossil", "air, unspecified",project=p);
            Nitrogen_oxides_1890(p) = getBio("Nitrogen oxides", "air, unspecified",project=p);
            Benzo_a_pyrene_2768(p) = getBio("Benzo(a)pyrene", "air, unspecified",project=p);
            Mercury_II_2851(p) = getBio("Mercury II", "air, unspecified",project=p);
            Water_cooling_unspecified_natural_origin_2946(p) = getBio("Water, cooling, unspecified natural origin", "natural resource, in water",project=p);
            Acetic_acid_3353(p) = getBio("Acetic acid", "air, unspecified",project=p);
            Toluene_3473(p) = getBio("Toluene", "air, unspecified",project=p);
            PAH_polycyclic_aromatic_hydrocarbons_3573(p) = getBio("PAH, polycyclic aromatic hydrocarbons", "air, unspecified",project=p);
            Butane_3666(p) = getBio("Butane", "air, unspecified",project=p);
            Formaldehyde_3857(p) = getBio("Formaldehyde", "air, unspecified",project=p);
            Propane_4257(p) = getBio("Propane", "air, unspecified",project=p);
            Methane_fossil_4384(p) = getBio("Methane, fossil", "air, unspecified",project=p);
            Dinitrogen_monoxide_4391(p) = getBio("Dinitrogen monoxide", "air, unspecified",project=p);
            Water_4539(p) = getBio("Water", "air, unspecified",project=p);
            Benzene_4564(p) = getBio("Benzene", "air, unspecified",project=p);
            #-----------------------------------------------------------------------------------------  
            hydrogen_bSMR(p)=newAct!(
                        name="hydrogen production, steam methane reforming, from biomethane",
                        label=:hydrogen_bSMR,
                        category=:operation,
                        stage=:level1,
                        reference_flow="hydrogen, gaseous, low pressure",
                        unit="kilogram",
                        location="World",
                        amount=1.0,
                        project=p,
                        
                        #TECHNOSPHERE FLOWS
                        #*************************************************************************************  
                        techflows=Dict(
                                        molybdenum_trioxide_443(p) => 1.668e-5, #kilogram
                                        chromium_oxide_458(p) => 3.6e-5, #kilogram
                                        quicklime_2029(p) => 4.8e-5, #kilogram
                                        chemical_factory_2368(p) => 5.348319914762801e-10, #unit
                                        copper_oxide_2580(p) => 0.00036239999999999997, #kilogram
                                        silica_sand_4471(p) => 1.1591999999999998e-5, #kilogram
                                        # electricity_5180(p) => 0.0, #kilowatt hour
                                        elecLV(p)=> 0, #kWh
                                        nickel_5598(p) => 0.00020292014459767033, #kilogram
                                        water_12449(p) => 7.5384135551021, #kilogram
                                        zinc_oxide_13058(p) => 0.00037140000000000003, #kilogram
                                        liquid_storage_tank_14447(p) => 2.54628e-9, #unit
                                        portafer_15775(p) => 0.00031235999999999997, #kilogram
                                        aluminium_oxide_16596(p) => 0.0005327279999999999, #kilogram
                                        zeolite_17195(p) => 0.0008829015460672572, #kilogram
                                        magnesium_oxide_19528(p) => 2.796e-5, #kilogram
                                        biomethane_25000(p) => 3.3088031787310634, #kilogram
                                        ),
                        # BIOSPHERE FLOWS
                        #*************************************************************************************  
                        bioflows=Dict(
                                        Particulate_Matter_um_127(p) => 6.342889789140465e-6, #kilogram
                                        Carbon_monoxide_fossil_153(p) => 6.65983844530233e-5, #kilogram
                                        Sulfur_dioxide_507(p) => 1.7442720958641864e-5, #kilogram
                                        Water_773(p) => 0.37128954313377893, #cubic meter
                                        Pentane_942(p) => 3.80579412988279e-5, #kilogram
                                        Acetaldehyde_1042(p) => 3.1712942535739586e-8, #kilogram
                                        Propionic_acid_1175(p) => 6.342889789140465e-7, #kilogram
                                        Carbon_dioxide_non_fossil_1252(p) => 8.768328423637318, #kilogram
                                        Nitrogen_oxides_1890(p) => 0.0005676755303613958, #kilogram
                                        Benzo_a_pyrene_2768(p) => 3.1712942535739584e-10, #kilogram
                                        Mercury_II_2851(p) => 9.514184042714423e-10, #kilogram
                                        Water_cooling_unspecified_natural_origin_2946(p) => 0.38037452713377895, #cubic meter
                                        Acetic_acid_3353(p) => 4.756941380360937e-6, #kilogram
                                        Toluene_3473(p) => 6.342889789140465e-6, #kilogram
                                        PAH_polycyclic_aromatic_hydrocarbons_3573(p) => 3.171294253573958e-7, #kilogram
                                        Butane_3666(p) => 2.2199662339002805e-5, #kilogram
                                        Formaldehyde_3857(p) => 3.1712942535739587e-6, #kilogram
                                        Propane_4257(p) => 6.342889789140465e-6, #kilogram
                                        Methane_fossil_4384(p) => 6.342889789140466e-5, #kilogram
                                        Dinitrogen_monoxide_4391(p) => 3.1712942535739587e-6, #kilogram
                                        Water_4539(p) => 0.009084983999999999, #cubic meter
                                        Benzene_4564(p) => 1.268547829628838e-5, #kilogram
                        ));
                        
        ## end

        ### 3.1.4 from biomethane with CCS
            # THECHNOSPHERE FLOWS
            #-----------------------------------------------------------------------------------------  
            molybdenum_trioxide_443(p) = getAct("market for molybdenum trioxide", "GLO",project=p);
            chromium_oxide_458(p) = getAct("market for chromium oxide, flakes", "GLO",project=p);
            quicklime_2029(p) = getAct("market for quicklime, milled, packed", "RoW",project=p);
            chemical_factory_2368(p) = getAct("chemical factory construction, organics", "RoW",project=p);
            copper_oxide_2580(p) = getAct("market for copper oxide", "GLO",project=p);
            silica_sand_4471(p) = getAct("market for silica sand", "GLO",project=p);
            electricity_5180(p) = getAct("market group for electricity, high voltage", "RER",project=p);
            nickel_5598(p) = getAct("market for nickel, class 1", "GLO",project=p);
            water_12449(p) = getAct("market for water, deionised", "RoW",project=p);
            zinc_oxide_13058(p) = getAct("market for zinc oxide", "GLO",project=p);
            diethanolamine_13356(p) = getAct("market for diethanolamine", "GLO",project=p);

            portafer_15775(p) = getAct("market for portafer", "GLO",project=p);
            aluminium_oxide_16596(p) = getAct("market for aluminium oxide, metallurgical", "RoW",project=p);
            zeolite_17195(p) = getAct("market for zeolite, powder", "GLO",project=p);
            magnesium_oxide_19528(p) = getAct("market for magnesium oxide", "GLO",project=p);
            carbon_dioxide_21240(p) = getAct("carbon dioxide, captured at hydrogen production plant, pre, pipeline 200km, storage 1000m", "RER",project=p);
            biomethane_25000(p) = getAct("biomethane production, from biogas upgrading, using amine scrubbing", "World",project=p);

            # BIOSPHERE FLOWS
            #-----------------------------------------------------------------------------------------  
            Particulate_Matter_um_127(p) = getBio("Particulate Matter, < 2.5 um", "air, unspecified",project=p);
            Carbon_monoxide_fossil_153(p) = getBio("Carbon monoxide, fossil", "air, unspecified",project=p);
            Sulfur_dioxide_507(p) = getBio("Sulfur dioxide", "air, unspecified",project=p);
            Water_773(p) = getBio("Water", "water, unspecified",project=p);
            Pentane_942(p) = getBio("Pentane", "air, unspecified",project=p);
            Acetaldehyde_1042(p) = getBio("Acetaldehyde", "air, unspecified",project=p);
            Propionic_acid_1175(p) = getBio("Propionic acid", "air, unspecified",project=p);
            Carbon_dioxide_non_fossil_1252(p) = getBio("Carbon dioxide, non-fossil", "air, unspecified",project=p);
            Nitrogen_oxides_1890(p) = getBio("Nitrogen oxides", "air, unspecified",project=p);
            Benzo_a_pyrene_2768(p) = getBio("Benzo(a)pyrene", "air, unspecified",project=p);
            Mercury_II_2851(p) = getBio("Mercury II", "air, unspecified",project=p);
            Water_cooling_unspecified_natural_origin_2946(p) = getBio("Water, cooling, unspecified natural origin", "natural resource, in water",project=p);
            Acetic_acid_3353(p) = getBio("Acetic acid", "air, unspecified",project=p);
            Toluene_3473(p) = getBio("Toluene", "air, unspecified",project=p);
            PAH_polycyclic_aromatic_hydrocarbons_3573(p) = getBio("PAH, polycyclic aromatic hydrocarbons", "air, unspecified",project=p);
            Butane_3666(p) = getBio("Butane", "air, unspecified",project=p);
            Formaldehyde_3857(p) = getBio("Formaldehyde", "air, unspecified",project=p);
            Propane_4257(p) = getBio("Propane", "air, unspecified",project=p);
            Methane_fossil_4384(p) = getBio("Methane, fossil", "air, unspecified",project=p);
            Dinitrogen_monoxide_4391(p) = getBio("Dinitrogen monoxide", "air, unspecified",project=p);
            Water_4539(p) = getBio("Water", "air, unspecified",project=p);
            Benzene_4564(p) = getBio("Benzene", "air, unspecified",project=p);
            #-----------------------------------------------------------------------------------------  
            hydrogen_bSMRccs(p)=newAct!(
                            name="hydrogen production, steam methane reforming, from biomethane, with CCS",
                            label=:hydrogen_bSMRccs,
                            category=:operation,
                            stage=:level1,
                            reference_flow="hydrogen, gaseous, low pressure",
                            unit="kilogram",
                            location="World",
                            amount=1.0,
                            project=p,
                            
                            #TECHNOSPHERE FLOWS
                            #*************************************************************************************  
                            techflows=Dict(
                            molybdenum_trioxide_443(p) => 1.668e-5, #kilogram
                            chromium_oxide_458(p) => 3.6e-5, #kilogram
                            quicklime_2029(p) => 4.8e-5, #kilogram
                            chemical_factory_2368(p) => 5.348339353784591e-10, #unit
                            copper_oxide_2580(p) => 0.00036239999999999997, #kilogram
                            silica_sand_4471(p) => 1.1591999999999998e-5, #kilogram
                            # electricity_5180(p) => 0.0, #kilowatt hour
                            elecLV(p)=> 0, #kWh
                            nickel_5598(p) => 0.00020292014459767036, #kilogram
                            water_12449(p) => 7.5384409542457, #kilogram
                            zinc_oxide_13058(p) => 0.00037140000000000003, #kilogram
                            diethanolamine_13356(p) => 0.00020908949384107795, #kilogram
                            liquid_storage_tank_14447(p) => 2.54628e-9, #unit
                            portafer_15775(p) => 0.00031235999999999997, #kilogram
                            aluminium_oxide_16596(p) => 0.0005327279999999999, #kilogram
                            zeolite_17195(p) => 0.0008829015460672572, #kilogram
                            magnesium_oxide_19528(p) => 2.796e-5, #kilogram
                            carbon_dioxide_21240(p) => 6.149690995325822, #kilogram
                            biomethane_25000(p) => 3.2430526231187016, #kilogram
                            ),
                                            # BIOSPHERE FLOWS
                            #*************************************************************************************  
                            bioflows=Dict(
                            Particulate_Matter_um_127(p) => 5.718117856586435e-6, #kilogram
                            Carbon_monoxide_fossil_153(p) => 6.0038472056164506e-5, #kilogram
                            Sulfur_dioxide_507(p) => 1.5724620401228882e-5, #kilogram
                            Water_773(p) => 0.3693982206443318, #cubic meter
                            Pentane_942(p) => 3.430925035120878e-5, #kilogram
                            Acetaldehyde_1042(p) => 2.858923125370675e-8, #kilogram
                            Propionic_acid_1175(p) => 5.718117856586434e-7, #kilogram
                            Carbon_dioxide_non_fossil_1252(p) => 2.5884448839268264, #kilogram
                            Nitrogen_oxides_1890(p) => 0.0005117597333102247, #kilogram
                            Benzo_a_pyrene_2768(p) => 2.858923125370674e-10, #kilogram
                            Mercury_II_2851(p) => 8.57704098195711e-10, #kilogram
                            Water_cooling_unspecified_natural_origin_2946(p) => 0.3803759096443318, #cubic meter
                            Acetic_acid_3353(p) => 4.2883846880560116e-6, #kilogram
                            Toluene_3473(p) => 5.718117856586435e-6, #kilogram
                            PAH_polycyclic_aromatic_hydrocarbons_3573(p) => 2.858923125370675e-7, #kilogram
                            Butane_3666(p) => 2.0013005089284896e-5, #kilogram
                            Formaldehyde_3857(p) => 2.8589231253706745e-6, #kilogram
                            Propane_4257(p) => 5.718117856586435e-6, #kilogram
                            Methane_fossil_4384(p) => 5.718117856586435e-5, #kilogram
                            Dinitrogen_monoxide_4391(p) => 2.8589231253706745e-6, #kilogram
                            Water_4539(p) => 0.010977689, #cubic meter
                            Benzene_4564(p) => 1.1435964107327784e-5, #kilogram
                            ));
                            
        ## end

    ## End

    ### 3.2 Coal Gasification
        ### 3.2.1 Coal gasification without CCS
            # THECHNOSPHERE FLOWS
            #-----------------------------------------------------------------------------------------  
            chemical_factory_2368(p) = getAct("chemical factory construction, organics", "RoW",project=p);
            lime_3471(p) = getAct("lime production, milled, packed", "RoW",project=p);
            waste_gypsum_4790(p) = getAct("treatment of waste gypsum, inert material landfill", "RoW",project=p);
            hard_coal_ash_5704(p) = getAct("treatment of hard coal ash, residual material landfill", "RoW",project=p);
            liquid_storage_tank_7911(p) = getAct("liquid storage tank production, chemicals, organics", "RoW",project=p);
            transport_15367(p) = getAct("market for transport, freight train", "RoW",project=p);
            wastewater_16102(p) = getAct("treatment of wastewater, average, wastewater treatment", "RoW",project=p);
            transport_16209(p) = getAct("transport, freight, inland waterways, barge", "RoW",project=p);
            aluminium_oxide_16596(p) = getAct("market for aluminium oxide, metallurgical", "RoW",project=p);
            hard_coal_18049(p) = getAct("market for hard coal", "RoW",project=p);
            water_18927(p) = getAct("water production, deionised", "RoW",project=p);
            electricity_20072(p) = getAct("market group for electricity, medium voltage", "GLO",project=p);
            methanol_22098(p) = getAct("methanol production, coal gasification", "RoW",project=p);

            # BIOSPHERE FLOWS
            #-----------------------------------------------------------------------------------------  
            Carbon_dioxide_fossil_2463(p) = getBio("Carbon dioxide, fossil", "air, non-urban air or from high stacks",project=p);
            Ammonia_3201(p) = getBio("Ammonia", "air, non-urban air or from high stacks",project=p);
            Hydrochloric_acid_4291(p) = getBio("Hydrochloric acid", "air, non-urban air or from high stacks",project=p);

            # REPLACE THE CATEGORY AND STAGE 
            #-----------------------------------------------------------------------------------------  
            hydrogen_coal(p)=newAct!(
                                        name="hydrogen production, coal gasification",
                                        label=:hydrogen_coal,
                                        category=:operation,
                                        stage=:level1,
                                        reference_flow="hydrogen, gaseous, low pressure",
                                        unit="kilogram",
                                        location="World",
                                        amount=1.0,
                                        project=p,
                                        
                                        #TECHNOSPHERE FLOWS
                                        #*************************************************************************************  
                                        techflows=Dict(
                                        chemical_factory_2368(p) => 6.997199999999999e-10, #unit
                                        lime_3471(p) => 0.16752, #kilogram
                                        waste_gypsum_4790(p) => -0.22848, #kilogram
                                        hard_coal_ash_5704(p) => -0.50532, #kilogram
                                        liquid_storage_tank_7911(p) => 3.9744e-9, #unit
                                        transport_15367(p) => 1.1397599999999999, #ton kilometer
                                        wastewater_16102(p) => -0.03607, #cubic meter
                                        transport_16209(p) => 0.42432000000000003, #ton kilometer
                                        aluminium_oxide_16596(p) => 0.00098, #kilogram
                                        hard_coal_18049(p) => 6.771, #kilogram
                                        water_18927(p) => 10.5, #kilogram
                                        # electricity_20072(p) => 4.39, #kilowatt hour
                                        electricityHV_MV(p)=> 4.39, #kWh
                                        methanol_22098(p) => 0.00444, #kilogram
                                        ),
                                                        # BIOSPHERE FLOWS
                                        #*************************************************************************************  
                                        bioflows=Dict(
                                        Carbon_dioxide_fossil_2463(p) => 17.77, #kilogram
                                        Ammonia_3201(p) => 0.0069264, #kilogram
                                        Hydrochloric_acid_4291(p) => 0.0103752, #kilogram
                                        ));
                                        
        ## end

        ### 3.2.1 Coal gasification with CCS
            # THECHNOSPHERE FLOWS
            #-----------------------------------------------------------------------------------------  
            chemical_factory_2368(p) = getAct("chemical factory construction, organics", "RoW",project=p);
            lime_3471(p) = getAct("lime production, milled, packed", "RoW",project=p);
            nitrogen_3593(p) = getAct("market for nitrogen, liquid", "RoW",project=p);
            waste_gypsum_4790(p) = getAct("treatment of waste gypsum, inert material landfill", "RoW",project=p);
            hard_coal_ash_5704(p) = getAct("treatment of hard coal ash, residual material landfill", "RoW",project=p);
            liquid_storage_tank_7911(p) = getAct("liquid storage tank production, chemicals, organics", "RoW",project=p);
            transport_15367(p) = getAct("market for transport, freight train", "RoW",project=p);
            wastewater_16102(p) = getAct("treatment of wastewater, average, wastewater treatment", "RoW",project=p);
            transport_16209(p) = getAct("transport, freight, inland waterways, barge", "RoW",project=p);
            aluminium_oxide_16596(p) = getAct("market for aluminium oxide, metallurgical", "RoW",project=p);
            hard_coal_18049(p) = getAct("market for hard coal", "RoW",project=p);
            water_18927(p) = getAct("water production, deionised", "RoW",project=p);
            ammonia_18963(p) = getAct("market for ammonia, anhydrous, liquid", "RoW",project=p);
            electricity_20072(p) = getAct("market group for electricity, medium voltage", "GLO",project=p);
            carbon_dioxide_21240(p) = getAct("carbon dioxide, captured at hydrogen production plant, pre, pipeline 200km, storage 1000m", "RER",project=p);
            methanol_22098(p) = getAct("methanol production, coal gasification", "RoW",project=p);

            # BIOSPHERE FLOWS
            #-----------------------------------------------------------------------------------------  
            Carbon_dioxide_fossil_2463(p) = getBio("Carbon dioxide, fossil", "air, non-urban air or from high stacks",project=p);
            Water_cooling_unspecified_natural_origin_2946(p) = getBio("Water, cooling, unspecified natural origin", "natural resource, in water",project=p);
            Ammonia_3201(p) = getBio("Ammonia", "air, non-urban air or from high stacks",project=p);
            Hydrochloric_acid_4291(p) = getBio("Hydrochloric acid", "air, non-urban air or from high stacks",project=p);
            #-----------------------------------------------------------------------------------------  
            hydrogen_coalccs(p)=newAct!(
                            name="hydrogen production, coal gasification, with CCS",
                            label=:hydrogen_coalccs,
                            category=:operation,
                            stage=:level1,
                            reference_flow="hydrogen, gaseous, low pressure",
                            unit="kilogram",
                            location="World",
                            amount=1.0,
                            project=p,
                            
                            #TECHNOSPHERE FLOWS
                            #*************************************************************************************  
                            techflows=Dict(
                            chemical_factory_2368(p) => 6.997199999999999e-10, #unit
                            lime_3471(p) => 0.16752, #kilogram
                            nitrogen_3593(p) => 0.0096, #kilogram
                            waste_gypsum_4790(p) => -0.22848, #kilogram
                            hard_coal_ash_5704(p) => -0.50532, #kilogram
                            liquid_storage_tank_7911(p) => 3.9744e-9, #unit
                            transport_15367(p) => 1.1397599999999999, #ton kilometer
                            wastewater_16102(p) => -0.050208754, #cubic meter
                            transport_16209(p) => 0.42432000000000003, #ton kilometer
                            aluminium_oxide_16596(p) => 0.00098, #kilogram
                            hard_coal_18049(p) => 6.771, #kilogram
                            water_18927(p) => 10.24, #kilogram
                            ammonia_18963(p) => 5.7e-5, #kilogram
                            # electricity_20072(p) => 7.75, #kilowatt hour
                            elecLV(p)=> 7.75, #kWh
                            carbon_dioxide_21240(p) => 15.29, #kilogram
                            methanol_22098(p) => 0.00444, #kilogram
                            ),
                                            # BIOSPHERE FLOWS
                            #*************************************************************************************  
                            bioflows=Dict(
                            Carbon_dioxide_fossil_2463(p) => 2.48, #kilogram
                            Water_cooling_unspecified_natural_origin_2946(p) => 0.032, #cubic meter
                            Ammonia_3201(p) => 0.0069264, #kilogram
                            Hydrochloric_acid_4291(p) => 0.0103752, #kilogram
                            ));
                
        ## end
    ## End

    ### 3.3 Biomass gasification
        ### 3.3.1 Biomass gasification with CCS
            #Copy of the activity: hydrogen production, gaseous, 25 bar, from gasification of woody biomass in entrained flow gasifier, with CCS, at gasification plant - World 

            # THECHNOSPHERE FLOWS
            #-----------------------------------------------------------------------------------------  
            electricity_5949(p) = getAct("market group for electricity, low voltage", "ENTSO-E",project=p);
            water_12449(p) = getAct("market for water, deionised", "RoW",project=p);
            synthetic_gas_factory_13162(p) = getAct("synthetic gas factory construction", "RoW",project=p);
            wood_chips_13315(p) = getAct("market for wood chips, wet, measured as dry mass", "RoW",project=p);

            wastewater_16102(p) = getAct("treatment of wastewater, average, wastewater treatment", "RoW",project=p);
            carbon_dioxide_21240(p) = getAct("carbon dioxide, captured at hydrogen production plant, pre, pipeline 200km, storage 1000m", "RER",project=p);

            # BIOSPHERE FLOWS
            #-----------------------------------------------------------------------------------------  
            Carbon_dioxide_non_fossil_1252(p) = getBio("Carbon dioxide, non-fossil", "air, unspecified",project=p);

            # REPLACE THE CATEGORY AND STAGE 
            #-----------------------------------------------------------------------------------------  
            hydrogen_BioCccs(p)=newAct!(
                                        name="hydrogen production, gaseous, 25 bar, from gasification of woody biomass in entrained flow gasifier, with CCS, at gasification plant",
                                        label=:hydrogen_BioCccs,
                                        category=:operation,
                                        stage=:level1,
                                        reference_flow="hydrogen, gaseous, 25 bar",
                                        unit="kilogram",
                                        location="World",
                                        amount=1.0,
                                        project=p,
                                        
                                        #TECHNOSPHERE FLOWS
                                        #*************************************************************************************  
                                        techflows=Dict(
                                                    electricity_5949(p) => 0.0, #kilowatt hour
                                                    water_12449(p) => 15.92628, #kilogram
                                                    synthetic_gas_factory_13162(p) => 5.348319914762801e-10, #unit
                                                    wood_chips_13315(p) => 11.6966, #kilogram
                                                    liquid_storage_tank_14447(p) => 2.54628e-9, #unit
                                                    wastewater_16102(p) => -0.012439, #cubic meter
                                                    carbon_dioxide_21240(p) => 19.58557, #kilogram
                                                    ),
                                        # BIOSPHERE FLOWS
                                        #*************************************************************************************  
                                        bioflows=Dict(
                                                    Carbon_dioxide_non_fossil_1252(p) => 1.5237, #kilogram
                                                                                                ));
        #Copy of the activity: hydrogen production, gaseous, 25 bar, from gasification of woody biomass in entrained flow gasifier, at gasification plant - World 

        # THECHNOSPHERE FLOWS
        #-----------------------------------------------------------------------------------------  
        electricity_5949(p) = getAct("market group for electricity, low voltage", "ENTSO-E",project=p);
        water_12449(p) = getAct("market for water, deionised", "RoW",project=p);
        synthetic_gas_factory_13162(p) = getAct("synthetic gas factory construction", "RoW",project=p);
        wood_chips_13315(p) = getAct("market for wood chips, wet, measured as dry mass", "RoW",project=p);
        liquid_storage_tank_14447(p) = getAct("market for liquid storage tank, chemicals, organics", "GLO",project=p);
        wastewater_16102(p) = getAct("treatment of wastewater, average, wastewater treatment", "RoW",project=p);

        # BIOSPHERE FLOWS
        #-----------------------------------------------------------------------------------------  
        Carbon_dioxide_non_fossil_1252(p) = getBio("Carbon dioxide, non-fossil", "air, unspecified",project=p);

        # REPLACE THE CATEGORY AND STAGE 
        #-----------------------------------------------------------------------------------------  
        hydrogen_BioG(p)=newAct!(
                                    name="hydrogen production, gaseous, 25 bar, from gasification of woody biomass in entrained flow gasifier, at gasification plant",
                                    label=:hydrogen_BioG,
                                    category=:copied_default,
                                    stage=:copied_default,
                                    reference_flow="hydrogen, gaseous, 25 bar",
                                    unit="kilogram",
                                    location="World",
                                    amount=1.0,
                                    project=p,
                                    
                                    #TECHNOSPHERE FLOWS
                                    #*************************************************************************************  
                                    techflows=Dict(
                                                electricity_5949(p) => 0.0, #kilowatt hour
                                                water_12449(p) => 15.90552, #kilogram
                                                synthetic_gas_factory_13162(p) => 5.348319914762801e-10, #unit
                                                wood_chips_13315(p) => 11.6966, #kilogram
                                                liquid_storage_tank_14447(p) => 2.54628e-9, #unit
                                                wastewater_16102(p) => -0.012439, #cubic meter
        ),
                                    # BIOSPHERE FLOWS
                                    #*************************************************************************************  
                                    bioflows=Dict(
                                                Carbon_dioxide_non_fossil_1252(p) => 21.1966, #kilogram
                                                                                            ))
                        ;
                        
                ## end
            ## End

    ### 3.4 Methane pyrolysis
        # THECHNOSPHERE FLOWS
            #-----------------------------------------------------------------------------------------  
            palladium_1283(p) = getAct("market for palladium", "GLO",project=p);
            tap_water_6575(p) = getAct("market for tap water", "RoW",project=p);
            copper_11632(p) = getAct("market for copper, cathode", "GLO",project=p);
            natural_gas_11706(p) = getAct("market for natural gas, high pressure", "RoW",project=p);
            air_compressor_12767(p) = getAct("market for air compressor, screw-type compressor, 4kW", "GLO",project=p);
            tin_18369(p) = getAct("market for tin", "GLO",project=p);
            silicon_carbide_19631(p) = getAct("market for silicon carbide", "GLO",project=p);
            electricity_23998(p) = getAct("market group for electricity, low voltage", "EUR",project=p);
            steel_27543(p) = getAct("market for steel, chromium steel 18/8", "World",project=p);

            # BIOSPHERE FLOWS
            #-----------------------------------------------------------------------------------------  
            Water_773(p) = getBio("Water", "water, unspecified",project=p);
            Carbon_dioxide_fossil_1780(p) = getBio("Carbon dioxide, fossil", "air, unspecified",project=p);
            Water_4539(p) = getBio("Water", "air, unspecified",project=p);
            #-----------------------------------------------------------------------------------------  
            hydrogen_pyrolysis(p)=newAct!(
                            name="hydrogen production, gaseous, 100 bar, from methane pyrolysis",
                            label=:hydrogen_pyrolysis,
                            category=:operation,
                            stage=:level1,
                            reference_flow="hydrogen, gaseous, 100 bar",
                            unit="kilogram",
                            location="World",
                            amount=1.0,
                            project=p,
                            
                            #TECHNOSPHERE FLOWS
                            #*************************************************************************************  
                            techflows=Dict(
                                        palladium_1283(p) => 1.1e-5, #kilogram
                                        tap_water_6575(p) => 7.751652902472759, #kilogram
                                        copper_11632(p) => 7.33e-6, #kilogram
                                        natural_gas_11706(p) => 5.67, #cubic meter
                                        air_compressor_12767(p) => 6.36e-8, #unit
                                        tin_18369(p) => 0.0336, #kilogram
                                        silicon_carbide_19631(p) => 4.2e-6, #kilogram
                                        elecLV(p)=> 9.593629829793018, #kWh
                                        steel_27543(p) => 0.003097, #kilogram
                            ),
                                            # BIOSPHERE FLOWS
                            #*************************************************************************************  
                            bioflows=Dict(
                                        Water_773(p) => 0.006976487612225483, #cubic meter
                                        Carbon_dioxide_fossil_1780(p) => 2.3984074574482546, #kilogram
                                        Water_4539(p) => 0.0007751652902472758, #cubic meter
                                        ));
    ## end

    ### 3.5 Water electrolysis
        ### 3.5.1 Alkaline electrolysis
            # THECHNOSPHERE FLOWS
            #-----------------------------------------------------------------------------------------  
            potassium_hydroxide_7956(p) = getAct("market for potassium hydroxide", "GLO",project=p);
            water_17817(p) = getAct("market for water, deionised", "CH",project=p);
            electrolyzer_22043(p) = getAct("electrolyzer production, 1MWe, AEC, Stack", "RER",project=p);
            used_fuel_cell_stack_22044(p) = getAct("treatment of fuel cell stack, 1MWe, AEC", "RER",project=p);
            electrolyzer_22045(p) = getAct("electrolyzer production, 1MWe, AEC, Balance of Plant", "RER",project=p);
            used_fuel_cell_balance_of_plant_22046(p) = getAct("treatment of fuel cell balance of plant, 1MWe, AEC", "RER",project=p);

            # BIOSPHERE FLOWS
            #-----------------------------------------------------------------------------------------  
            Transformation_to_industrial_area_1035(p) = getBio("Transformation, to industrial area", "natural resource, land",project=p);
            Transformation_from_industrial_area_1122(p) = getBio("Transformation, from industrial area", "natural resource, land",project=p);
            Occupation_industrial_area_4354(p) = getBio("Occupation, industrial area", "natural resource, land",project=p);
            Oxygen_4449(p) = getBio("Oxygen", "air, unspecified",project=p);
            #-----------------------------------------------------------------------------------------  
            hydrogen_AE(p)=newAct!(
                            name="hydrogen production, gaseous, 20 bar, from AEC electrolysis, from choice electricity",
                            label=:hydrogen_AE,
                            category=:operation,
                            stage=:level1,
                            reference_flow="hydrogen, gaseous, 20 bar",
                            unit="kilogram",
                            location="World",
                            amount=1.0,
                            project=p,
                            
                            #TECHNOSPHERE FLOWS
                            #*************************************************************************************  
                            techflows=Dict(
                                            potassium_hydroxide_7956(p) => 0.0037, #kilogram
                                            water_17817(p) => 14.0, #kilogram
                                            electrolyzer_22043(p) => 9.391435011269722e-7, #unit
                                            used_fuel_cell_stack_22044(p) => -9.391435011269722e-7, #unit
                                            electrolyzer_22045(p) => 2.3478587528174306e-7, #unit
                                            used_fuel_cell_balance_of_plant_22046(p) => -2.3478587528174306e-7, #unit
                                            elecLV(p) => 48.5, #kilowatt hour
                                    ),
                            # BIOSPHERE FLOWS
                            #*************************************************************************************  
                            bioflows=Dict(
                                        Transformation_to_industrial_area_1035(p) => 2.8174305033809167e-5, #square meter
                                        Transformation_from_industrial_area_1122(p) => 2.8174305033809167e-5, #square meter
                                        Occupation_industrial_area_4354(p) => 0.0007747933884297521, #square meter-year
                                        Oxygen_4449(p) => 8.0, #kilogram
                                        ))
                                        ;


        ## end

        ### 3.5.2 Proton exchange membrane electrolysis

            ### 3.5.2.1 stacks
                # THECHNOSPHERE FLOWS
                #-----------------------------------------------------------------------------------------  
                tetrafluoroethylene_2946(p) = getAct("market for tetrafluoroethylene", "GLO",project=p);
                sheet_rolling_5631(p) = getAct("market for sheet rolling, chromium steel", "GLO",project=p);
                steel_8727(p) = getAct("market for steel, chromium steel 18/8, hot rolled", "GLO",project=p);
                copper_11632(p) = getAct("market for copper, cathode", "GLO",project=p);
                platinum_12068(p) = getAct("market for platinum", "GLO",project=p);
                sheet_rolling_14363(p) = getAct("market for sheet rolling, aluminium", "GLO",project=p);
                synthetic_rubber_16219(p) = getAct("market for synthetic rubber", "GLO",project=p);
                sheet_rolling_16747(p) = getAct("market for sheet rolling, copper", "GLO",project=p);
                titanium_16891(p) = getAct("market for titanium", "GLO",project=p);
                carbon_black_17372(p) = getAct("market for carbon black", "GLO",project=p);
                aluminium_17463(p) = getAct("market for aluminium, wrought alloy", "GLO",project=p);
                iridium_22034(p) = getAct("platinum group metal, extraction and refinery operations", "ZA",project=p);

                #-----------------------------------------------------------------------------------------  
                electrolyzer_22038(p)=newAct!(
                                    name="electrolyzer production, 1MWe, PEM, Stack",
                                    label=:electrolyzer_22038,
                                    category=:copied_default,
                                    stage=:copied_default,
                                    reference_flow="electrolyzer, 1MWe, PEM, Stack",
                                    unit="unit",
                                    location="RER",
                                    amount=1.0,
                                    project=p,
                                    
                                    #TECHNOSPHERE FLOWS
                                    #*************************************************************************************  
                                    techflows=Dict(
                                                tetrafluoroethylene_2946(p) => 16.0, #kilogram
                                                sheet_rolling_5631(p) => 100.0, #kilogram
                                                steel_8727(p) => 100.0, #kilogram
                                                copper_11632(p) => 4.5, #kilogram
                                                platinum_12068(p) => 0.75, #kilogram
                                                sheet_rolling_14363(p) => 27.0, #kilogram
                                                synthetic_rubber_16219(p) => 4.8, #kilogram
                                                sheet_rolling_16747(p) => 4.5, #kilogram
                                                titanium_16891(p) => 528.0, #kilogram
                                                carbon_black_17372(p) => 9.0, #kilogram
                                                aluminium_17463(p) => 27.0, #kilogram
                                                iridium_22034(p) => 0.8, #kilogram
                                                electricityHV_MV(p) => 103890.7681, #kilowatt hour
                                    ),
                                                    # BIOSPHERE FLOWS
                                    #*************************************************************************************  
                                    bioflows=Dict(
                                                #*-*-**-*-* -> no biosphere flows, null amount of oxygen registered
                                                getBio("Oxygen","air, unspecified") => 0 ));
                                    
            ## end
            
            ### 3.5.2.2 Plant
                # THECHNOSPHERE FLOWS
                #-----------------------------------------------------------------------------------------  
                water_12449(p) = getAct("market for water, deionised", "RoW",project=p);
                used_fuel_cell_stack_22039(p) = getAct("treatment of fuel cell stack, 1MWe, PEM", "RER",project=p);
                electrolyzer_22040(p) = getAct("electrolyzer production, 1MWe, PEM, Balance of Plant", "RER",project=p);
                used_fuel_cell_balance_of_plant_22041(p) = getAct("treatment of fuel cell balance of plant, 1MWe, PEM", "RER",project=p);
                # BIOSPHERE FLOWS
                #-----------------------------------------------------------------------------------------  
                Transformation_to_industrial_area_1035(p) = getBio("Transformation, to industrial area", "natural resource, land",project=p);
                Transformation_from_industrial_area_1122(p) = getBio("Transformation, from industrial area", "natural resource, land",project=p);
                Occupation_industrial_area_4354(p) = getBio("Occupation, industrial area", "natural resource, land",project=p);
                Oxygen_4449(p) = getBio("Oxygen", "air, unspecified",project=p);

                #-----------------------------------------------------------------------------------------  
                hydrogen_PEM(p)=newAct!(
                            name="hydrogen production, gaseous, 30 bar, from PEM electrolysis, from choice electricity",
                            label=:hydrogen_PEM,
                            category=:operation,
                            stage=:level1,
                            reference_flow="hydrogen, gaseous, 30 bar",
                            unit="kilogram",
                            location="World",
                            amount=1.0,
                            project=p,
                            
                            #TECHNOSPHERE FLOWS
                            #*************************************************************************************  
                            techflows=Dict(
                                            water_12449(p) => 14.0, #kilogram
                                            electrolyzer_22038(p) => 1.349892008639309e-6, #unit
                                            used_fuel_cell_stack_22039(p) => -1.349892008639309e-6, #unit
                                            electrolyzer_22040(p) => 3.3747300215982723e-7, #unit
                                            used_fuel_cell_balance_of_plant_22041(p) => -3.3747300215982723e-7, #unit
                                            elecLV(p) => 52, #kilowatt hour:  this is directly updated in the TCM
                                            ),
                                            # BIOSPHERE FLOWS
                            #*************************************************************************************  
                            bioflows=Dict(
                                        Transformation_to_industrial_area_1035(p) => 2.547921166306695e-5, #square meter
                                        Transformation_from_industrial_area_1122(p) => 2.547921166306695e-5, #square meter
                                        Occupation_industrial_area_4354(p) => 0.0005095842332613391, #square meter-year
                                        Oxygen_4449(p) => 6.71111111111111, #kilogram
                            ));

            ## end

        ## end

        ### 3.5.1 Solide oxide electrolyis 
            ### 3.5.1.1 Steam input
                # THECHNOSPHERE FLOWS
                #-----------------------------------------------------------------------------------------  
                water_12500(p) = getAct("market for water, deionised", "Europe without Switzerland",project=p);
                electrolyzer_22049(p) = getAct("electrolyzer production, 1MWe, SOEC, Stack", "RER",project=p);
                used_fuel_cell_stack_22050(p) = getAct("treatment of fuel cell stack, 1MWe, SOEC", "RER",project=p);
                electrolyzer_22051(p) = getAct("electrolyzer production, 1MWe, SOEC, Balance of Plant", "RER",project=p);
                used_fuel_cell_balance_of_plant_22052(p) = getAct("treatment of fuel cell balance of plant, 1MWe, SOEC", "RER",project=p);
                electricity_24018(p) = getAct("market group for electricity, low voltage", "NEU",project=p);
                heat_26329(p) = getAct("market for heat, from steam, in chemical industry", "NEU",project=p);

                # BIOSPHERE FLOWS
                #-----------------------------------------------------------------------------------------  
                Transformation_to_industrial_area_1035(p) = getBio("Transformation, to industrial area", "natural resource, land",project=p);
                Transformation_from_industrial_area_1122(p) = getBio("Transformation, from industrial area", "natural resource, land",project=p);
                Occupation_industrial_area_4354(p) = getBio("Occupation, industrial area", "natural resource, land",project=p);
                Oxygen_4449(p) = getBio("Oxygen", "air, unspecified",project=p);

                #-----------------------------------------------------------------------------------------  
                hydrogen_SOEC_steam(p)=newAct!(
                            name="hydrogen production, gaseous, 1 bar, from SOEC electrolysis, with steam input, from choice electricity",
                            label=:hydrogen_SOEC_steam,
                            category=:operation,
                            stage=:level1,
                            reference_flow="hydrogen, gaseous, 1 bar",
                            unit="kilogram",
                            location="World",
                            amount=1.0,
                            project=p,
                            
                            #TECHNOSPHERE FLOWS
                            #*************************************************************************************  
                            techflows=Dict(
                            water_12500(p) => 14.0, #kilogram
                            electrolyzer_22049(p) => 2.11864406779661e-6, #unit
                            used_fuel_cell_stack_22050(p) => -2.11864406779661e-6, #unit
                            electrolyzer_22051(p) => 2.6483050847457627e-7, #unit
                            used_fuel_cell_balance_of_plant_22052(p) => -2.6483050847457627e-7, #unit
                            elecLV(p) => 39.0, #kilowatt hour
                            heat_26329(p) => 16.0, #megajoule
                            ),
                                            # BIOSPHERE FLOWS
                            #*************************************************************************************  
                            bioflows=Dict(
                            Transformation_to_industrial_area_1035(p) => 1.3241525423728813e-5, #square meter
                            Transformation_from_industrial_area_1122(p) => 1.3241525423728813e-5, #square meter
                            Occupation_industrial_area_4354(p) => 0.00026483050847457627, #square meter-year
                            Oxygen_4449(p) => 8.0, #kilogram
                            ));
            ## end
            
            ### 3.5.1.2 Heat pump
                #-----------------------------------------------------------------------------------------  
                hydrogen_SOEC_elec(p)=newAct!(
                            name="hydrogen production, gaseous, 1 bar, from SOEC electrolysis, from choice electricity",
                            label=:hydrogen_SOEC_elec,
                            category=:operation,
                            stage=:level1,
                            reference_flow="hydrogen, gaseous, 1 bar",
                            unit="kilogram",
                            location="World",
                            amount=1.0,
                            project=p,
                            
                            #TECHNOSPHERE FLOWS
                            #*************************************************************************************  
                            techflows=Dict(
                                            water_12500(p) => 14.0, #kilogram
                                            electrolyzer_22049(p) => 2.11864406779661e-6, #unit
                                            used_fuel_cell_stack_22050(p) => -2.11864406779661e-6, #unit
                                            electrolyzer_22051(p) => 2.6483050847457627e-7, #unit
                                            used_fuel_cell_balance_of_plant_22052(p) => -2.6483050847457627e-7, #unit
                                            elecLV(p) => 40.6, #kilowatt hour
                                            heat_26329(p) => 0.0, #megajoule
                                            ),
                                            # BIOSPHERE FLOWS
                            #*************************************************************************************  
                            bioflows=Dict(
                                        Transformation_to_industrial_area_1035(p) => 5.296610169491526e-6, #square meter
                                        Transformation_from_industrial_area_1122(p) => 5.296610169491526e-6, #square meter
                                        Occupation_industrial_area_4354(p) => 0.0001059322033898305, #square meter-year
                                        Oxygen_4449(p) => 8.0, #kilogram
                                        ));

            ## end
        ## end 
    ## end


    model(p)=newChoice([
                        hydrogen_SMR(p),
                        hydrogen_SMRccs(p),
                        hydrogen_bSMR(p),
                        hydrogen_bSMRccs(p),
                        hydrogen_coal(p),hydrogen_coalccs(p),hydrogen_BioCccs(p),hydrogen_BioG(p),
                        hydrogen_pyrolysis(p),
                        hydrogen_AE(p),hydrogen_PEM(p),hydrogen_SOEC_steam(p),hydrogen_SOEC_elec(p)
                        ],
                        name="hydrogen production choice",
                        reference_flow="hydrogen, gaseous",
                        label=:hydrogen,
                        stage=:operation,
                        category=:level0,
                        unit="kg",
                        location="World",
                        project=p);

        """ # Computes the necessary inventories for global hydrogen production.
        ## Description
        This module defines the life cycle inventory (LCI) for various hydrogen production methods, including:
        - Steam Methane Reforming (SMR)
        - Biomass Steam Methane Reforming (bSMR)
        - Coal gasification with and without Carbon Capture and Storage (CCS)
        - Biomass gasification
        - Methane pyrolysis
        - Water electrolysis (Alkaline, PEM, SOEC with steam input and heat pump)
        ## methods
        """ 
    function LCI(p)
        wood_elect(p) #just to initialise the cache, it must not be a choice.
        DAC(p)
        model(p)
    end
end
