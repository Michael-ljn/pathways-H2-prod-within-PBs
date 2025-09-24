# **0. Initialisation**
using CSV,DataFrames,XLSX,Statistics, Interpolations
using LinearAlgebra,SparseArrays, Distributions, KernelDensity
using JLD2
import Statistics: quantile
using Logging
global_logger(NullLogger())
include("Utils/2_02_utils.jl");
xr = pyimport("xarray");
function quantile(a::Matrix{Float64}, q::Float64; dims::Int64)
    return mapslices(x -> quantile(x, q), a; dims=dims) |> vec
end

### Target setting
target=2.25 #W/m² by 2100

## We make this initial filter based on the AR6 report - A.III.I.11 Comparison of Mitigation and Removal Measures Represented by Models that Contributed Mitigation Scenarios to the Assessment - Table 7 | Overview of demand- and supply-side mitigation and removal measures in the energy, transport, building, industry and AFOLU sectors, as stated by contributing modelling teams to the AR6 database.

## models with a comprhensive hydrogen production pathways (explicit and endogenous):
accepted_mods=["REMIND","MESSAGEix-GLOBIOM","POLES",
            "IMAGE","PROMETHEUS","TIAM","REmap",
            "COFFEE","EPPA","McKinsey","GCAM","GMM"]

## rejected scenarios based on insufficient data granularity.
rejected_scenarios=["EMF33",
                    "CD-LINKS",
                    "SSP1-19",
                    "SSP2-19",
                    "SSP5-19",
                    "R_MAC_35_n8",
                    "R_MAC_30_n8",
                    "EN_NPi2020_200f",
                    "EN_NPi2020_300f",
                    "EN_NPi2020_400f",
                    "SSP2_openres_lc_120",
                    "SSP2_openres_lc_CB400",
                    "SSP2_openres_lc_CB450",
                    "SSP2_openres_lc_CB500",
                    "SSP2_openres_lc_CB550",
                    "SSP2_openres_lc_CB600",
                    "EMF30_ClimPolicy",
                    "EMF30_ClimPolicy+SLCF",
                    "EMF30_Slower-to-faster",
                    "EMF30_Slower-to-faster+SLCF",
                    "EMF30_Slower-to-faster+SLCF+HFC"]

df = AR6database_formating(target; accepted_models=accepted_mods, rejected_scenarios=rejected_scenarios);

getModel(df)

rmd_df=filter(s -> s[:Scenario] == "SSP1-PkBudg500" ||
                    s[:Scenario] == "SSP2EU-PkBudg500" ||
                    s[:Scenario] == "SSP5-PkBudg500",df);



getVals("Secondary Energy|Electricity|Wind",df=df)./getVals("Secondary Energy|Electricity|Solar",df=df)

# **1. Future hydrogen production**
SEʰ²=getVals("Secondary Energy|Hydrogen",df=df)
ṁᵏᵍ=SEʰ².*EJH2_to_kgH2 # mass H2
ṁᴹᵗ=ṁᵏᵍ.*1e-9; # convert to Mt
ṁᴳᵗ=ṁᴹᵗ.*1e-3;

fig, axs = plt.subplots(figsize=(5,3))
years=2025:5:2050
year_index=years.-2019 
ṁᴹᵗq05=quantile(ṁᴹᵗ[:,year_index],0.05,dims=1)'
ṁᴹᵗq25=quantile(ṁᴹᵗ[:,year_index],0.25,dims=1)'
ṁᴹᵗq50=median(ṁᴹᵗ[:,year_index],dims=1)'
ṁᴹᵗq75=quantile(ṁᴹᵗ[:,year_index],0.75,dims=1)'
ṁᴹᵗq95=quantile(ṁᴹᵗ[:,year_index],0.95,dims=1)'
# axs.plot(years,ṁᴹᵗ[:,year_index]',linewidth=2,color="blue",alpha=0.05)
axs.plot(years,ṁᴹᵗq50,linewidth=2,color="blue",label="Model ensemble")
axs.fill_between(x=years, y1=ṁᴹᵗq05, y2=ṁᴹᵗq95, color="skyblue",linewidth=0, alpha=0.1) #85% proba
axs.fill_between(x=years, y1=ṁᴹᵗq25, y2=ṁᴹᵗq75, color="skyblue",linewidth=0, alpha=0.3) #70% proba
axs.set_xlim(2025, 2050)
axs.set_ylabel("Hydrogen production [MtH₂]",fontproperties=font_prop_labels)
axs.axhline(0, color="k", linewidth=0.5)
# plt.savefig("hydrogen_production.svg", dpi=300, bbox_inches="tight",transparent=true)
display(plt.gcf())
plt.close("all")

