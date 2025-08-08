mᵃᵗᵐ = 5.148e18    # total mass of Earth’s atmosphere in kg
Mᵃⁱʳ = 0.02897     # mean molar mass of air in kg kmol⁻¹
Mᴴ² = 2.016e-3     # molar mass of H₂ in kg kmol⁻¹
εᴴ² = 0.13e-3         # effective radiative efficiency of hydrogen in W m⁻² ppbv⁻¹
qₛ = (Mᵃⁱʳ / mᵃᵗᵐ) * 1e9 # air mixing ratio
ε̄ᴴ² = εᴴ² * qₛ / Mᴴ² # effective radiative efficiency of hydrogen in in W m⁻² kg⁻¹
𝛕ᴴ² = 2.5           # lifetime of hydrogen in the atmosphere in yr
Cfᴴ²= 𝛕ᴴ² * ε̄  # Characterisation factor for hydrogen in W yr m⁻²kg⁻¹

Mᶜᵒ² = 44.01e-3    # molar mass of CO₂ in kg kmol⁻¹
εᶜᵒ²=1.33e-5 # W m⁻² ppbv⁻¹
ε̄ᶜᵒ²=εᶜᵒ² * qₛ / Mᶜᵒ² # effective radiative efficiency of CO₂ in W m⁻² kg⁻¹
 
ε̄ᴴ² /ε̄ᶜᵒ² # 1kg of H₂ is equivalent to 213kg of CO₂ in terms of effective radiative forcing

ΔXᵖᵇ= 1 #W m⁻²
af=4e-12
aΔXᵖᵇ= af * ΔXᵖᵇ # W m⁻² kg⁻¹

