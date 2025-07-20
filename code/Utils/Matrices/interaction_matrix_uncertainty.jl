using LinearAlgebra, Statistics, InvertedIndices, SparseArrays, Distributions

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

S =Set([ᶜᶜ ᴮᴵˡ ᴮᴵᶠ ᴮᴵᴼ ˡˢᶜ ᴮᶜᶠ ᴼᵃ ᶠʷᵘ ᵃᵃˡ ˢᵒᵈ])# Set of all planetary boundaries
𝐈=I(length(S)) # Identity matrix

𝐁  = zeros(length(S),length(S))
δ𝐁 =  Matrix{UnivariateDistribution}(undef, 10, 10);
δ𝐁.= Dirac(0.0)

# --- Climate change → Biosphere Integrity (land) ---
Δxᶜᶜ⁻ᴮᴵˡ = 2.0    # Normalised current climate change control variable 
Δyᶜᶜ⁻ᴮᴵˡ = 0.3   # Central estimate of current loss of biosphere integrity due to CC (20% of 1.5)
sᶜᶜ⁻ᴮᴵˡ = Δyᶜᶜ⁻ᴮᴵˡ / Δxᶜᶜ⁻ᴮᴵˡ
𝐁[ᶜᶜ, ᴮᴵˡ] = sᶜᶜ⁻ᴮᴵˡ
δ𝐁[ᶜᶜ, ᴮᴵˡ] = TriangularDist(0.05, 0.20, 0.15)

# --- Climate change → Biosphere Integrity (freshwater) ---
Δxᶜᶜ⁻ᴮᴵᶠ = 2.0    # Normalised current climate change control variable 
Δyᶜᶜ⁻ᴮᴵᶠ = 2.3/3  # Cyanobacterial ratio–based estimate
sᶜᶜ⁻ᴮᴵᶠ = Δyᶜᶜ⁻ᴮᴵᶠ / Δxᶜᶜ⁻ᴮᴵᶠ
𝐁[ᶜᶜ, ᴮᴵᶠ] = sᶜᶜ⁻ᴮᴵᶠ
δ𝐁[ᶜᶜ, ᴮᴵᶠ] = TriangularDist(0.30, 0.46, 0.38)

# --- Climate change → Biosphere Integrity (ocean) ---
Δxᶜᶜ⁻ᴮᴵᴼ = 2.0    # Normalised current climate change control variable
Δyᶜᶜ⁻ᴮᴵᴼ = 0.44   # Central estimate of change in ocean biosphere integrity due to CC (0.22 * 2.0)
sᶜᶜ⁻ᴮᴵᴼ = Δyᶜᶜ⁻ᴮᴵᴼ / Δxᶜᶜ⁻ᴮᴵᴼ
𝐁[ᶜᶜ, ᴮᴵᴼ] = sᶜᶜ⁻ᴮᴵᴼ
δ𝐁[ᶜᶜ, ᴮᴵᴼ] = TriangularDist(0.04, 0.50, 0.22)

# --- Climate change → Land system change ---
Δxᶜᶜ⁻ˡˢᶜ = 2.0      # Normalised current climate change control variable
Δyᶜᶜ⁻ˡˢᶜ = 0.20     # Central estimate of change in land system via Amazon tipping scenario (0.10 * 2.0)
sᶜᶜ⁻ˡˢᶜ = Δyᶜᶜ⁻ˡˢᶜ / Δxᶜᶜ⁻ˡˢᶜ
𝐁[ᶜᶜ, ˡˢᶜ] = sᶜᶜ⁻ˡˢᶜ
δ𝐁[ᶜᶜ, ˡˢᶜ] = Uniform(0.05, 0.15)

# --- Climate change → Freshwater Use ---
Δxᶜᶜ⁻ᶠʷᵘ = 2.0    # Normalised current climate change control variable
Δyᶜᶜ⁻ᶠʷᵘ = -0.16  # Central estimate of change in freshwater use (–0.08 * 2.0)
sᶜᶜ⁻ᶠʷᵘ = Δyᶜᶜ⁻ᶠʷᵘ / Δxᶜᶜ⁻ᶠʷᵘ
𝐁[ᶜᶜ, ᶠʷᵘ] = sᶜᶜ⁻ᶠʷᵘ
δ𝐁[ᶜᶜ, ᶠʷᵘ] = TriangularDist(-0.14, -0.07, -0.08)