# **2. Utilitarian allocation factor for hydrogen production**

Emi=getVals("Emissions|CO2|Gross",df=df);
Emiˢᵉ=getVals("Emissions|CO2|Gross|Energy|Supply",df=df);
αᵉᵐⁱ=Emiˢᵉ./Emi;

SE=getVals("Secondary Energy",df=df)
αˢᵉ=SEʰ²./SE;
α=αᵉᵐⁱ.*αˢᵉ
αᵏᵍ=α./ṁᵏᵍ;
αᴹᵗ=α./ṁᴹᵗ;
αᴳᵗ=α./ṁᴳᵗ;

# **3. Climate change scenario variables**
## **3.1. Data gathering**
fair_ds = xr.open_dataset("/Users/mickael/Library/CloudStorage/OneDrive-UNSW/Research/Publications/Journal articles/1_Natcoms/Submission/Source data/01_input/FAIR/climate_data.nc")

GSTA_fair=fair_ds.GSTA.median(dim="config").sel(layer=0,scenario="ssp119",timebounds=(2015:1:2105).-1)
GSTA_fair_10yr_avg = GSTA_fair.rolling(timebounds=50, center=true).mean()
EFR_fair= fair_ds.ERF.median(dim="config").sel(scenario="ssp119",timebounds=(2020:1:2100).-1)
EFR_CO2_fair= fair_ds.CO2_erf.median(dim="config").sel(scenario="ssp119",timebounds=(2020:1:2100).-1)
atCO2_fair= fair_ds.atco2.median(dim="config").sel(scenario="ssp119",timebounds=(2020:1:2100).-1);

## Data from the Annex III of the Intergovernmental Panel On Climate Change (Ipcc) (2023) Climate Change 2021 – The Physical Science Basis: Working Group I Contribution to the Sixth Assessment Report of the Intergovernmental Panel on Climate Change. 1st edn. Cambridge University Press. Available at: https://doi.org/10.1017/9781009157896.
hist_years_erf =[1750, 1850, 1900, 1910, 1920, 1930, 1940, 1950, 1960, 1970, 1980, 1990, 2000, 2010, 2015, 2019]
hist_years_ppm = [
    1750, 1850, 1860, 1870, 1880, 1890, 1900, 1905, 1910, 1915, 1920, 1925, 1930, 1935,
    1940, 1945, 1950, 1955, 1960, 1961, 1962, 1963, 1964, 1965, 1966, 1967,
    1994, 1995, 1996, 1997, 1998, 1999, 2000, 2001, 2002, 2003, 2004, 2005,
    2006, 2007, 2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019
]
ssp19_years2500 = [2020, 2030, 2040, 2050, 2060, 2070, 2080, 2090, 2100, 2200, 2300, 2400, 2500]
ssp19_years = [2020, 2030, 2040, 2050, 2060, 2070, 2080, 2090, 2100]

hist_ppm = [
    278.3, 285.5, 286.8, 288.4, 290.4, 293.3, 296.4, 298.0, 300.0, 302.5, 304.8, 306.3, 307.1, 308.6,
    311.7, 312.7, 313.1, 314.6, 316.8, 317.5, 318.2, 318.8, 319.5, 320.0, 321.0, 321.6,
    358.2, 360.0, 361.8, 362.5, 365.5, 367.6, 368.8, 370.4, 372.4, 375.0, 376.8, 378.8,
    381.0, 382.7, 384.8, 386.3, 388.6, 390.5, 392.5, 395.2, 397.1, 399.4, 402.9, 405.0, 407.4, 409.9
]
ssp19_ppm2500 =   [414,  434,  440,  438,  431,  424,  415,  405,  394,  343,  342,  339,  337]
ssp19_ppm =   [414,  434,  440,  438,  431,  424,  415,  405,  394]
ssp126_ppm = [414, 440, 458, 469, 474, 473, 467, 457, 446, 403, 396, 389, 384]

