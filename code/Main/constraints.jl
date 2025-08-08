## Everything is per kg of H₂ producted. So, 0 =  fully constraintd, 1 = unconstrained. 
using CSV,DataFrames,XLSX,Statistics, Interpolations
using LinearAlgebra,SparseArrays, Distributions, KernelDensity
using JLD2,StatsBase

include("../Utils/2_02_utils.jl");
include("./ssp_utils.jl");
@load "../Source data/02_results/2_02_allocated_space/ensemble.jld"


years=2025:5:2050
## We define the production volumes for hydrogen. 
SEʰ²=getVals("Secondary Energy|Hydrogen",df=df)
ṁᵏᵍ=SEʰ².*EJH2_to_kgH2 # mass H2
ṁᴹᵗ=ṁᵏᵍ.*1e-9; # convert to Mt
ṁᴳᵗ=ṁᴹᵗ.*1e-3;

max_ṁᴹᵗ=maximum(ṁᴹᵗ,dims=1)
min_ṁᴹᵗ=minimum(ṁᴹᵗ,dims=1)
med_ṁᴹᵗ=median(ṁᴹᵗ,dims=1)
δṁᴹᵗ= TriangularDist.(min_ṁᴹᵗ, max_ṁᴹᵗ, med_ṁᴹᵗ)

max_ṁᴹᵗ ⊙ min_ṁᴹᵗ




df_h2=filter(row -> row[:Scenario] != "ADVANCE_2020_1.5C-2100" && row[:Scenario] != "ADVANCE_2030_1.5C-2100" && row[:Model] !="POLES ADVANCE" && row[:Model] != "REMIND", df)

df_h2=filter(row -> row[:Scenario] == "SusDev_SSP1-PkBudg900", df)

SEʰ²=getVals("Secondary Energy|Hydrogen",df=df_h2,years=years)
# getVals("Secondary Energy|Hydrogen|Biomass|w/ CC",years=years,df=df_h2,matrix=false)

SEʰ²_BioCss=vcat(getVals("Secondary Energy|Hydrogen|Biomass|w/ CCS",years=years,df=df_h2),
            getVals("Secondary Energy|Hydrogen|Biomass|w/ CC",years=years,df=df_h2))
SEʰ²_Bio = vcat(getVals("Secondary Energy|Hydrogen|Biomass|w/o CCS",years=years,df=df_h2),
            getVals("Secondary Energy|Hydrogen|Biomass|w/ oCC",years=years,df=df_h2))

SEʰ²_ren= getVals("Secondary Energy|Hydrogen|Renewables (incl. Biomass)",years=years,df=df_h2)
SEʰ²_fossil= getVals("Secondary Energy|Hydrogen|Fossil|w/o CCS",years=years,df=df_h2)
SEʰ²_electric= getVals("Secondary Energy|Hydrogen|Electricity",years=years,df=df_h2)
        

c_electricity_h2= (SEʰ²_electric ⊘ SEʰ²)
max_c_electricity_h2=maximum(c_electricity_h2,dims=1)
min_c_electricity_h2=minimum(c_electricity_h2,dims=1)
med_c_electricity_h2=median(c_electricity_h2,dims=1)
δc_electricity_h2= TriangularDist.(min_c_electricity_h2, max_c_electricity_h2, med_c_electricity_h2)

c_BioCss_h2= (SEʰ²_BioCss ⊘ SEʰ²)
max_c_BioCss_h2=maximum(c_BioCss_h2,dims=1)
min_c_BioCss_h2=minimum(c_BioCss_h2,dims=1)
med_c_BioCss_h2=median(c_BioCss_h2,dims=1)
δc_BioCss_h2= TriangularDist.(min_c_BioCss_h2, max_c_BioCss_h2, med_c_BioCss_h2)

c_Bio_h2= (SEʰ²_Bio ⊘ SEʰ²)
max_c_Bio_h2=maximum(c_Bio_h2,dims=1)
min_c_Bio_h2=minimum(c_Bio_h2,dims=1)
med_c_Bio_h2=median(c_Bio_h2,dims=1)
δc_Bio_h2= TriangularDist.(min_c_Bio_h2, max_c_Bio_h2, med_c_Bio_h2)

c_fossil_h2= (SEʰ²_fossil ⊘ SEʰ²)
max_c_fossil_h2=maximum(c_fossil_h2,dims=1)
min_c_fossil_h2=minimum(c_fossil_h2,dims=1)
med_c_fossil_h2=median(c_fossil_h2,dims=1)
δc_fossil_h2= TriangularDist.(min_c_fossil_h2, max_c_fossil_h2, med_c_fossil_h2)