# --- Climate change → Ocean Acidification ---
Δxᶜᶜ⁻ᴼᵃ = 2.0     # Normalised current climate change control variable
Δyᶜᶜ⁻ᴼᵃ = -0.14   # Central estimate of change in ocean acidification due to CC (–0.07 * 2.0)
sᶜᶜ⁻ᴼᵃ = Δyᶜᶜ⁻ᴼᵃ / Δxᶜᶜ⁻ᴼᵃ
𝐁[ᶜᶜ, ᴼᵃ] = sᶜᶜ⁻ᴼᵃ
δ𝐁[ᶜᶜ, ᴼᵃ] = TriangularDist(-0.10, -0.04, -0.07)

# --- Climate change → Stratospheric Ozone Depletion ---
Δxᶜᶜ⁻ˢᵒᵈ = (369 - 280) / (350 - 280)   # Normalised current climate‐change control variable based on CO₂ levels
Δyᶜᶜ⁻ˢᵒᵈ = -0.079               # Central estimate of change in stratospheric ozone depletion due to CC
sᶜᶜ⁻ˢᵒᵈ = Δyᶜᶜ⁻ˢᵒᵈ / Δxᶜᶜ⁻ˢᵒᵈ
𝐁[ᶜᶜ, ˢᵒᵈ] = sᶜᶜ⁻ˢᵒᵈ
δ𝐁[ᶜᶜ, ˢᵒᵈ] = Normal(-0.06, 0.03)

# --- Climate change → Biogeochemical Flows ---
Δxᶜᶜ⁻ᴮᶜᶠ = 2.0      # Normalised current climate change control variable
Δyᶜᶜ⁻ᴮᶜᶠ = 0.38   # Central estimate of change in biogeochemical flows due to CC (0.19 * 2.0)
sᶜᶜ⁻ᴮᶜᶠ = Δyᶜᶜ⁻ᴮᶜᶠ / Δxᶜᶜ⁻ᴮᶜᶠ
𝐁[ᶜᶜ, ᴮᶜᶠ] = sᶜᶜ⁻ᴮᶜᶠ
δ𝐁[ᶜᶜ, ᴮᶜᶠ] = Normal(0.19, 0.003)

# --- Biosphere integrity (land) → Climate change ---
Δxᴮᴵˡ⁻ᶜᶜ = 1.0    # Normalised loss of biosphere integrity (land)
Δyᴮᴵˡ⁻ᶜᶜ = 0.22   # Central estimate of change in climate due to BI land (0.22 * 1.0)
sᴮᴵˡ⁻ᶜᶜ = Δyᴮᴵˡ⁻ᶜᶜ / Δxᴮᴵˡ⁻ᶜᶜ
𝐁[ᴮᴵˡ, ᶜᶜ] = sᴮᴵˡ⁻ᶜᶜ
δ𝐁[ᴮᴵˡ, ᶜᶜ] = TriangularDist(0.18, 0.26, 0.22)

# --- Biosphere integrity (land) → Ocean Acidification ---
Δxᴮᴵˡ⁻ᴼᵃ = 1.0    # Normalised loss of land biosphere integrity (Δx = 1.0)
Δyᴮᴵˡ⁻ᴼᵃ = 0.08   # Central estimate of change in ocean acidification due to BI land (0.08)
sᴮᴵˡ⁻ᴼᵃ = Δyᴮᴵˡ⁻ᴼᵃ / Δxᴮᴵˡ⁻ᴼᵃ
𝐁[ᴮᴵˡ, ᴼᵃ] = sᴮᴵˡ⁻ᴼᵃ
δ𝐁[ᴮᴵˡ, ᴼᵃ] = TriangularDist(0.04, 0.12, 0.08)