hist_erf = [0.3, 0.33, 0.34 ,.3, 0.43, 0.48, 0.52, 0.59, 0.54, 0.42, 0.86, 1.42, 2.02, 2.23, 2.61, 2.84]
ssp19_erf = [2.81, 3.20, 3.18, 3.05, 2.88, 2.76, 2.64, 2.48, 2.33, 1.58, 1.49, 1.42, 1.38]
ssp26_erf = [2.80, 3.21, 3.48, 3.58, 3.58, 3.54, 3.42, 3.25, 3.10, 2.50, 2.30, 2.19, 2.11];
ssp19_erfCO2 =   [2.22,2.49,2.56,2.53,2.45,2.35,2.23,2.09,1.92];

GSTA=getVals("AR6 climate diagnostics|Surface Temperature (GSAT)|FaIRv1.6.2|50.0th Percentile",df=df)
RF=getVals("AR6 climate diagnostics|Effective Radiative Forcing|FaIRv1.6.2|50.0th Percentile",df=df);
GSTA_rmd=getVals("Temperature|Global Mean",df=rmd_df);
Emi_rmd=getVals("Emissions|CO2",df=rmd_df).*1e9;

α₀ = 0.2173
α = [0.2240, 0.2824, 0.2763]
τ = [394.4, 36.54, 4.304]
∑=sum
IRF_CO₂(t)= α₀*t + ∑([αᵢ * τᵢ * (1 - exp(-t/ τᵢ)) for (αᵢ, τᵢ) in zip(α, τ)])

function RF_CO₂(impact,period)

    radiative_efficiency_ppb = 1.33e-5  # W/m2/ppb; 2019 background co2 concentration; IPCC AR6 Table 7.15
    
    # for conversion from ppb to kg-CO2
    M_co2 = 44.01  # g/mol
    M_air = 28.97  # g/mol, dry air
    m_atmosphere = 5.135e18  # kg [Trenberth and Smith, 2005]

    radiative_efficiency_kg = radiative_efficiency_ppb * (M_air / M_co2) * 1e9 / m_atmosphere  # W/m2/kg-CO2
    
    decay_multipliers = radiative_efficiency_kg * diff(IRF_CO₂.(period)) #reduction of 1 year here 80
    years_period=length(period)-1
    
    decay_matrix=zeros(years_period,years_period)
    for i in 1:1:years_period
        decay_matrix[i,i:end]=decay_multipliers[1:end+1-i]
    end
    
    return  decay_matrix.*impact[1:end-1]

end
function Conc_CO₂(impact,period)
    
    # for conversion from ppb to kg-CO2
    M_co2 = 44.01  # g/mol
    M_air = 28.97  # g/mol, dry air
    m_atmosphere = 5.135e18  # kg [Trenberth and Smith, 2005]

    concentration_per_kg =  (M_air / M_co2) * 1e9 / m_atmosphere  # W/m2/kg-CO2
    decay_multipliers = concentration_per_kg * diff(IRF_CO₂.(period)) #reduction of 1 year here 80
    years_period=length(period)-1
    
    decay_matrix=zeros(years_period,years_period)
    for i in 1:1:years_period
        decay_matrix[i,i:end]=decay_multipliers[1:end+1-i]
    end
    
    return  decay_matrix.*impact[1:end-1].*1e-3#ppm

end

Emi=getVals("Emissions|CO2",df=df).*1e9
years=2020:1:2100
period=years.-2019

## CO2 cocnentration
decay_concentration=vcat([sum(Conc_CO₂(Emi[ssp,period],period),dims=1).+409.9 for ssp in 1:size(Emi,1)]...)
decay_concentration_rmd=vcat([sum(Conc_CO₂(Emi_rmd[ssp,period],period),dims=1).+409.9 for ssp in 1:3]...)

decay_concentration05=quantile(decay_concentration,0.05,dims=1)
decay_concentration25=quantile(decay_concentration,0.25,dims=1)
decay_concentration50=quantile(decay_concentration,0.5,dims=1)
decay_concentration75=quantile(decay_concentration,0.75,dims=1)
decay_concentration95=quantile(decay_concentration,0.95,dims=1);


## Radiative forcing
decayforcing= vcat([sum(RF_CO₂(Emi[ssp,period],period),dims=1) for ssp in 1:size(Emi,1)]...).+2.16
decayforcing_rmd= vcat([sum(RF_CO₂(Emi_rmd[ssp,period],period),dims=1) for ssp in 1:3]...).+2.16

decayforcing05=quantile(decayforcing,0.05,dims=1)
decayforcing25=quantile(decayforcing,0.25,dims=1)
decayforcing50=quantile(decayforcing,0.5,dims=1)
decayforcing75=quantile(decayforcing,0.75,dims=1)
decayforcing95=quantile(decayforcing,0.95,dims=1);

