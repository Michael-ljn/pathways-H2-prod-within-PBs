∑=sum

"""
PB Characterisation factor for hydrogen in terms of radiative forcing for CO2 
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
    return Cfᴴ²
end

Mᶜᵒ² = 44.01e-3    # molar mass of CO₂ in kg kmol⁻¹
εᶜᵒ² = 1.33e-5  # W/m2/ppb; 2019 background co2 concentration; IPCC AR6 Table 7.15
ε̄ᶜᵒ²=εᶜᵒ² * qₛ / Mᶜᵒ² # effective radiative efficiency of CO₂ in W m⁻² kg⁻¹
ε̄ᴴ² /ε̄ᶜᵒ² # 1kg of H₂ is equivalent to 213kg of CO₂ in terms of effective radiative forcing


"""
Decay matrix for CO2 based on IPCC AR6
"""
function decay_matrix(;period=2020:1:2101)
    period=period.-2019
    α₀ = 0.2173
    α = [0.2240, 0.2824, 0.2763]
    τ = [394.4, 36.54, 4.304]
    
    IRF_CO₂(t)= α₀*t + ∑([αᵢ * τᵢ * (1 - exp(-t/ τᵢ)) for (αᵢ, τᵢ) in zip(α, τ)])

    decays = diff(IRF_CO₂.(period)) #reduction of 1 year here 80
    
    t=length(period)-1
    
    matrix=zeros(t,t)
    
    for y ∈ 1:1:t
        matrix[y,y:t]=decays[1:t-y+1]
    end
    return matrix
end

"""
Decay concentration of CO2, results in a matrix that has to be multiplied by emissions
"""
function equation2(;period=2020:1:2101)
    Mᶜᵒ² = 44.01e-3  # kg mol⁻¹
    Mᵃⁱʳ = 28.97e-3   # mean molar mass of air in kg mol⁻¹
    mᵃᵗᵐ = 5.135e18 #5.148e18   # total mass of Earth’s atmosphere in kg
    qₛ = (Mᵃⁱʳ / mᵃᵗᵐ) * 1e9 #air mixing ratio ppb mol⁻¹
    decays_concentration = (qₛ/Mᶜᵒ²) .* decay_matrix(period=period).*1e-3 # in ppm kg⁻¹
    return  decays_concentration
end

"""
Decay radiative forcing of CO2, results in a matrix that has to be multiplied by emissions
"""
function equation3(;period=2020:1:2101)
    εᶜᵒ² = 1.33e-2 # W/m2/ppm; concentration; IPCC AR6 Table 7.15
    return  decays_forcing=εᶜᵒ².*equation2(;period=period) #  W m⁻² kg⁻¹
end

equation3()


