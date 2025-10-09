using InvertedIndices
using SparseArrays, LinearAlgebra, Statistics

catlabels_lade= [ # Labels order from Lade et al. 2020
                "Climate Change"
                "BI Land"
                "BI Freshwater"
                "BI Ocean"
                "Land System Change"
                "Biogeochemical Flows"
                "Ocean Acidification"
                "Freshwater Use"
                "Aerosol Loading"
                "Strat. Ozone Depletion"]

ᶜᶜ = 1 # Climate Change
ᴮᴵˡ = 2 # BI Land
ᴮᴵᶠ = 3 # BI Freshwater
ᴮᴵᴼ = 4  # BI Ocean
ˡˢᶜ = 5 # Land System Change
ᴮᶜᶠ = 6 # Biogeochemical Flows
ᴼᵃ = 7 # Ocean Acidification
ᶠʷᵘ = 8 # Freshwater Use
ᵃᵃˡ = 9 # Aerosol Loading
ˢᵒᵈ = 10 # Strat. Ozone Depletion


#### matrices


𝐈=I(10) # Identity matrix

# 𝐁 ∈ ℝᵏᶻ matrix for Biophysical interactions, # NOTE: Matrix arranged to represent the effect of columns on rows
𝐁 = [
    1.0     0.15    0.38    0.22    0.10    0.19    -0.07   -0.08   0       -0.06   # Climate Change
    0.22    1       0       0       0       0       0.08    0       0       0       # BI Land
    0.17    0       1       0       0       0       0.04    0       0       0       # BI Freshwater
    0.15    0       0       1       0       0       0.06    0       0       0       # BI Ocean
    0.12    0.8     0.08    0       1       0       0.16    -0.11   0       0       # Land System Change
    0.04    0.02    1       0.05    0       1       -0.03   0       0.10    0.01    # Biogeochemical Flows
    0.10    0       0       1       0       0       1       0       0       0       # Ocean Acidification
    0       0       1       0       0       0       0       1       0       0       # Freshwater Use
    -0.56   0       0       0       0       0       0       0       1       0       # Aerosol Loading
    -0.11   0       0       0       0       0       0       0       0       1       # Strat. Ozone Deplet.
    ]'-𝐈 |>sparse

    
# 𝐑 ∈ ℝᵏᶻ matrix for Reactive human-mediated interactions # NOTE: Matrix arranged to represent the effect of columns on rows
𝐑 = [
    1       0       0       0       0.05        0       0       0       0       0       # Climate Change
    0       1       0       0       0           0       0       0       0       0       # BI Land
    0.002   0       1       0       0.003       0       0       0       0       0       # BI Freshwater
    0       0       0       1       0.02        0       0       0       0       0       # BI Ocean
    0       0       0       0       1           0       0       0       0       0       # Land System Change
    0       0       0       0       0           1       0       0       0       0       # Biogeochemical Flows
    0       0       0       0       0           0       1       0       0       0       # Ocean Acidification
    0       0       0       0       0           0       0       1       0       0       # Freshwater Use
    0       0       0       0       0           0       0       0       1       0       # Aerosol Loading
    0       0       0       0       0           0       0       0       0       1       # Strat. Ozone Deplet.
    ]'-𝐈 |>sparse
    

# 𝐏 ∈ ℝᶻᶻ matrix for Parallel human drivers, # NOTE: Matrix arranged to represent the effect of columns on rows
𝐏 = [
    1       0       0       0       0       0       0.40        0.065       0       0       # Climate Change
    0       1       0       0       0       0       0           0           0       0       # BI Land
    0       0       1       0       0       0       0           0           0       0       # BI Freshwater
    0       0       0       1       0       0       0           0           0       0       # BI Ocean
    0.33    0       0       0       1       1.3     0           0.36        0       0       # Land System Change
    0.005   0       0       0       0       1       0           0           0       0       # Biogeochemical Flows
    0       0       0       0       0       0       1           0           0       0       # Ocean Acidification
    0.018   0       0       0       0       0       0           1           0       0       # Freshwater Use
    0       0       0       0       0       0       0           0           1       0       # Aerosol Loading
    0.52    0       0       0       0       0       0           0           0       1       # Strat. Ozone Deplet.
    ]'-𝐈 |>sparse