############ Global Surface Air Temperature Anomaly (GSTA) ############
TA=fair_ds.GSTA.sel(scenario="ssp119",layer=0)
TA26=fair_ds.GSTA.sel(scenario="ssp126",layer=0)
TAq05=TA.quantile(0.05, dim="config")
TAq16=TA.quantile(0.16, dim="config")
TAq84=TA.quantile(0.84, dim="config")
TAq95=TA.quantile(0.95, dim="config")
TAq50=TA.median(axis=1)
TAq50ssp126=TA26.median(axis=1)
TAmin=TA.min(dim="config")
TAmax=TA.max(dim="config")

############ Atmospheric CO2 concentration ############
CO2_conc=fair_ds.atco2.sel(scenario="ssp119")
CO2_conc26=fair_ds.atco2.sel(scenario="ssp126")
CO2_concq05=CO2_conc.quantile(0.05, dim="config")
CO2_concq16=CO2_conc.quantile(0.16, dim="config")
CO2_concq84=CO2_conc.quantile(0.84, dim="config")
CO2_concq95=CO2_conc.quantile(0.95, dim="config")
CO2_concq50=CO2_conc.median(axis=1)
CO2_concq50ssp126=CO2_conc26.median(axis=1)
CO2_concmin=CO2_conc.min(dim="config")
CO2_concmax=CO2_conc.max(dim="config")
period=fair_ds.timebounds

############ Effective Radiative Forcing (ERF) ############
ERF=fair_ds.ERF.sel(scenario="ssp119")
ERF26=fair_ds.ERF.sel(scenario="ssp126")
ERFq05=ERF.quantile(0.05, dim="config")
ERFq16=ERF.quantile(0.16, dim="config")
ERFq84=ERF.quantile(0.84, dim="config")
ERFq95=ERF.quantile(0.95, dim="config")
ERFq50=ERF.median(axis=1)
ERFq50ssp126=ERF26.median(axis=1)
ERFmin=ERF.min(dim="config")
ERFmax=ERF.max(dim="config");

## **3.2. Ensemble validations**
erf_fairCO2=fair_ds.CO2_erf.sel(scenario="ssp119",timebounds=(2020:1:2100).-1)
EFR_CO2_fairq05=erf_fairCO2.quantile(0.05, dim="config")
EFR_CO2_fairq95=erf_fairCO2.quantile(0.95, dim="config")
times=EFR_CO2_fairq95.timebounds;
co2_df = CSV.read("data/co2.csv", DataFrame);

fig, axs = plt.subplots(1, 2,figsize=(10, 7))
years = 2020:1:2100
year_index= years.-2019