# --- Biosphere integrity (freshwater) → Ocean Acidification ---
Δxᴮᴵᶠ⁻ᴼᵃ = 1.2    # Normalised loss of biosphere integrity (freshwater)
Δyᴮᴵᶠ⁻ᴼᵃ = 0.042  # Central estimate of change in ocean acidification due to BI freshwater (0.04 * 1.2)
sᴮᴵᶠ⁻ᴼᵃ = Δyᴮᴵᶠ⁻ᴼᵃ / Δxᴮᴵᶠ⁻ᴼᵃ
𝐁[ᴮᴵᶠ, ᴼᵃ] = sᴮᴵᶠ⁻ᴼᵃ
δ𝐁[ᴮᴵᶠ, ᴼᵃ] = TriangularDist(0.02, 0.06, 0.04)

# --- Biosphere integrity (freshwater) → Climate change ---
Δxᴮᴵᶠ⁻ᶜᶜ = 1.2    # Normalised loss of biosphere integrity (freshwater)
Δyᴮᴵᶠ⁻ᶜᶜ = 0.17   # Central estimate of change in climate due to BI freshwater (0.17 * 1.0)
sᴮᴵᶠ⁻ᶜᶜ = Δyᴮᴵᶠ⁻ᶜᶜ / Δxᴮᴵᶠ⁻ᶜᶜ
𝐁[ᴮᴵᶠ, ᶜᶜ] = sᴮᴵᶠ⁻ᶜᶜ
δ𝐁[ᴮᴵᶠ, ᶜᶜ] = TriangularDist(0.10, 0.24, 0.17)

# --- Biosphere integrity (ocean) → Climate Change ---
Δxᴮᴵᴼ⁻ᶜᶜ = 1.0    # Normalised loss of biosphere integrity (ocean)
Δyᴮᴵᴼ⁻ᶜᶜ = 0.15   # Central estimate of change in climate due to BI ocean (0.15 * 1.0)
sᴮᴵᴼ⁻ᶜᶜ = Δyᴮᴵᴼ⁻ᶜᶜ / Δxᴮᴵᴼ⁻ᶜᶜ
𝐁[ᴮᴵᴼ, ᶜᶜ] = sᴮᴵᴼ⁻ᶜᶜ
δ𝐁[ᴮᴵᴼ, ᶜᶜ] = Uniform(0.075, 0.225)

# --- Biosphere integrity (ocean) → Land System Change ---
Δxᴮᴵᴼ⁻ˡˢᶜ = 1.0    # Normalised loss of biosphere integrity (ocean)
Δyᴮᴵᴼ⁻ˡˢᶜ = 0.02   # Central estimate of change in land system change due to BI ocean (0.02 * 1.0)
sᴮᴵᴼ⁻ˡˢᶜ = Δyᴮᴵᴼ⁻ˡˢᶜ / Δxᴮᴵᴼ⁻ˡˢᶜ
𝐁[ᴮᴵᴼ, ˡˢᶜ] = sᴮᴵᴼ⁻ˡˢᶜ
δ𝐁[ᴮᴵᴼ, ˡˢᶜ] = TriangularDist(0.01, 0.05, 0.02)

# --- Biosphere integrity (ocean) → Ocean Acidification ---
Δxᴮᴵᴼ⁻ᴼᵃ = 1.0    # Normalised loss of biosphere integrity (ocean)
Δyᴮᴵᴼ⁻ᴼᵃ = 0.15   # Central estimate of change in ocean acidification due to BI ocean (0.15 * 1.0)
sᴮᴵᴼ⁻ᴼᵃ = Δyᴮᴵᴼ⁻ᴼᵃ / Δxᴮᴵᴼ⁻ᴼᵃ
𝐁[ᴮᴵᴼ, ᴼᵃ] = sᴮᴵᴼ⁻ᴼᵃ
δ𝐁[ᴮᴵᴼ, ᴼᵃ] = TriangularDist(0.10, 0.20, 0.15)