c_ren_h2= (SEʰ²_ren ⊘ SEʰ²)
max_c_ren_h2=maximum(c_ren_h2,dims=1)
min_c_ren_h2=minimum(c_ren_h2,dims=1)
med_c_ren_h2=median(c_ren_h2,dims=1)
δc_ren_h2= TriangularDist.(min_c_ren_h2, max_c_ren_h2, med_c_ren_h2)

medians=[vcat(median.(rand.(δc_electricity_h2,10000),dims=1)...) ⊙ 100,
            vcat(median.(rand.(δc_BioCss_h2,10000),dims=1)...) ⊙ 100,
            vcat(median.(rand.(δc_Bio_h2,10000),dims=1)...) ⊙ 100,
            vcat(median.(rand.(δc_fossil_h2,10000),dims=1)...) ⊙ 100,
            vcat(median.(rand.(δc_ren_h2,10000),dims=1)...) ⊙ 100,
        ]

q05s=[ quantile(cat(rand.(δc_electricity_h2,10000)...,dims=2),0.05,dims=1) ⊙ 100,
         quantile(cat(rand.(δc_BioCss_h2,10000)...,dims=2),0.05,dims=1) ⊙ 100,
         quantile(cat(rand.(δc_Bio_h2,10000)...,dims=2),0.05,dims=1) ⊙ 100,
                quantile(cat(rand.(δc_fossil_h2,10000)...,dims=2),0.05,dims=1) ⊙ 100,
                quantile(cat(rand.(δc_ren_h2,10000)...,dims=2),0.05,dims=1) ⊙ 100,   
      ]

q95s=[ quantile(cat(rand.(δc_electricity_h2,10000)...,dims=2),0.95,dims=1) ⊙ 100,
         quantile(cat(rand.(δc_BioCss_h2,10000)...,dims=2),0.95,dims=1) ⊙ 100,
         quantile(cat(rand.(δc_Bio_h2,10000)...,dims=2),0.95,dims=1) ⊙ 100,
                quantile(cat(rand.(δc_fossil_h2,10000)...,dims=2),0.95,dims=1) ⊙ 100,
                quantile(cat(rand.(δc_ren_h2,10000)...,dims=2),0.95,dims=1) ⊙ 100,
      ]




titles=["Electrolytic H₂ production share",
        "Biomass w/ CCS share in H₂ production",
        "Biomass w/o CCS share in H₂ production",
        "Fossil w/o CCS share in H₂ production",
        "Renewables share in H₂ production",
        ] 


