## Everything is per kg of H₂ producted. So, 0 =  fully constraintd, 1 = unconstrained. 
using CSV,DataFrames,XLSX,Statistics, Interpolations
using LinearAlgebra,SparseArrays, Distributions, KernelDensity
using JLD2,StatsBase
include("../../Utils/2_02_utils.jl");
include("../utils/ssp_utils.jl");

## load data.
@load "../Source data/02_results/2_02_allocated_space/ensemble.jld"
include("iea_data.jl");

df

unique(df[!,["Variable"]])
writetable(unique(df[!,["Variable"]]))

aa=getVals("Efficiency|Hydrogen|Electricity",df=df,matrix=false)
## IEA data used to deaggregate the hydrogen production

IEA_data=Matrix(hcat([iea_NG, iea_NGccs, iea_Coal, iea_Coalccs, iea_Bio, iea_Bioccs, iea_PEM, iea_AE, iea_SOEC]...)')[:,2:end]

IEA_fossil=IEA_data[1:4,:] ⊘ sum(IEA_data[1:4,:],dims=1)
IEA_REN=IEA_data[5:6,:] ⊘ sum(IEA_data[5:6,:],dims=1)
IEA_electricity=IEA_data[7:9,:] ⊘ sum(IEA_data[7:9,:],dims=1)


years=2025:5:2050

## Hydrogen production constraints

    df_h2=filter(row -> row[:Scenario] != "ADVANCE_2020_1.5C-2100" && row[:Scenario] != "ADVANCE_2030_1.5C-2100" && row[:Model] !="POLES ADVANCE" && row[:Model] != "REMIND", df)

    SEʰ²=getVals("Secondary Energy|Hydrogen",df=df_h2,years=years)
    # getVals("Secondary Energy|Hydrogen|Biomass|w/ CC",years=years,df=df_h2,matrix=false)
    SEʰ²_ren= getVals("Secondary Energy|Hydrogen|Renewables (incl. Biomass)",years=years,df=df_h2)
    SEʰ²_fossil= getVals("Secondary Energy|Hydrogen|Fossil|w/o CCS",years=years,df=df_h2)
    SEʰ²_electric= getVals("Secondary Energy|Hydrogen|Electricity",years=years,df=df_h2)
            
    c_electricity_h2= (SEʰ²_electric ⊘ SEʰ²)
    max_c_electricity_h2=maximum(c_electricity_h2,dims=1)
    min_c_electricity_h2=minimum(c_electricity_h2,dims=1)
    med_c_electricity_h2=median(c_electricity_h2,dims=1)
    δc_electricity_h2= TriangularDist.(min_c_electricity_h2, max_c_electricity_h2, med_c_electricity_h2)
    δc_PEM=[a*b for (a,b) in zip(δc_electricity_h2,IEA_electricity[1,:])]
    δc_AE=[a*b for (a,b) in zip(δc_electricity_h2,IEA_electricity[2,:])]
    δc_SOEC=[a*b for (a,b) in zip(δc_electricity_h2,IEA_electricity[3,:])]

    

    c_fossil_h2= (SEʰ²_fossil ⊘ SEʰ²)
    max_c_fossil_h2=maximum(c_fossil_h2,dims=1)
    min_c_fossil_h2=minimum(c_fossil_h2,dims=1)
    med_c_fossil_h2=median(c_fossil_h2,dims=1)
    δc_fossil_h2= TriangularDist.(min_c_fossil_h2, max_c_fossil_h2, med_c_fossil_h2)
    δc_NG= [a*b for (a,b) in zip(δc_fossil_h2,IEA_fossil[1,:])]
    δc_NGccs= [a*b for (a,b) in zip(δc_fossil_h2,IEA_fossil[2,:])]
    δc_Coal= [a*b for (a,b) in zip(δc_fossil_h2,IEA_fossil[3,:])]
    δc_Coalccs= [a*b for (a,b) in zip(δc_fossil_h2,IEA_fossil[4,:])]

    c_ren_h2= (SEʰ²_ren ⊘ SEʰ²)
    max_c_ren_h2=maximum(c_ren_h2,dims=1)
    min_c_ren_h2=minimum(c_ren_h2,dims=1)
    med_c_ren_h2=median(c_ren_h2,dims=1)
    δc_ren_h2= TriangularDist.(min_c_ren_h2, max_c_ren_h2, med_c_ren_h2)
    δc_biomass_h2=[a*b for (a,b) in zip(δc_ren_h2,IEA_REN[1,:])]
    δc_bioccs_h2°=[a*b for (a,b) in zip(δc_ren_h2[3:end],IEA_REN[2,3:end])]    
    δc_bioccs_h2=Matrix{UnivariateDistribution}(undef, 1,6)
    δc_bioccs_h2.=Dirac(0)
    δc_bioccs_h2[3:end]= δc_bioccs_h2°


    medians=[
        vcat(median.(rand.(δc_PEM,10000),dims=1)...).*100,
        vcat(median.(rand.(δc_AE,10000),dims=1)...).*100,
        vcat(median.(rand.(δc_SOEC,10000),dims=1)...).*100,
        vcat(median.(rand.(δc_biomass_h2,10000),dims=1)...).*100,
        vcat(median.(rand.(δc_bioccs_h2,10000),dims=1)...).*100,
        vcat(median.(rand.(δc_NG,10000),dims=1)...).*100,
        vcat(median.(rand.(δc_NGccs,10000),dims=1)...).*100,
        vcat(median.(rand.(δc_Coal,10000),dims=1)...).*100,
        vcat(median.(rand.(δc_Coalccs,10000),dims=1)...).*100,
    ]

    q05s=[ quantile(cat(rand.(δc_PEM,10000)...,dims=2),0.05,dims=1) ⊙ 100,
        quantile(cat(rand.(δc_AE,10000)...,dims=2),0.05,dims=1) ⊙ 100,
        quantile(cat(rand.(δc_SOEC,10000)...,dims=2),0.05,dims=1) ⊙ 100,
        quantile(cat(rand.(δc_biomass_h2,10000)...,dims=2),0.05,dims=1) ⊙ 100,
        quantile(cat(rand.(δc_bioccs_h2,10000)...,dims=2),0.05,dims=1) ⊙ 100,
        quantile(cat(rand.(δc_NG,10000)...,dims=2),0.05,dims=1) ⊙ 100,
        quantile(cat(rand.(δc_NGccs,10000)...,dims=2),0.05,dims=1) ⊙ 100,
        quantile(cat(rand.(δc_Coal,10000)...,dims=2),0.05,dims=1) ⊙ 100,
        quantile(cat(rand.(δc_Coalccs,10000)...,dims=2),0.05,dims=1) ⊙ 100,
        ]

    q95s= [ quantile(cat(rand.(δc_PEM,10000)...,dims=2),0.95,dims=1) ⊙ 100,
        quantile(cat(rand.(δc_AE,10000)...,dims=2),0.95,dims=1) ⊙ 100,
        quantile(cat(rand.(δc_SOEC,10000)...,dims=2),0.95,dims=1) ⊙ 100,
        quantile(cat(rand.(δc_biomass_h2,10000)...,dims=2),0.95,dims=1) ⊙ 100,
        quantile(cat(rand.(δc_bioccs_h2,10000)...,dims=2),0.95,dims=1) ⊙ 100,
        quantile(cat(rand.(δc_NG,10000)...,dims=2),0.95,dims=1) ⊙ 100,
        quantile(cat(rand.(δc_NGccs,10000)...,dims=2),0.95,dims=1) ⊙ 100,
        quantile(cat(rand.(δc_Coal,10000)...,dims=2),0.95,dims=1) ⊙ 100,
        quantile(cat(rand.(δc_Coalccs,10000)...,dims=2),0.95,dims=1) ⊙ 100,
    ]

    ## plotting
        titles=["PEM",
                "Alkaline Electrolysis",
                "Solid Oxide Electrolysis",
                "Biomass",
                "Biomass w/CCS",
                "Natural Gas",
                "Natural Gas w/CCS",
                "Coal",
                "Coal w/CCS",]

        fig, axs = plt.subplots(3,3,figsize=(10, 5.5),sharex=true)
                for i ∈ 1:9
                    axs[i].plot(years, medians[i], lw=2, label="Median")
                    axs[i].fill_between(years, q05s[i], q95s[i], alpha=0.2, label="5-95% range")
                    axs[i].set_title(titles[i], fontproperties=font_prop_labels)

                end
                for i in 1:3
                    axs[i].set_ylabel("% of production", fontproperties=font_prop_labels)
                end
                # axs[8].set_xlabel("Electricity share %", fontproperties=font_prop_labels)
                # axs[1].legend(frameon=false)
                fig.tight_layout()
                plt.savefig("../Source data/02_results/4_00_constrains/hydrogen_constraints.svg", dpi=800, bbox_inches="tight",transparent=true)
                plt.savefig("../Source data/02_results/4_00_constrains/hydrogen_constraints.png", dpi=800, bbox_inches="tight",transparent=true)
                display(fig)
                plt.close("all")
    # end plot

    @save "../Source data/02_results/4_00_constrains/hydrogen_constraints.jld" δc_PEM δc_AE δc_SOEC δc_biomass_h2 δc_bioccs_h2 δc_NG δc_NGccs δc_Coal δc_Coalccs
#end


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
    
    ## export constraints for further analysis.
    @save "../Source data/02_results/4_00_constrains/electricity_constraints.jld" δc_biomass_electricity δc_gas_electricity_CC δc_gas_electricity_noCC δc_coal_electricity δc_hydro_electricity δc_nuclear_electricity δc_wind_electricity δc_solar_electricity δc_solar_PV_electricity δc_CSP_electricity



        # Plotting
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
                plt.savefig("../Source data/02_results/4_00_constrains/electricity_constraints.png", dpi=800, bbox_inches="tight",transparent=true)
                display(fig)
                plt.close("all")
        # end plot
## end



# res=cat([a.*b for (a,b) in zip( rand.(δc_nuclear_electricity,10000),rand.(δc_PEM,10000))
# ]...,dims=2)


# plt.figure(figsize=(10, 5))
# plt.plot(years, median(res,dims=1)', lw=2, label="Median")
# plt.fill_between(years, quantile(res,0.05,dims=1), quantile(res,0.95,dims=1), alpha=0.2, label="5-95% range")
# plt.title("Nuclear + PEM Electrolysis", fontproperties=font_prop_labels)
# plt.ylabel("Electricity share %", fontproperties=font_prop_labels)
# plt.xlabel("Year", fontproperties=font_prop_labels)
# plt.legend(frameon=false)
# plt.tight_layout()
# plt.savefig("../Source data/02_results/4_00_constrains/nuclear_PEM_constraints.svg", dpi=800, bbox_inches="tight",transparent=true)
# plt.savefig("../Source data/02_results/4_00_constrains/nuclear_PEM_constraints.png", dpi=800, bbox_inches="tight",transparent=true)
# display(plt.gcf())
# plt.close("all")