# --- Land system change → Climate change ---
Δxˡˢᶜ⁻ᶜᶜ = 1.5    # Combined biophysical Δx from emissions (0.59) and albedo effects (–0.40)
Δyˡˢᶜ⁻ᶜᶜ = 0.59 - 0.40   # Net change in climate due to land system change
sˡˢᶜ⁻ᶜᶜ = Δyˡˢᶜ⁻ᶜᶜ / Δxˡˢᶜ⁻ᶜᶜ
𝐁[ˡˢᶜ, ᶜᶜ] = sˡˢᶜ⁻ᶜᶜ
δ𝐁[ˡˢᶜ, ᶜᶜ] = TriangularDist(0.07, 0.19, 0.13)

# --- Land system change → Biosphere integrity (land) ---
Δxˡˢᶜ⁻ᴮᴵˡ = 1.5    # Normalised land‐use change control variable (Δx = 1.5)
Δyˡˢᶜ⁻ᴮᴵˡ = 1.2    # Central estimate of change in land biosphere integrity due to LSC (1.2)
sˡˢᶜ⁻ᴮᴵˡ = Δyˡˢᶜ⁻ᴮᴵˡ / Δxˡˢᶜ⁻ᴮᴵˡ
𝐁[ˡˢᶜ, ᴮᴵˡ] = sˡˢᶜ⁻ᴮᴵˡ
δ𝐁[ˡˢᶜ, ᴮᴵˡ] = TriangularDist(0.70, 0.90, 0.80)

# --- Land system change → Biosphere integrity (freshwater) ---
Δxˡˢᶜ⁻ᴮᴵᶠ = 2.4    # Normalised land‐use change control variable
Δyˡˢᶜ⁻ᴮᴵᶠ = 0.2    # Central estimate of change in freshwater biosphere integrity due to LSC (1.0/5)
sˡˢᶜ⁻ᴮᴵᶠ = Δyˡˢᶜ⁻ᴮᴵᶠ / Δxˡˢᶜ⁻ᴮᴵᶠ
𝐁[ˡˢᶜ, ᴮᴵᶠ] = sˡˢᶜ⁻ᴮᴵᶠ
δ𝐁[ˡˢᶜ, ᴮᴵᶠ] = TriangularDist(0.04, 0.12, 0.08)

# --- Land system change → Ocean Acidification ---
Δxˡˢᶜ⁻ᴼᵃ = 1.5    # Normalised land‐use change control variable
Δyˡˢᶜ⁻ᴼᵃ = 0.24   # Central estimate of change in ocean acidification due to LSC (0.16 * 1.5)
sˡˢᶜ⁻ᴼᵃ = Δyˡˢᶜ⁻ᴼᵃ / Δxˡˢᶜ⁻ᴼᵃ
𝐁[ˡˢᶜ, ᴼᵃ] = sˡˢᶜ⁻ᴼᵃ
δ𝐁[ˡˢᶜ, ᴼᵃ] = TriangularDist(0.12, 0.20, 0.16)

# --- Land system change → Freshwater Use ---
Δxˡˢᶜ⁻ᶠʷᵘ = 1.5    # Normalised land‐use change control variable
Δyˡˢᶜ⁻ᶠʷᵘ = -0.11 # Central estimate of change in freshwater use due to LSC (–0.11)
sˡˢᶜ⁻ᶠʷᵘ = Δyˡˢᶜ⁻ᶠʷᵘ / Δxˡˢᶜ⁻ᶠʷᵘ
𝐁[ˡˢᶜ, ᶠʷᵘ] = sˡˢᶜ⁻ᶠʷᵘ
δ𝐁[ˡˢᶜ, ᶠʷᵘ] = TriangularDist(-0.14, -0.07, -0.11)