axs[1].plot((2020:1:2099),decayforcing50',color="k",label="AR6 ensemble", lw=2)
EFR_CO2_fair.plot(ax=axs[1],x="timebounds", color="goldenrod", label="FaIR: SSP1-1.9",zorder=0, lw=2)
axs[1].fill_between(EFR_CO2_fairq95.timebounds,EFR_CO2_fairq05,EFR_CO2_fairq95,color="goldenrod",alpha=0.4,lw=0)
axs[1].fill_between((2020:1:2099),decayforcing05,decayforcing95,color="grey",alpha=0.1, lw=0.2)
axs[1].fill_between((2020:1:2099),decayforcing25,decayforcing75,color="grey",alpha=0.3, lw=0.2)
axs[1].set_ylabel("CO₂ ERF W/m²", fontproperties=font_prop_labels)
axs[1].plot((2020:1:2099),median(decayforcing_rmd[1:3,:],dims=1)',label="premise ensemble", lw=2)
axs[1].scatter(ssp19_years,ssp19_erfCO2,color="goldenrod",marker="x")
axs[1].axhline(2.25,color="black",linestyle="--",xmax=1)
axs[1].set_xlim(2020, 2100)
axs[1].set_ylim(1.5, 3.65)
axs[1].set_xlabel("")
axs[1].set_title("(a)", fontproperties=font_prop)
axs[1].axhline([1.9],color="black",linestyle="--",xmax=1)



axs[2].plot((2020:1:2099),decay_concentration50', color="k",label="AR6 ensemble", lw=2,zorder=5)
axs[2].plot((2020:1:2099),median(decay_concentration_rmd[1:3,:],dims=1)',label="premise ensemble", lw=2)
atCO2_fair.plot(ax=axs[2],x="timebounds", color="goldenrod", label="FaIR: SSP1-1.9",zorder=0, lw=2,alpha=0.6)
axs[2].scatter(co2_df.year, co2_df.co2_ppm,marker="x",color="red", label="hist_NOAA",zorder=5)
axs[2].scatter(ssp19_years,ssp19_ppm,color="goldenrod",marker="x",zorder=5,label="AR6-ssp119")


axs[2].fill_between(x=(2020:1:2099), y1=decay_concentration05, y2=decay_concentration95, color="grey",alpha=0.1, linewidth=0,zorder=4)
axs[2].fill_between(x=(2020:1:2099), y1=decay_concentration25, y2=decay_concentration75, color="grey",alpha=0.3, linewidth=0,zorder=4)
axs[2].fill_between(x=(2020:1:2099), y1=(minimum(decay_concentration,dims=1)|>vec)', 
                                            y2=(maximum(decay_concentration,dims=1)|>vec)', 
                                            color="grey",alpha=0.05, linewidth=0)
axs[2].fill_between(period, CO2_concq05, CO2_concq95, alpha=0.4, color="goldenrod",linewidth=0,zorder=0)

axs[2].set_title("(b)", fontproperties=font_prop)
axs[2].set_xlabel("")
axs[2].set_ylabel("ppmCO₂", fontproperties=font_prop_labels)
axs[2].legend(frameon=false,prop=font_prop_labels)
axs[2].set_xlim(2020, 2100)
axs[2].set_ylim(360, 480)
fig.tight_layout()
fig.savefig(respath*"scenario_climate_vars.svg", bbox_inches="tight",transparent=true)
fig.savefig(respath*"scenario_climate_vars.png", dpi=800 ,bbox_inches="tight",transparent=true)
display(plt.gcf())
plt.close("all")

## **3.3. Fig.2**
box_stats = [ #data from Johnson et al. 2025
    Dict(
        "med" => 25,
        "q1" => 13.5,
        "q3" => 90,
        "whislo" => 7.7,
        "whishi" => 208.7,
    ),Dict(
        "med" => 75,
        "q1" => 49.6,
        "q3" => 146,
        "whislo" => 40.4,
        "whishi" => 388,
    ),Dict(
        "med" => 227.583,
        "q1" => 114.680,
        "q3" => 458.337,
        "whislo" => 89.328,
        "whishi" => 659.332,
    )
]

A,B,C = plt.figure(figsize=(10, 5.5),facecolor="none",layout="constrained").subplot_mosaic(
                                        "ABC",
                                        width_ratios=[1,1,1])
axs=[B,A,C]
axs=[i[2] for i in axs]
years=2025:5:2050
year_index=years.-2019 
for (ax,mat,l) in  zip(axs[2:2],[ṁᴹᵗ],["MtH₂/yr"])
    mins = (minimum(mat, dims=1)|>vec)[year_index]
    maxs = (maximum(mat, dims=1)|>vec)[year_index]
    q05 = quantile(mat, 0.05; dims=1)[year_index]
    q25 = quantile(mat, 0.25; dims=1)[year_index]
    q50 = median(mat; dims=1)[year_index]
    q75 = quantile(mat, 0.75; dims=1)[year_index]
    q95 = quantile(mat, 0.95; dims=1)[year_index]

    ax.plot(years, q50,color="k",label="Model ensemble",lw=2)
    ax.plot(years, mat[:,year_index]',color="k",alpha=0.05,zorder=0)
    # ax.fill_between(x=years, y1=mins, y2=maxs, color="grey",linewidth=0, alpha=0.1)
    ax.fill_between(x=years, y1=q05, y2=q95, color="grey",linewidth=0, alpha=0.2)
    ax.fill_between(x=years, y1=q25, y2=q75, color="grey",linewidth=0, alpha=0.3)
    ax.set_ylabel(l, fontproperties=font_prop)
    ax.tick_params(axis="both", direction="in")
end

IEA_years=[2025,2030,2035,2040,2045,2050]
IEA_vals=[137.841672,201.3247223,294.6324469,387.955364,457.7382688, 527.5227996]#.*EJH2_to_kgH2*1.e-9
axs[2].plot(IEA_years,IEA_vals,label="IEA NZE 2050",color="k",linestyle="--",lw=2)


axs[2].set_ylabel("MtH₂/yr", fontproperties=font_prop)
# axs[1].set_ylim(-15, 1200)
axs[2].set_title("(b)", fontproperties=font_prop)

axs[2].bxp(box_stats,positions=[2030,2040,2050], showfliers=false,label="(Johnson et al. 2025)",widths=2,medianprops=Dict("linewidth"=>2))


axs[2].scatter([2025],[0.95],zorder=5,marker="x",color="goldenrod",s=50,label="hist-(Johnson et al. 2025)")
axs[2].set_ylim(-15, 600)
axs[2].set_xlim(2025, 2050)

# allocated space per kgH2 using utilitarian principle.
axs[3].set_title("(c)",fontproperties=font_prop_labels)
αᵏᵍmins = [minimum(filter(!isnan, αᵏᵍ[:,j])) for j in 1:size(αᵏᵍ,2)][year_index]
αᵏᵍmaxs = [maximum(filter(!isnan, αᵏᵍ[:,j])) for j in 1:size(αᵏᵍ,2)][year_index]
αq(a,q) = [quantile(filter(!isnan, a[:,j]), q ) for j in 1:size(a,2)][year_index]
αᵏᵍq05 , αᵏᵍq95 = αq(αᵏᵍ,0.05),αq(αᵏᵍ,0.95) #5-95th (90%) IQR 
αᵏᵍq25 , αᵏᵍq75 = αq(αᵏᵍ,0.25),αq(αᵏᵍ,0.75) #25-75th (50%) IQR
αᵏᵍq50 = αq(αᵏᵍ,0.50)

αᴳᵗq05, αᴳᵗq95 = αq(αᴳᵗ,0.05),αq(αᴳᵗ,0.95) #5-95th (90%) IQR
αᴳᵗq25 , αᴳᵗq75 = αq(αᴳᵗ,0.25),αq(αᴳᵗ,0.75) #25-75th (50%) IQR
αᴳᵗq50 = αq(αᴳᵗ,0.50)



# axs[2].plot(years,βᵏᵍ_rmd[:,year_index]'.*100,linewidth=2,color="grey",alpha=0.05,zorder=0,label="PkBudg")
axs[3].plot(years,αᴳᵗ[:,year_index]'.*100,linewidth=2,color="grey",alpha=0.04,zorder=0,label="PkBudg")
axs[3].plot(years,αᴳᵗq50 .*100 ,label="Median",linewidth=2, color="k")
axs[3].fill_between(x=years, y1=αᴳᵗq05.*100, y2=αᴳᵗq95.*100, color="grey",linewidth=0, alpha=0.2) #85% proba
axs[3].fill_between(x=years, y1=αᴳᵗq25.*100, y2=αᴳᵗq75.*100, color="grey",linewidth=0, alpha=0.3) #70% proba
axs[3].set_xlim(2025, 2050)
axs[3].set_ylabel("%SOS/yr/GtH₂",fontproperties=font_prop_labels)

bluee=(0.19215686274509805, 0.5098039215686274, 0.7411764705882353, 1.0)
CO2_concq50.plot(ax=axs[1], label="FaIR: SSP1-19", color="seagreen")
CO2_concq50ssp126.plot(ax=axs[1], label="FaIR: SSP1-26", color="darkgoldenrod",zorder=0)
axs[1].plot((2020:1:2099),decay_concentration50', color="k",label="Model ensemble",zorder=5)
axs[1].set_title("(a)",fontproperties=font_prop_titles)
axs[1].fill_between(period, CO2_concmin, CO2_concmax, alpha=0.1, color="seagreen")
axs[1].fill_between(period, CO2_concq05, CO2_concq95, alpha=0.4, color="seagreen")
axs[1].fill_between(period, CO2_concq16, CO2_concq84, alpha=0.25, color="seagreen")
axs[1].scatter(ssp19_years2500, ssp19_ppm2500,marker="x",color="seagreen", label="AR6-ssp119",zorder=3,s=15)
axs[1].scatter(ssp19_years2500, ssp126_ppm,marker=".",edgecolor="goldenrod",color="none", label="AR6-ssp126",zorder=3)
axs[1].scatter(co2_df.year, co2_df.co2_ppm,marker="x",color="grey", label="hist_NOAA",zorder=5,s=15)
axs[1].scatter(hist_years_ppm, hist_ppm,marker=".",color="orangered", label="AR6-hist",zorder=3,s=15)
axs[1].axhline(350, ls=":", color="k",linewidth=2,zorder=0)
axs[1].axhline(278, ls=":",color="#3787c0",linewidth=2,zorder=0)
axs[1].axhline(450, ls=":", color="goldenrod",linewidth=2,zorder=0)

axs[1].set_xlim(period[1], period[-1])
axs[1].set_ylim(270, 488)
axs[1].set_ylabel("ppmCO₂",fontproperties=font_prop_labels)
axs[1].set_xlabel("")
axs[1].axvline(2100, ls="--", color="k", linewidth=0.5)
axs[1].axvline(2020, ls="--", color="k", linewidth=0.5)
# axs[3].set_xlim(1750, 2500)
axs[1].annotate("Upper end of\nzone of\n increasing\nrisk", xy=(1800, 453), xytext=(1800, 453), fontproperties=font_prop_ticks,ha="left")
axs[1].annotate("Planetary\nboundary", xy=(2490, 353), xytext=(2490, 353), fontsize=8, fontproperties=font_prop_ticks,ha="right")
axs[1].annotate("Natural\nbackground", xy=(2490, 280), xytext=(2490, 280), fontsize=8, fontproperties=font_prop_ticks,ha="right")
axs[1].legend(loc="upper right",frameon=false,prop=font_prop_ticks)#

axs[2].yaxis.set_major_locator(tkr.MaxNLocator(integer=true, nbins=5))
axs[3].yaxis.set_major_locator(tkr.MaxNLocator(integer=false, nbins=5))


handles, labels = axs[2].get_legend_handles_labels()
axs[2].legend(handles, labels, frameon=false, loc="upper center", bbox_to_anchor=(0.43, 0.97), ncol=1, prop=font_prop)
for ax in axs
    for ticklabel in ax.get_xticklabels()
        ticklabel.set_fontproperties(font_prop_ticks)
        end

    for ticklabel in ax.get_yticklabels()
        ticklabel.set_fontproperties(font_prop_ticks)
    end
end
plt.savefig(respath*"fig2.svg", bbox_inches="tight",transparent=true)
plt.savefig(respath*"fig2.png", dpi=800,bbox_inches="tight",transparent=true)
plt.savefig(respath*"fig2nt.png", dpi=800,bbox_inches="tight",transparent=false)
display(plt.gcf())
plt.close("all")

# **4. Allocated safe operating space**

sos=load("../Source data/02_results/2_01_global_space/data_SOS.jld2")
𝚫𝐗ᴾᵇ,𝚫𝐗ᴰ,units,catnames=sos["𝚫𝐗ᴾᵇ"],sos["𝚫𝐗ᴰ"],sos["units"],sos["control_var"];

## First we need to create a set of years that fit the dimension of our assessment. 
all_years = 2020:1:2100
assessment_years = 2025:5:2050
years_to_remove=setdiff(all_years,assessment_years)
years=setdiff(all_years,years_to_remove);


𝚨max=maximum(αᵏᵍ[:,years.-2019],dims=1)
𝚨min=minimum(αᵏᵍ[:,years.-2019],dims=1)
𝚨q50=median(αᵏᵍ[:,years.-2019],dims=1)
δ𝛀ᴾᵇ=𝚫𝐗ᴾᵇ.*TriangularDist.(𝚨min, 𝚨max, 𝚨q50);
𝛀ᴾᵇ=𝚫𝐗ᴾᵇ*mode.(TriangularDist.(𝚨min, 𝚨max, 𝚨q50))
δ𝛀ᴰ=𝚫𝐗ᴰ.*TriangularDist.(𝚨min, 𝚨max, 𝚨q50);
𝛀ᴰ=𝚫𝐗ᴰ*mode.(TriangularDist.(𝚨min, 𝚨max, 𝚨q50));

# **5.Result export**

@save respath*"aSOS.jld" 𝛀ᴾᵇ δ𝛀ᴾᵇ 𝛀ᴰ δ𝛀ᴰ
@save respath*"ensemble.jld" df

function writetable(table::DataFrame; worksheet="Model_Scenarios",workbook::String="output.xlsx")
    if isfile(workbook)
        XLSX.openxlsx(workbook, mode="rw") do xf
                ws = XLSX.addsheet!(xf, worksheet)
                XLSX.writetable!(ws, Tables.columntable(table))
        end
    else
            XLSX.writetable(workbook, Tables.columntable(table), sheetname=worksheet)
    end
end
function writetable(tables::Vector{DataFrame},worksheets::Vector{String};workbook::String="output.xlsx")
    for (sheetname,table) in zip(worksheets,tables)
        if isfile(workbook)
            XLSX.openxlsx(workbook, mode="rw") do xf
                if sheetname in XLSX.sheetnames(xf)
                    XLSX.deletesheet!(xf, sheetname) # not working
                end
                    ws = XLSX.addsheet!(xf, sheetname)
                    XLSX.writetable!(ws, Tables.columntable(table))
            end
        else
                XLSX.writetable(workbook, Tables.columntable(table), sheetname=sheetname)
        end
    end
end

if isfile(respath*"ensemble.xlsx")
    rm(respath*"ensemble.xlsx")
    writetable(df,workbook=respath*"ensemble.xlsx")
else    
    writetable(df,workbook=respath*"ensemble.xlsx")
end

## **Fig2a**
co2_resdf=DataFrame(hcat([(2020:1:2099),decay_concentration05,decay_concentration50,decay_concentration95]...),
            [:Year;:CO2_ppm_05; :CO2_ppm_50; :CO2_ppm_95])

rmd_res=hcat((2020:1:2099),quantile(decay_concentration_rmd[1:3,:],0.05,dims=1),median(decay_concentration_rmd[1:3,:],dims=1)',quantile(decay_concentration_rmd[1:3,:],0.95,dims=1))

co2_resdf_premise=DataFrame(rmd_res,[:Year;:CO2_ppm_05;:CO2_ppm_50;:CO2_ppm_95])

FaIRdf=DataFrame(hcat(CO2_conc.timebounds.values,CO2_conc.quantile(0.05, dim="config").values,CO2_conc.median(axis=1).values,CO2_conc.quantile(0.95, dim="config").values),
            [:Year;:CO2_ppm_05; :CO2_ppm_50; :CO2_ppm_95])

if isfile(respath*"Fig2a.xlsx")
    rm(respath*"Fig2a.xlsx")
end
writetable(co2_resdf; worksheet="AR6_ensemble", workbook=respath*"Fig2a.xlsx")
writetable(co2_resdf_premise; worksheet="premise_ensemble", workbook=respath*"Fig2a.xlsx")
writetable(co2_df; worksheet="NOAA", workbook=respath*"Fig2a.xlsx")
writetable(FaIRdf; worksheet="FaIR", workbook=respath*"Fig2a.xlsx")

## **Fig2b**
h2demanddf=DataFrame(hcat(2025:5:2050,ṁᴹᵗq05',ṁᴹᵗq25',ṁᴹᵗq50,ṁᴹᵗq75',ṁᴹᵗq95'),
            [:Year;:H2_Mt_05; :H2_Mt_25; :H2_Mt_50; :H2_Mt_75; :H2_Mt_95]) 

function CAGR(v0,v1; y=25)
    cagr = (v1 / v0)^(1 / y) - 1
    return cagr
end

h2cagr=hcat([[CAGR(o[1],i,y=b)*100 for (i,b) in zip(o[1:end],[0,5,10,15,20,25])] for o in [ṁᴹᵗq05',ṁᴹᵗq25',ṁᴹᵗq50,ṁᴹᵗq75',ṁᴹᵗq95']]...)
h2cagrdf=DataFrame(hcat(2025:5:2050,h2cagr),
            [:Year;:H2_CAGR_05; :H2_CAGR_25; :H2_CAGR_50; :H2_CAGR_75; :H2_CAGR_95])
if isfile(respath*"Fig2b.xlsx")
    rm(respath*"Fig2b.xlsx")
end         
writetable(h2demanddf; worksheet="hydrogen demand", workbook=respath*"Fig2b.xlsx")
writetable(h2cagrdf; worksheet="hydrogen CAGR", workbook=respath*"Fig2b.xlsx")

## **Fig2c**
asosdf=DataFrame(hcat(years,hcat(αᴳᵗq05,αᴳᵗq25,αᴳᵗq50,αᴳᵗq75,αᴳᵗq95).*100),
            [:Year;:SOS_per_GtH2_05; :SOS_per_GtH2_25; :SOS_per_GtH2_50; :SOS_per_GtH2_75; :SOS_per_GtH2_95])
if isfile(respath*"Fig2c.xlsx")
    rm(respath*"Fig2c.xlsx")
end
writetable(asosdf; worksheet="allocated SOS", workbook=respath*"Fig2c.xlsx")
