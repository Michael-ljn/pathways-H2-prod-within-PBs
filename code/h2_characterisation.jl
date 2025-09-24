"""
# PB Characterisation factor for hydrogen in terms of radiative forcing for CO2 
"""
function CFᴴ²()
    mᵃᵗᵐ = 5.148e18   # total mass of Earth’s atmosphere in kg
    Mᵃⁱʳ = 28.97e-3     # mean molar mass of air in kg mol⁻¹
    Mᴴ² = 2.016e-3    # molar mass of H₂ in kg mol⁻¹
    εᴴ² = 0.13e-3         # effective radiative efficiency of hydrogen in W m⁻² ppbv⁻¹
    qₛ = (Mᵃⁱʳ / mᵃᵗᵐ) * 1e9 # air mixing ratio ppb mol⁻¹
    ε̄ᴴ² = εᴴ² * qₛ / Mᴴ² # effective radiative efficiency of hydrogen in in W m⁻² kg⁻¹
    𝛕ᴴ² = 2.5           # lifetime of hydrogen in the atmosphere in yr
    Cfᴴ²= 𝛕ᴴ² * ε̄ᴴ²  # Characterisation factor for hydrogen in W yr m⁻²kg⁻¹

    # Mᶜᵒ² = 44.01e-3    # molar mass of CO₂ in kg kmol⁻¹
    # εᶜᵒ²=1.33e-5 # W m⁻² ppbv⁻¹
    # ε̄ᶜᵒ²=εᶜᵒ² * qₛ / Mᶜᵒ² # effective radiative efficiency of CO₂ in W m⁻² kg⁻¹
    #ε̄ᴴ² /ε̄ᶜᵒ² # 1kg of H₂ is equivalent to 213kg of CO₂ in terms of effective radiative forcing
    return Cfᴴ²
end




### CO2 analysis
    # ∑ = sum

    # α₀ = 0.2173
    # α = [0.2240, 0.2824, 0.2763]
    # τ = [394.4, 36.54, 4.304]

    # IRF_CO₂(t)= α₀*t + ∑([αᵢ * τᵢ * (1 - exp(-t/ τᵢ)) for (αᵢ, τᵢ) in zip(α, τ)])

    # function RF_CO₂(impact,period)

    #     radiative_efficiency_ppb = 1.33e-5  # W/m2/ppb; 2019 background co2 concentration; IPCC AR6 Table 7.15
        
    #     # for conversion from ppb to kg-CO2
    #     M_co2 = 44.01  # g/mol
    #     M_air = 28.97  # g/mol, dry air
    #     m_atmosphere = 5.135e18  # kg [Trenberth and Smith, 2005]

    #     radiative_efficiency_kg = radiative_efficiency_ppb * (M_air / M_co2) * 1e9 / m_atmosphere  # W/m2/kg-CO2
        
    #     decay_multipliers = radiative_efficiency_kg * diff(IRF_CO₂.(period)) #reduction of 1 year here 80
    #     years_period=length(period)-1
        
    #     decay_matrix=zeros(years_period,years_period)
    #     for i in 1:1:years_period
    #         decay_matrix[i,i:end]=decay_multipliers[1:end+1-i]
    #     end
        
    #     return  decay_matrix.*impact[1:end-1]

    # end
    # function Conc_CO₂(impact,period)
        
    #     # for conversion from ppb to kg-CO2
    #     M_co2 = 44.01  # g/mol
    #     M_air = 28.97  # g/mol, dry air
    #     m_atmosphere = 5.135e18  # kg [Trenberth and Smith, 2005]

    #     concentration_per_kg =  (M_air / M_co2) * 1e9 / m_atmosphere  # W/m2/kg-CO2
    #     decay_multipliers = concentration_per_kg * diff(IRF_CO₂.(period)) #reduction of 1 year here 80
    #     years_period=length(period)-1
        
    #     decay_matrix=zeros(years_period,years_period)
    #     for i in 1:1:years_period
    #         decay_matrix[i,i:end]=decay_multipliers[1:end+1-i]
    #     end
        
    #     return  decay_matrix.*impact[1:end-1].*1e-3#ppm

    # end