# --- Biogeochemical flows → Climate Change ---
Δxᴮᶜᶠ⁻ᶜᶜ = 2.3    # Normalised biogeochemical flows control variable
Δyᴮᶜᶠ⁻ᶜᶜ = 0.092  # Central estimate of change in climate due to BCF (0.04 * 2.3)
sᴮᶜᶠ⁻ᶜᶜ = Δyᴮᶜᶠ⁻ᶜᶜ / Δxᴮᶜᶠ⁻ᶜᶜ
𝐁[ᴮᶜᶠ, ᶜᶜ] = sᴮᶜᶠ⁻ᶜᶜ
δ𝐁[ᴮᶜᶠ, ᶜᶜ] = TriangularDist(0.03, 0.05, 0.04)

# --- Biogeochemical flows → Biosphere Integrity (land) ---
Δxᴮᶜᶠ⁻ᴮᴵˡ = 2.3    # Normalised biogeochemical flows control variable
Δyᴮᶜᶠ⁻ᴮᴵˡ = 0.045  # Central estimate of change in land biosphere integrity due to BCF (0.02 * 2.3)
sᴮᶜᶠ⁻ᴮᴵˡ = Δyᴮᶜᶠ⁻ᴮᴵˡ / Δxᴮᶜᶠ⁻ᴮᴵˡ
𝐁[ᴮᶜᶠ, ᴮᴵˡ] = sᴮᶜᶠ⁻ᴮᴵˡ
δ𝐁[ᴮᶜᶠ, ᴮᴵˡ] = TriangularDist(0.01, 0.03, 0.02)

# --- Biogeochemical flows → Ocean Acidification ---
Δxᴮᶜᶠ⁻ᴼᵃ = 2.3    # Normalised biogeochemical flows control variable
Δyᴮᶜᶠ⁻ᴼᵃ = -0.069  # Central estimate of change in ocean acidification due to BCF (-0.03 * 2.3)
sᴮᶜᶠ⁻ᴼᵃ = Δyᴮᶜᶠ⁻ᴼᵃ / Δxᴮᶜᶠ⁻ᴼᵃ
𝐁[ᴮᶜᶠ, ᴼᵃ] = sᴮᶜᶠ⁻ᴼᵃ
δ𝐁[ᴮᶜᶠ, ᴼᵃ] = TriangularDist(-0.05, -0.01, -0.03)

# --- Biogeochemical flows → Aerosol Loading ---
Δxᴮᶜᶠ⁻ᵃᵃˡ = 2.3    # Normalised biogeochemical flows control variable
Δyᴮᶜᶠ⁻ᵃᵃˡ = 0.18   # Central estimate of change in aerosol loading due to BCF (0.10 * 2.3)
sᴮᶜᶠ⁻ᵃᵃˡ = Δyᴮᶜᶠ⁻ᵃᵃˡ / Δxᴮᶜᶠ⁻ᵃᵃˡ
𝐁[ᴮᶜᶠ, ᵃᵃˡ] = sᴮᶜᶠ⁻ᵃᵃˡ
δ𝐁[ᴮᶜᶠ, ᵃᵃˡ] = TriangularDist(0.0, 0.20, 0.10)

# --- Biogeochemical flows → Strat. Ozone Depletion ---
Δxᴮᶜᶠ⁻ˢᵒᵈ = 2.3      # Normalised biogeochemical flows control variable
Δyᴮᶜᶠ⁻ˢᵒᵈ = 0.028    # Central estimate of change in stratospheric ozone depletion due to BCF (0.039 × 0.72)
sᴮᶜᶠ⁻ˢᵒᵈ = Δyᴮᶜᶠ⁻ˢᵒᵈ / Δxᴮᶜᶠ⁻ˢᵒᵈ
𝐁[ᴮᶜᶠ, ˢᵒᵈ] = sᴮᶜᶠ⁻ˢᵒᵈ
δ𝐁[ᴮᶜᶠ, ˢᵒᵈ] = TriangularDist(0.005, 0.02, 0.01)

# --- Ocean Acidification → Climate change ---
Δxᴼᵃ⁻ᶜᶜ = 0.8    # Normalised ocean acidification control variable
Δyᴼᵃ⁻ᶜᶜ = -0.08 # Central estimate of change in climate due to OA (–0.08)
sᴼᵃ⁻ᶜᶜ = Δyᴼᵃ⁻ᶜᶜ / Δxᴼᵃ⁻ᶜᶜ
𝐁[ᴼᵃ, ᶜᶜ] = sᴼᵃ⁻ᶜᶜ
δ𝐁[ᴼᵃ, ᶜᶜ] = TriangularDist(0.08, 0.12, 0.10)

