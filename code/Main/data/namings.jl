process_names = Dict(
        "hydrogen production, gaseous, 100 bar, from methane pyrolysis" => "MP",
        "hydrogen production, coal gasification" => "CG",
        "hydrogen production, steam methane reforming" => "SMR",
        "hydrogen production, coal gasification, with CCS" => "CGccs",
        "hydrogen production, gaseous, 1 bar, from SOEC electrolysis, from choice electricity" => "SOECelectricity",
        "hydrogen production, steam methane reforming, from biomethane, with CCS" => "bioSMRccs",
        "hydrogen production, gaseous, 30 bar, from PEM electrolysis, from choice electricity" => "PEM",
        "hydrogen production, gaseous, 20 bar, from AEC electrolysis, from choice electricity" => "AEC",
        "hydrogen production, steam methane reforming, with CCS" => "SMRccs",
        "hydrogen production, steam methane reforming, from biomethane" => "bioSMR",
        "hydrogen production, gaseous, 1 bar, from SOEC electrolysis, with steam input, from choice electricity" => "SOECsteam",
        "hydrogen production, gaseous, 25 bar, from gasification of woody biomass in entrained flow gasifier, with CCS, at gasification plant"=>"bioGccs",   
        "hydrogen production, gaseous, 25 bar, from gasification of woody biomass in entrained flow gasifier, at gasification plant" => "bioG",
        "biomethane production, from biogas upgrading, using amine scrubbing" => "bioMethane",
        "carbon dioxide, captured from atmosphere and stored, with a solvent-based direct air capture system, 1MtCO2, with industrial steam heat, and grid electricity"=>"CC_steam",
        "carbon dioxide, captured from atmosphere and stored, with a solvent-based direct air capture system, 1MtCO2, with heat pump heat, and grid electricity"=>"CC_HP",
        "electricity production, peat" => "E_Peat",
        "electricity production, lignite" => "E_Lignite",
        "electricity production, wind, >3MW turbine, onshore" => "E_Wind_Onshore",
        "electricity production, deep geothermal" => "E_Geothermal",
        "electricity production, solar thermal parabolic trough, 50 MW" => "E_Solar_Thermal",
        "electricity production, at lignite-fired IGCC power plant" => "E_Lignite_IGCC",
        "electricity production, natural gas, 10MW" => "E_Gas_10MW",
        "electricity production, hydro, reservoir, tropical region" => "E_Hydro_Tropical",
        "electricity production, oil" => "E_Oil",
        "electricity production, hard coal" => "E_Coal",
        "electricity production, hard coal, supercritical" => "E_Coal_SC",
        "electricity production, nuclear, pressure water reactor" => "E_Nuclear_PWR",
        "electricity production, from hydrogen-fired one gigawatt gas turbine" => "E_Hydrogen_1GW",
        "electricity production, wood, future" => "E_Wood_Future",
        "electricity production, at natural gas-fired combined cycle power plant, post, pipeline 200km, storage 1000m" => "E_NGccs",
        "electricity production, at natural gas-fired combined cycle power plant" => "E_NG",
        "electricity production, nuclear, boiling water reactor" => "E_Nuclear_BWR",
        "electricity production, hydro, run-of-river" => "E_Hydro",
        "electricity production, nuclear, pressure water reactor, heavy water moderated" => "E_Nuclear_PWR_HWM",
        "electricity production, photovoltaic, 570kWp open ground installation, multi-Si"=> "E_PV"
        );


catnames=["Energy  Imbalance",
        "CO2  Concentration",
        "Ocean  Acidification",
        "Atmospheric  Aerosol  Loading",
        "Freshwater  Use",
        "Biogeochemical  Flows  P",
        "Biogeochemical  Flows  N",
        "Stratospheric  Ozone  Depletion",
        "Land-System  Change",
        "Biosphere  Integrity"
        ];

# utility function to wrap text, use a double space to separate words
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


catnames_ticks=wrap_text.(catnames, 9)