fig, axs = plt.subplots(2,3,figsize=(10, 5.5),sharex=true)
        for i ∈ 1:5
            axs[i].plot(years, medians[i]', lw=2, label="Median")
            axs[i].fill_between(years, q05s[i], q95s[i], alpha=0.2, label="5-95% range")
            axs[i].set_title(titles[i], fontproperties=font_prop_labels)

        end
        for i in 1:3
            axs[i].set_ylabel("% of production", fontproperties=font_prop_labels)
        end
        # axs[8].set_xlabel("Electricity share %", fontproperties=font_prop_labels)
        # axs[1].legend(frameon=false)
        fig.tight_layout()
        plt.savefig("../Source data/02_results/4_00_constrains/electricity_constraints.svg", dpi=800, bbox_inches="tight",transparent=true)
        display(fig)
        plt.close("all")


### electricity constrains % of future electrical mix
    SEᵉ= vcat(getVals("Secondary Energy|Electricity",years=years),getVals("SE|Electricity",years=years))
    c_biomass_electricity = (getVals("Secondary Energy|Electricity|Biomass",years=years) ⊘ SEᵉ)
    max_c_biomass_electricity=maximum(c_biomass_electricity,dims=1)
    min_c_biomass_electricity=minimum(c_biomass_electricity,dims=1)
    med_c_biomass_electricity=median(c_biomass_electricity,dims=1)
    δc_biomass_electricity= TriangularDist.(min_c_biomass_electricity, max_c_biomass_electricity, med_c_biomass_electricity)

    c_gas_electricity = (getVals("Secondary Energy|Electricity|Gas",years=years) ⊘ SEᵉ)
    max_c_gas_electricity=maximum(c_gas_electricity,dims=1)
    min_c_gas_electricity=minimum(c_gas_electricity,dims=1)
    med_c_gas_electricity=median(c_gas_electricity,dims=1)
    δc_gas_electricity= TriangularDist.(min_c_gas_electricity, max_c_gas_electricity, med_c_gas_electricity)

    c_gas_electricity_CC = (getVals("Secondary Energy|Electricity|Gas|w/ CCS",years=years) ⊘ SEᵉ)
    max_c_gas_electricity_CC=maximum(c_gas_electricity_CC,dims=1)
    min_c_gas_electricity_CC=minimum(c_gas_electricity_CC,dims=1)
    med_c_gas_electricity_CC=median(c_gas_electricity_CC,dims=1)
    δc_gas_electricity_CC= TriangularDist.(min_c_gas_electricity_CC, max_c_gas_electricity_CC, med_c_gas_electricity_CC)

    c_gas_electricity_noCC = (getVals("Secondary Energy|Electricity|Gas|w/o CCS",years=years) ⊘ SEᵉ)
    max_c_gas_electricity_noCC=maximum(c_gas_electricity_noCC,dims=1)
    min_c_gas_electricity_noCC=minimum(c_gas_electricity_noCC,dims=1)
    med_c_gas_electricity_noCC=median(c_gas_electricity_noCC,dims=1)
    δc_gas_electricity_noCC= TriangularDist.(min_c_gas_electricity_noCC, max_c_gas_electricity_noCC, med_c_gas_electricity_noCC)

    c_coal_electricity = (getVals("Secondary Energy|Electricity|Coal",years=years) ⊘ SEᵉ)
    max_c_coal_electricity=maximum(c_coal_electricity,dims=1)
    min_c_coal_electricity=minimum(c_coal_electricity,dims=1)
    med_c_coal_electricity=median(c_coal_electricity,dims=1)
    δc_coal_electricity= TriangularDist.(min_c_coal_electricity, max_c_coal_electricity, med_c_coal_electricity)

    c_hydro_electricity = (getVals("Secondary Energy|Electricity|Hydro",years=years) ⊘ SEᵉ)
    max_c_hydro_electricity=maximum(c_hydro_electricity,dims=1)
    min_c_hydro_electricity=minimum(c_hydro_electricity,dims=1)
    med_c_hydro_electricity=median(c_hydro_electricity,dims=1)
    δc_hydro_electricity= TriangularDist.(min_c_hydro_electricity, max_c_hydro_electricity, med_c_hydro_electricity)

    c_nuclear_electricity = (getVals("Secondary Energy|Electricity|Nuclear",years=years) ⊘ SEᵉ)
    max_c_nuclear_electricity=maximum(c_nuclear_electricity,dims=1)
    min_c_nuclear_electricity=minimum(c_nuclear_electricity,dims=1)
    med_c_nuclear_electricity=median(c_nuclear_electricity,dims=1)
    δc_nuclear_electricity= TriangularDist.(min_c_nuclear_electricity, max_c_nuclear_electricity, med_c_nuclear_electricity)

    c_wind_electricity = (getVals("Secondary Energy|Electricity|Wind",years=years) ⊘ SEᵉ)
    max_c_wind_electricity=maximum(c_wind_electricity,dims=1)
    min_c_wind_electricity=minimum(c_wind_electricity,dims=1)
    med_c_wind_electricity=median(c_wind_electricity,dims=1)
    δc_wind_electricity= TriangularDist.(min_c_wind_electricity, max_c_wind_electricity, med_c_wind_electricity)

    c_solar_electricity = (getVals("Secondary Energy|Electricity|Solar",years=years) ⊘ SEᵉ)
    max_c_solar_electricity=maximum(c_solar_electricity,dims=1)
    min_c_solar_electricity=minimum(c_solar_electricity,dims=1)
    med_c_solar_electricity=median(c_solar_electricity,dims=1)
    δc_solar_electricity= TriangularDist.(min_c_solar_electricity, max_c_solar_electricity, med_c_solar_electricity)

    c_solar_PV_electricity = (getVals("Secondary Energy|Electricity|Solar|PV",years=years) ⊘ SEᵉ)
    max_c_solar_PV_electricity=maximum(c_solar_PV_electricity,dims=1)
    min_c_solar_PV_electricity=minimum(c_solar_PV_electricity,dims=1)
    med_c_solar_PV_electricity=median(c_solar_PV_electricity,dims=1)
    δc_solar_PV_electricity= TriangularDist.(min_c_solar_PV_electricity, max_c_solar_PV_electricity, med_c_solar_PV_electricity)

    c_CSP_electricity = (getVals("Secondary Energy|Electricity|Solar|CSP",years=years) ⊘ SEᵉ)
    max_c_CSP_electricity=maximum(c_CSP_electricity,dims=1)
    min_c_CSP_electricity=minimum(c_CSP_electricity,dims=1)
    med_c_CSP_electricity=median(c_CSP_electricity,dims=1)
    δc_CSP_electricity= TriangularDist.(min_c_CSP_electricity, max_c_CSP_electricity, med_c_CSP_electricity)

    # c_oil_electricity = (getVals("Secondary Energy|Electricity|Oil") ⊘ getVals("Secondary Energy"))
    #c_geothermal_electricity = (getVals("Secondary Energy|Electricity|Geothermal") ⊘ getVals("Secondary Energy"))

    @save "../Source data/02_results/4_00_constrains/electricity_constraints.jld" δc_biomass_electricity δc_gas_electricity_CC δc_gas_electricity_noCC δc_coal_electricity δc_hydro_electricity δc_nuclear_electricity δc_wind_electricity δc_solar_electricity δc_solar_PV_electricity δc_CSP_electricity


    medians=[vcat(median.(rand.(δc_biomass_electricity,10000),dims=1)...).*100,
        vcat(median.(rand.(δc_gas_electricity_CC,10000),dims=1)...).*100,
        vcat(median.(rand.(δc_gas_electricity_noCC,10000),dims=1)...).*100,
        vcat(median.(rand.(δc_coal_electricity,10000),dims=1)...).*100,
        vcat(median.(rand.(δc_hydro_electricity,10000),dims=1)...).*100,
        vcat(median.(rand.(δc_nuclear_electricity,10000),dims=1)...).*100,
        vcat(median.(rand.(δc_wind_electricity,10000),dims=1)...).*100,
        vcat(median.(rand.(δc_solar_electricity,10000),dims=1)...).*100,]


    q05s=[quantile(cat(rand.(δc_biomass_electricity,10000)...,dims=2),0.05,dims=1).*100,
            quantile(cat(rand.(δc_gas_electricity_CC,10000)...,dims=2),0.05,dims=1).*100,
            quantile(cat(rand.(δc_gas_electricity_noCC,10000)...,dims=2),0.05,dims=1).*100,
            quantile(cat(rand.(δc_coal_electricity,10000)...,dims=2),0.05,dims=1).*100,
            quantile(cat(rand.(δc_hydro_electricity,10000)...,dims=2),0.05,dims=1).*100,
            quantile(cat(rand.(δc_nuclear_electricity,10000)...,dims=2),0.05,dims=1).*100,
            quantile(cat(rand.(δc_wind_electricity,10000)...,dims=2),0.05,dims=1).*100,
            quantile(cat(rand.(δc_solar_electricity,10000)...,dims=2),0.05,dims=1).*100,]

    q95s=[quantile(cat(rand.(δc_biomass_electricity,10000)...,dims=2),0.95,dims=1).*100,
            quantile(cat(rand.(δc_gas_electricity_CC,10000)...,dims=2),0.95,dims=1).*100,
            quantile(cat(rand.(δc_gas_electricity_noCC,10000)...,dims=2),0.95,dims=1).*100,
            quantile(cat(rand.(δc_coal_electricity,10000)...,dims=2),0.95,dims=1).*100,
            quantile(cat(rand.(δc_hydro_electricity,10000)...,dims=2),0.95,dims=1).*100,
            quantile(cat(rand.(δc_nuclear_electricity,10000)...,dims=2),0.95,dims=1).*100,
            quantile(cat(rand.(δc_wind_electricity,10000)...,dims=2),0.95,dims=1).*100,
            quantile(cat(rand.(δc_solar_electricity,10000)...,dims=2),0.95,dims=1).*100,]


    fig, axs = plt.subplots(4,2, figsize=(9, 9),sharex=true)
        for i ∈ 1:8
            axs[i].plot(years, medians[i], lw=2, label="Median")
            axs[i].fill_between(years, q05s[i], q95s[i], alpha=0.2, label="5-95% range")
            axs[i].set_title(titles[i], fontproperties=font_prop_labels)

        end
        for i in 1:4
            axs[i].set_ylabel("% of production", fontproperties=font_prop_labels)
        end
        # axs[8].set_xlabel("Electricity share %", fontproperties=font_prop_labels)
        axs[1].legend(frameon=false)
        fig.tight_layout()
        plt.savefig("../Source data/02_results/4_00_constrains/electricity_constraints.svg", dpi=800, bbox_inches="tight",transparent=true)
        display(fig)
        plt.close("all")


    sims=[
        rand.(δc_biomass_electricity,100000).*100
        rand.(δc_gas_electricity_CC,100000).*100
        rand.(δc_gas_electricity_noCC,100000).*100
        rand.(δc_coal_electricity,100000).*100
        rand.(δc_hydro_electricity,100000).*100
        rand.(δc_nuclear_electricity,100000).*100
        rand.(δc_wind_electricity,100000).*100
        rand.(δc_solar_electricity,100000).*100
        ]

        titles=[
                "Biomass",
                "Gas w/CC",
                "Gas w/o CC",
                "Coal",
                "Hydro",
                "Nuclear",
                "Wind",
                "Solar",]

        fig, axs = plt.subplots(4,2, figsize=(9, 9))
        for i ∈ 1:8
            for y in (2025:5:2050).-2024
                data= collect(sims[i,y])
                axs[i].hist(data, bins=300,density=true, alpha=0.5,edgecolor="none", histtype="stepfilled", lw=1.5)
                kd = kde(data)
                axs[i].plot(kd.x,kd.density, lw=2, label="years $(y+2024)") 
                axs[i].axvline(median(sims[i,y]), color="k", linestyle="--",lw=0.2)
                axs[i].set_title(titles[i], fontproperties=font_prop_labels)
            end
        end
        for i in 1:4
            axs[i].set_ylabel("Density", fontproperties=font_prop_labels)
        end
        axs[4].set_xlabel("Electricity share %", fontproperties=font_prop_labels)
        axs[8].set_xlabel("Electricity share %", fontproperties=font_prop_labels)
        axs[8].legend(frameon=false)
        fig.tight_layout()
        plt.savefig("../Source data/02_results/4_00_constrains/electricity_constraints.svg", dpi=800, bbox_inches="tight",transparent=true)
        display(fig)
        plt.close("all")
        

        fig, axs = plt.subplots(4,2, figsize=(9, 9))
        for i ∈ 1:8
            for y in (2025:5:2050).-2024
                data= collect(sims[i,y])
                axs[i].hist(data, bins=300,density=true, alpha=0.5,edgecolor="none", histtype="stepfilled", lw=1.5)
                kd = kde(data)
                axs[i].plot(kd.x,kd.density, lw=2, label="years $(y+2024)") 
                axs[i].axvline(median(sims[i,y]), color="k", linestyle="--",lw=0.2)
                axs[i].set_title(titles[i], fontproperties=font_prop_labels)
            end
        end
        for i in 1:4
            axs[i].set_ylabel("Density", fontproperties=font_prop_labels)
        end
        axs[4].set_xlabel("Electricity share %", fontproperties=font_prop_labels)
        axs[8].set_xlabel("Electricity share %", fontproperties=font_prop_labels)
        axs[8].legend(frameon=false)
        fig.tight_layout()
        plt.savefig("../Source data/02_results/4_00_constrains/electricity_constraints.svg", dpi=800, bbox_inches="tight",transparent=true)
        display(fig)
        plt.close("all")
## end



fig, axs = plt.subplots()
years=2025:5:2050
year_index=years.-2019 
ṁᴹᵗq05=quantile(ṁᴹᵗ[:,year_index],0.05,dims=1)'
ṁᴹᵗq25=quantile(ṁᴹᵗ[:,year_index],0.25,dims=1)'
ṁᴹᵗq50=median(ṁᴹᵗ[:,year_index],dims=1)'
ṁᴹᵗq75=quantile(ṁᴹᵗ[:,year_index],0.75,dims=1)'
ṁᴹᵗq95=quantile(ṁᴹᵗ[:,year_index],0.95,dims=1)'
# axs.plot(years,ṁᴹᵗ[:,year_index]',linewidth=2,color="grey",alpha=0.05)
axs.plot(years,ṁᴹᵗq50,linewidth=2,color="k",label="Model ensemble")
axs.fill_between(x=years, y1=ṁᴹᵗq05, y2=ṁᴹᵗq95, color="grey",linewidth=0, alpha=0.1) #85% proba
axs.fill_between(x=years, y1=ṁᴹᵗq25, y2=ṁᴹᵗq75, color="grey",linewidth=0, alpha=0.3) #70% proba
axs.set_xlim(2025, 2050)
axs.set_ylabel("Hydrogen production [MtH₂]",fontproperties=font_prop_labels)
axs.axhline(0, color="k", linewidth=0.5)
display(plt.gcf())
plt.close("all")