# --- Ocean Acidification → Biosphere Integrity (ocean) ---
Δxᴼᵃ⁻ᴮᴵᴼ = 1.0    # Normalised ocean acidification control variable
Δyᴼᵃ⁻ᴮᴵᴼ = 1.0    # Central estimate of change in ocean biosphere integrity due to OA (1.0)
sᴼᵃ⁻ᴮᴵᴼ = Δyᴼᵃ⁻ᴮᴵᴼ / Δxᴼᵃ⁻ᴮᴵᴼ
𝐁[ᴼᵃ, ᴮᴵᴼ] = sᴼᵃ⁻ᴮᴵᴼ
δ𝐁[ᴼᵃ, ᴮᴵᴼ] = Dirac(1.0)

# --- Freshwater Use → Biosphere Integrity (freshwater) ---
Δxᶠʷᵘ⁻ᴮᴵᶠ = 1.0    # Freshwater use boundary Δx set to the critical depletion threshold
Δyᶠʷᵘ⁻ᴮᴵᶠ = 1.0    # Central estimate of change in freshwater biosphere integrity (1.0)
sᶠʷᵘ⁻ᴮᴵᶠ = Δyᶠʷᵘ⁻ᴮᴵᶠ / Δxᶠʷᵘ⁻ᴮᴵᶠ
𝐁[ᶠʷᵘ, ᴮᴵᶠ] = sᶠʷᵘ⁻ᴮᴵᶠ
δ𝐁[ᶠʷᵘ, ᴮᴵᶠ] = Dirac(1.0)

# --- Aerosol loading → Climate change ---
Δxᵃᵃˡ⁻ᶜᶜ = 1.6    # Normalised current aerosol loading control variable
Δyᵃᵃˡ⁻ᶜᶜ = -0.9   # Central estimate of change in climate due to aerosol loading (–0.9)
sᵃᵃˡ⁻ᶜᶜ = Δyᵃᵃˡ⁻ᶜᶜ / Δxᵃᵃˡ⁻ᶜᶜ
𝐁[ᵃᵃˡ, ᶜᶜ] = sᵃᵃˡ⁻ᶜᶜ
δ𝐁[ᵃᵃˡ, ᶜᶜ] = TriangularDist(-0.70, -0.42, -0.56)

# --- Aerosol loading → Freshwater use ---
Δxᵃᵃˡ⁻ᶠʷᵘ = -1.6   # Normalised change in control variable from current aerosol loading
Δyᵃᵃˡ⁻ᶠʷᵘ = 0.0    # Central estimate (no direct freshwater-use effect)
sᵃᵃˡ⁻ᶠʷᵘ = Δyᵃᵃˡ⁻ᶠʷᵘ / Δxᵃᵃˡ⁻ᶠʷᵘ
𝐁[ᵃᵃˡ, ᶠʷᵘ] = sᵃᵃˡ⁻ᶠʷᵘ
δ𝐁[ᵃᵃˡ, ᶠʷᵘ] = Dirac(0.0)

# --- Stratospheric ozone depletion → Climate change ---
Δxˢᵒᵈ⁻ᶜᶜ = (369 - 280) / (350 - 280)   # Normalised current stratospheric ozone depletion control variable
Δyˢᵒᵈ⁻ᶜᶜ = -0.11                # Central estimate of change in climate due to ozone depletion
sˢᵒᵈ⁻ᶜᶜ = Δyˢᵒᵈ⁻ᶜᶜ / Δxˢᵒᵈ⁻ᶜᶜ
𝐁[ˢᵒᵈ, ᶜᶜ] = sˢᵒᵈ⁻ᶜᶜ
δ𝐁[ˢᵒᵈ, ᶜᶜ] = TriangularDist(-0.21, -0.01, -0.11)
