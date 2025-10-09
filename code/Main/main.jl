# Main script for the publication "Pathways to global hydrogen production within planetary boundaries"
# - Author: Michaël Lejeune⁺[a,b], Sami Kara [a,b],Michael Zwicky Hauschild [d], Rahman Daiyan [b,c], 
# - Code maintainer author⁺ email: m.lejeune@unsw.edu.au
# - Affiliations: 
    ## - a. Sustainability in Manufacturing and Life Cycle Engineering Research Group, School of Mechanical and Manufacturing Engineering, The University of New South Wales, Sydney 2052, Australia. 
    ## - b. Australian Research Council, Training Centre for the Global Hydrogen Economy, Sydney 2052, Australia. 
    ## - c. School of Minerals and Energy Engineering, The University of New South Wales, Sydney 2052, Australia. 
    ## - d. Centre for Absolute Sustainability, Technical University of Denmark, Kgs, Lyngby, Denmark.

# using Revise
module Main
    export Fig3b,Fig3d,Fig3,Fig4,Fig5,Fig6,Fig7,Sfig10,Sfig11,sysconfig,opti,𝖘oil_coal,𝖘lignite_peat,𝖘gas,𝖘ⁿᵘᶜˡᵉᵃʳ,𝖘ᴱᴸ⁻ᵇᶦᵒ,𝖘solar_wind,𝖘hydro_geothermal,𝖘wind,𝐏
    # includes
        include("./init.jl")
        using .optimisation, lce, .TcmUtils
        using JLD2, Distributions, SparseArrays, LinearAlgebra, Statistics, InvertedIndices
        import Statistics:quantile
        function quantile(a::Matrix{Float64}, q::Float64; dims::Int64)
            return mapslices(x -> quantile(x, q), a; dims=dims)|> vec
        end
        function quantile(a::Array{Float64, 3}, q::Float64; dims::Int64)
            return mapslices(x -> quantile(x, q), a; dims=dims)
        end
        @load "./main/modules/pre_optimisation.jld"
        δ𝐜 = OptiData.δ𝐜ᵗ #constrains
        respath=mkpath(config_respath*"/main/")*"/"
    #end
    𝐏2050 = initProject("natcom",model="REMIND",RCP=1.9,SSP=1,year=2050)
    function electricity_sets()
        𝖘ᴱᴴⱽ = getTcmChoices(:electricityHV,𝐏) 
        PV_key=getTcmKey("electricity production, photovoltaic, 570kWp open ground installation, multi-Si","RoW",𝐏)
        𝖘ᴱ=vcat(𝖘ᴱᴴⱽ,[PV_key])
        act_to_tcm=Dict([x.second.act =>x.first for x ∈ pairs(filter(j -> j[1] in 𝖘ᴱ, getTcmAct(𝐏)))]...)
        res_elect_to_tcm = Dict(Symbol(process_names[k]) => v for (k, v) in act_to_tcm if haskey(process_names, k))

        𝖘oil_coal=[res_elect_to_tcm[i] for i in [:E_Oil,:E_Coal_SC,:E_Coal]]
        𝖘lignite_peat=[res_elect_to_tcm[i] for i in [:E_Lignite,:E_Lignite_IGCC,:E_Peat]]
        𝖘gas=[res_elect_to_tcm[i] for i in [:E_Gas_10MW,:E_NGccs,:E_NG]]
        𝖘ⁿᵘᶜˡᵉᵃʳ=[res_elect_to_tcm[i] for i in [:E_Nuclear_PWR,:E_Nuclear_PWR_HWM,:E_Nuclear_BWR]]
        𝖘ᴱᴸ⁻ᵇᶦᵒ=[res_elect_to_tcm[i] for i in [:E_Wood_Future]]
        𝖘solar_wind=[res_elect_to_tcm[i] for i in [:E_PV,:E_Solar_Thermal,:E_Wind_Onshore]]
        𝖘hydro_geothermal=[res_elect_to_tcm[i] for i in [:E_Hydro,:E_Geothermal]]
        𝖘wind=[res_elect_to_tcm[i] for i in [:E_Wind_Onshore]]

        return 𝖘oil_coal,𝖘lignite_peat,𝖘gas,𝖘ⁿᵘᶜˡᵉᵃʳ,𝖘ᴱᴸ⁻ᵇᶦᵒ,𝖘solar_wind,𝖘hydro_geothermal,𝖘wind
    end
    𝖘oil_coal,𝖘lignite_peat,𝖘gas,𝖘ⁿᵘᶜˡᵉᵃʳ,𝖘ᴱᴸ⁻ᵇᶦᵒ,𝖘solar_wind,𝖘hydro_geothermal,𝖘wind= electricity_sets()



    ### Plotting functions

    function Fig3b(ax2;s=s,filename=nothing,savefig=false)
        respath3=mkpath(respath*"/Fig3/")*"/"
        colorsᶠᵒˢˢⁱˡ= colors[[1,3,4]]
        colorsᶠᵒˢˢⁱˡ⁻ᶜᶜˢ= colors[7:8]
        colorsᵉˡᵉᶜᵗʳᵒˡʸˢⁱˢ= colors[17:20]
        colorsᵇᶦᵒ= colors[9:12]

        # 1. Fossil
        fossil = s[𝖘ᶠᵒˢˢⁱˡ,:] ⊙ ṁᴹᵗq50
        fossil_sum= zeros(size(fossil, 2))
        ax2.stackplot(years, fossil_sum; colors=colorsᶠᵒˢˢⁱˡ, lw=1)
        
        for i in 1:size(fossil, 1)
            labs=sum(fossil[i, :]) != 0 ? fossil_names[i] : nothing
            ax2.fill_between(years, fossil_sum, fossil_sum + fossil[i, :], color=colorsᶠᵒˢˢⁱˡ[i], alpha=1,label=labs)

            fossil_sum += fossil[i, :]
        end

        fossil_sum = sum(fossil, dims=1) |> vec
        ax2.plot(years, fossil_sum, color="black", linestyle="-", lw=0.8)


        fossil_ccs = s[𝖘ᶠᵒˢˢⁱˡ⁻ᶜᶜˢ,:] ⊙ ṁᴹᵗq50
        for i in 1:size(fossil_ccs, 1)
            labs=sum(fossil_ccs[i, :]) != 0 ? fossil_ccs_names[i] : nothing
            ax2.fill_between(years, fossil_sum, fossil_sum + fossil_ccs[i, :], color=colorsᶠᵒˢˢⁱˡ⁻ᶜᶜˢ[i], alpha=1,label=labs)
            fossil_sum += fossil_ccs[i, :]
        end
        ax2.plot(years, fossil_sum, color="k", linestyle="-", lw=0.8)

        bio = s[𝖘ᵇᶦᵒ,:] ⊙ ṁᴹᵗq50
        for i in 1:size(bio, 1)
            labs=sum(bio[i, :]) != 0 ? bio_names[i] : nothing
            ax2.fill_between(years, fossil_sum, fossil_sum + bio[i, :], color=colorsᵇᶦᵒ[i], alpha=1, label=labs)
            fossil_sum += bio[i, :]
        end
        ax2.plot(years, fossil_sum, color="k", linestyle="-", lw=0.8)

        electro = s[𝖘ᵉˡᵉᶜᵗʳᵒˡʸˢⁱˢ,:] ⊙ ṁᴹᵗq50
        for i in 1:size(electro, 1)
            labs=sum(electro[i, :]) != 0 ? electrolysis_names[i] : nothing
            ax2.fill_between(years, fossil_sum, fossil_sum + electro[i, :], color=colorsᵉˡᵉᶜᵗʳᵒˡʸˢⁱˢ[i], alpha=1, label=labs)
            fossil_sum += electro[i, :]
        end
        ax2.plot(years, fossil_sum, color="k", linestyle="-", lw=0.8)

        handles, labels = ax2.get_legend_handles_labels()
        ax2.legend(handles, labels, loc="upper left", fontsize=8,frameon=false,prop=font_prop,ncol=2)


        ax2.set_ylabel("MtH₂ yr⁻¹", font_properties=font_prop_labels)
        ax2.set_xlim(years[1], years[end])
        ax2.yaxis.tick_right()
        ax2.yaxis.set_label_position("right")
        ax2.spines["top"].set_visible(false)  
        ax2.spines["left"].set_visible(false)

        
        seth2=vcat(𝖘ᶠᵒˢˢⁱˡ,𝖘ᶠᵒˢˢⁱˡ⁻ᶜᶜˢ,𝖘ᵇᶦᵒ,𝖘ᵉˡᵉᶜᵗʳᵒˡʸˢⁱˢ)

        filn= filename ≠ nothing ? filename*"Fig3b" : "Fig3b"
        if isfile(respath3*filn*".xlsx")
            rm(respath3*filn*".xlsx")
        end
        if savefig
            plt.savefig(respath3*filn*".svg", transparent=true, bbox_inches="tight")
            display(fig)
            plt.close("all")
        end

        dfscaleh2=DataFrame(hcat([getTcmAct(i,𝐏).act for i in seth2],s[seth2,:]),["Processes","2025","2030","2035","2040","2045","2050"])
        writetable(dfscaleh2; workbook=respath3*filn*".xlsx", worksheet="scale of processes")
        dfscaleh2=DataFrame(hcat([getTcmAct(i,𝐏).act for i in seth2],s[seth2,:]⊙ ṁᴹᵗq50),["Processes","2025","2030","2035","2040","2045","2050"])
        writetable(dfscaleh2; workbook=respath3*filn*".xlsx", worksheet="MtH2 per process")
    end

    function Fig3b(;s=s)
        fig, ax2 = plt.subplots(figsize=(5,5))
        colorsᶠᵒˢˢⁱˡ= colors[[1,3,4]]
        colorsᶠᵒˢˢⁱˡ⁻ᶜᶜˢ= colors[7:8]
        colorsᵉˡᵉᶜᵗʳᵒˡʸˢⁱˢ= colors[17:20]
        colorsᵇᶦᵒ= colors[9:12]
            
        # 1. Fossil
        fossil = s[𝖘ᶠᵒˢˢⁱˡ,:] ⊙ ṁᴹᵗq50
        fossil_sum= zeros(size(fossil, 2))
        ax2.stackplot(years, fossil_sum; colors=colorsᶠᵒˢˢⁱˡ, lw=1)
        
        for i in 1:size(fossil, 1)
            labs=sum(fossil[i, :]) != 0 ? fossil_names[i] : nothing
            ax2.fill_between(years, fossil_sum, fossil_sum + fossil[i, :], color=colorsᶠᵒˢˢⁱˡ[i], alpha=1,label=labs)

            fossil_sum += fossil[i, :]
        end

        fossil_sum = sum(fossil, dims=1) |> vec
        ax2.plot(years, fossil_sum, color="black", linestyle="-", lw=0.8)


        fossil_ccs = s[𝖘ᶠᵒˢˢⁱˡ⁻ᶜᶜˢ,:] ⊙ ṁᴹᵗq50
        for i in 1:size(fossil_ccs, 1)
            labs=sum(fossil_ccs[i, :]) != 0 ? fossil_ccs_names[i] : nothing
            ax2.fill_between(years, fossil_sum, fossil_sum + fossil_ccs[i, :], color=colorsᶠᵒˢˢⁱˡ⁻ᶜᶜˢ[i], alpha=1,label=labs)
            fossil_sum += fossil_ccs[i, :]
        end
        ax2.plot(years, fossil_sum, color="k", linestyle="-", lw=0.8)

        bio = s[𝖘ᵇᶦᵒ,:] ⊙ ṁᴹᵗq50
        for i in 1:size(bio, 1)
            labs=sum(bio[i, :]) != 0 ? bio_names[i] : nothing
            ax2.fill_between(years, fossil_sum, fossil_sum + bio[i, :], color=colorsᵇᶦᵒ[i], alpha=1, label=labs)
            fossil_sum += bio[i, :]
        end
        ax2.plot(years, fossil_sum, color="k", linestyle="-", lw=0.8)

        electro = s[𝖘ᵉˡᵉᶜᵗʳᵒˡʸˢⁱˢ,:] ⊙ ṁᴹᵗq50
        for i in 1:size(electro, 1)
            labs=sum(electro[i, :]) != 0 ? electrolysis_names[i] : nothing
            ax2.fill_between(years, fossil_sum, fossil_sum + electro[i, :], color=colorsᵉˡᵉᶜᵗʳᵒˡʸˢⁱˢ[i], alpha=1, label=labs)
            fossil_sum += electro[i, :]
        end
        ax2.plot(years, fossil_sum, color="k", linestyle="-", lw=0.8)

        handles, labels = ax2.get_legend_handles_labels()
        ax2.legend(handles, labels, loc="upper left", fontsize=8,frameon=false,prop=font_prop,ncol=2)


        ax2.set_ylabel("MtH₂ yr⁻¹", font_properties=font_prop_labels)
        ax2.set_xlim(years[1], years[end])
        ax2.yaxis.tick_right()
        ax2.yaxis.set_label_position("right")
        ax2.spines["top"].set_visible(false)  
        ax2.spines["left"].set_visible(false)
        fig.tight_layout()
        display(fig)
        plt.close("all")
    end
    function Fig3d(ax;s=s,filename=nothing,savefig=false)
        respath3=mkpath(respath*"/Fig3/")*"/"





        function electricity_sets()
            𝖘ᴱᴴⱽ = getTcmChoices(:electricityHV,𝐏) 
            PV_key=getTcmKey("electricity production, photovoltaic, 570kWp open ground installation, multi-Si","RoW",𝐏)
            𝖘ᴱ=vcat(𝖘ᴱᴴⱽ,[PV_key])
            act_to_tcm=Dict([x.second.act =>x.first for x ∈ pairs(filter(j -> j[1] in 𝖘ᴱ, getTcmAct(𝐏)))]...)
            res_elect_to_tcm = Dict(Symbol(process_names[k]) => v for (k, v) in act_to_tcm if haskey(process_names, k))

            𝖘oil_coal=[res_elect_to_tcm[i] for i in [:E_Oil,:E_Coal_SC,:E_Coal]]
            𝖘lignite_peat=[res_elect_to_tcm[i] for i in [:E_Lignite,:E_Lignite_IGCC,:E_Peat]]
            𝖘gas=[res_elect_to_tcm[i] for i in [:E_Gas_10MW,:E_NGccs,:E_NG]]
            𝖘ⁿᵘᶜˡᵉᵃʳ=[res_elect_to_tcm[i] for i in [:E_Nuclear_PWR,:E_Nuclear_PWR_HWM,:E_Nuclear_BWR]]
            𝖘ᴱᴸ⁻ᵇᶦᵒ=[res_elect_to_tcm[i] for i in [:E_Wood_Future]]
            𝖘solar_wind=[res_elect_to_tcm[i] for i in [:E_PV,:E_Solar_Thermal,:E_Wind_Onshore]]
            𝖘hydro_geothermal=[res_elect_to_tcm[i] for i in [:E_Hydro,:E_Geothermal]]
            𝖘wind=[res_elect_to_tcm[i] for i in [:E_Wind_Onshore]]

            return 𝖘oil_coal,𝖘lignite_peat,𝖘gas,𝖘ⁿᵘᶜˡᵉᵃʳ,𝖘ᴱᴸ⁻ᵇᶦᵒ,𝖘solar_wind,𝖘hydro_geothermal,𝖘wind
        end
        𝖘oil_coal,𝖘lignite_peat,𝖘gas,𝖘ⁿᵘᶜˡᵉᵃʳ,𝖘ᴱᴸ⁻ᵇᶦᵒ,𝖘solar_wind,𝖘hydro_geothermal,𝖘wind= electricity_sets()


        oil_coal_names=["Oil","Coal"]
        lignite_peat_names=["Lignite","Lignite IGCC","Peat"]
        gas_names=["Gas","NG","NGCC"]
        nuclear_names=["Nuclear PWR","Nuclear PWR HWM","Nuclear BWR"]
        bio_names=["Biomass"]
        solar_wind_names=["PV","Solar Thermal","Wind"]
        hydro_geothermal_names=["Hydro","Geothermal"]
        
        color_oil_coal=colors[2:3]
        color_lignite_peat=colors2[[5,6,7]]
        color_gas=colors[15:17]
        color_nuclear=colors2[9:11]
        color_bio=colors2[16]
        color_solar_wind=colors[10:12]
        color_hydro_geothermal=colors[19:20]

        SEC_oil_coal=s[𝖘oil_coal,:]⊙1e-12 ⊙ ṁᵏᵍq50 #TWh per kgH2
        SEC_lignite_peat=s[𝖘lignite_peat,:]⊙1e-12 ⊙ ṁᵏᵍq50
        SEC_gas=s[𝖘gas,:]⊙1e-12 ⊙ ṁᵏᵍq50
        SEC_nuclear=s[𝖘ⁿᵘᶜˡᵉᵃʳ,:]⊙1e-12 ⊙ ṁᵏᵍq50
        SEC_bio=s[𝖘ᴱᴸ⁻ᵇᶦᵒ,:] ⊙ 1e-12 ⊙ ṁᵏᵍq50
        SEC_solar_wind=s[𝖘solar_wind,:]⊙1e-12 ⊙ ṁᵏᵍq50
        SEC_hydro_geothermal=s[𝖘hydro_geothermal,:]⊙1e-12 ⊙ ṁᵏᵍq50
        

        # 1. Oil & Coal
        oil_coal = SEC_oil_coal
        stack_sum=zeros(size(oil_coal, 2))
        ax.stackplot(years, stack_sum; colors=color_oil_coal, lw=1)

        for i in 1:size(oil_coal, 1)
            labs=sum(oil_coal[i, :]) != 0 ? oil_coal_names[i] : nothing   
            ax.fill_between(years, stack_sum, vec(oil_coal[i, :]), color=color_lignite_peat[i], alpha=1, label=labs)
        end
        stack_sum = sum(oil_coal, dims=1)|> vec
        ax.plot(years, stack_sum', color="black", linestyle="-", lw=0.8)

        # 2. Lignite & Peat
        lignite_peat = SEC_lignite_peat
        vec(stack_sum .+ lignite_peat[1, :])

        for i in 1:size(lignite_peat, 1)
            
            labs=sum(lignite_peat[i, :]) != 0 ? lignite_peat_names[i] : nothing
            
            ax.fill_between(years, stack_sum, vec(stack_sum .+ lignite_peat[i, :]), color=color_lignite_peat[i], alpha=1, label=labs)
            # ax.fill_between(years, stack_sum,  vec(stack_sum .+ lignite_peat[1, :]), color=color_lignite_peat[i], alpha=1, label=lignite_peat_names[i])
            stack_sum .+= lignite_peat[i, :]
        end
        ax.plot(years, stack_sum, color="k", linestyle="-", lw=0.8)

        # 3. Gas
        gas = SEC_gas
        for i in 1:size(gas, 1)
            labs=sum(gas[i, :]) != 0 ? gas_names[i] : nothing
            ax.fill_between(years, stack_sum, stack_sum + gas[i, :], color=color_gas[i], alpha=1, label=labs)
            stack_sum += gas[i, :]
        end
        ax.plot(years, stack_sum, color="k", linestyle="-", lw=0.8)

        # # 4. Nuclear
        nuclear = SEC_nuclear
        for i in 1:size(nuclear, 1)
            labs=sum(nuclear[i, :]) != 0 ? nuclear_names[i] : nothing
            ax.fill_between(years, stack_sum, stack_sum + nuclear[i, :], color=color_nuclear[i], alpha=1, label=labs)
            stack_sum += nuclear[i, :]
        end
        ax.plot(years, stack_sum, color="k", linestyle="-", lw=0.8)

        # # # 5. Bio
        bio = SEC_bio|>vec
        labs=sum(bio) != 0 ? "Biomass" : nothing
        ax.fill_between(years, stack_sum, stack_sum + bio, color=color_bio, alpha=1, label=labs)
        stack_sum += bio
        ax.plot(years, stack_sum, color="k", linestyle="-", lw=0.8)

        # 6. Solar & Wind
        solar_wind = SEC_solar_wind
        for i in 1:size(solar_wind, 1)
            labs=sum(solar_wind[i, :]) != 0 ? solar_wind_names[i] : nothing
            ax.fill_between(years, stack_sum, stack_sum + solar_wind[i, :], color=color_solar_wind[i], alpha=1, label=labs)
            stack_sum += solar_wind[i, :]
        end
        ax.plot(years, stack_sum, color="k", linestyle="-", lw=0.8)

        hydro_geothermal = SEC_hydro_geothermal
        for i in 1:size(hydro_geothermal, 1)
            labs=sum(hydro_geothermal[i, :]) != 0 ? hydro_geothermal_names[i] : nothing
            ax.fill_between(years, stack_sum, stack_sum + hydro_geothermal[i, :], color=color_hydro_geothermal[i], alpha=1, label=labs)
            stack_sum += hydro_geothermal[i, :]
        end
        ax.plot(years, stack_sum, color="k", linestyle="-", lw=0.8)

        # Legend and formatting
        handles, labels = ax.get_legend_handles_labels()
        ax.legend(handles, labels, loc="upper left", fontsize=8, frameon=false, prop=font_prop, ncol=2)

        ax.set_xlim(years[1], years[end])
        ax.set_xlim(years[1], years[end])
        ax.set_ylabel("PWh yr⁻¹", font_properties=font_prop_labels)
        ax.yaxis.tick_right()
        ax.yaxis.set_label_position("right")
        ax.spines["top"].set_visible(false) 
        ax.spines["left"].set_visible(false)

        filn= filename ≠ nothing ? filename*"Fig3d" : "Fig3d"
        if isfile(respath3*filn*".xlsx")
            rm(respath3*filn*".xlsx")
        end

        if savefig
            plt.savefig(respath3*filn*".svg", transparent=true, bbox_inches="tight")
            display(fig)
            plt.close("all")
        end

        setel=vcat(𝖘oil_coal,𝖘lignite_peat,𝖘gas,𝖘ⁿᵘᶜˡᵉᵃʳ,𝖘ᴱᴸ⁻ᵇᶦᵒ,𝖘solar_wind,𝖘hydro_geothermal)

        dfscaleel=DataFrame(hcat([getTcmAct(i,𝐏).act for i in setel],s[setel,:]),["Processes","2025","2030","2035","2040","2045","2050"])
        writetable(dfscaleel; workbook=respath3*filn*".xlsx", worksheet="scale of processes")

        dfscaleel=DataFrame(hcat([getTcmAct(i,𝐏).act for i in setel],s[setel,:] ⊙1e-12 ⊙ ṁᵏᵍq50),["Processes","2025","2030","2035","2040","2045","2050"])

        writetable(dfscaleel; workbook=respath3*filn*".xlsx", worksheet="PWh per process")
    end

    #FIXME: legend labels are not modelled yet.
    """ 
    # Planetary footpring of global hydrogen production
    ## Description
    > This figure shows the planetary footprint of global hydrogen production along with the optimised production pathways to meet the future hydrogen supply. 
    """
    function Fig3(;samples=5000, interactions=true,renewables=true,q=0.95,filename="Fig3",human_interact=false)
        respath3=mkpath(respath*"/Fig3/")*"/"
        rcParams["xtick.top"] = false
        fig = plt.figure(figsize=(11,11))
        ax1 = fig.add_subplot(221, projection="polar")
        ax2 = fig.add_subplot(222)  
        ax3 = fig.add_subplot(223, projection="polar")
        ax4 = fig.add_subplot(224)

            d̄ᴮ⁻ᴾᴮᴵ=opti(interactions=true,
                    stochastic=true,
                    human_interact=human_interact,
                    result_format=:response,
                    full_renewables=renewables,
                    dac=0,
                    h2_leak=0,q=q,samples=samples)


            d̄ᴮ⁻ᴾᴮᴵq05=quantile(d̄ᴮ⁻ᴾᴮᴵ,0.05,dims=2)
            xᴮ⁻ᴾᴮᴵ_plot_05=[reshape(d̄ᴮ⁻ᴾᴮᴵq05,10,6)[:,y] for y in 1:6]
            d̄ᴮ⁻ᴾᴮᴵq50=quantile(d̄ᴮ⁻ᴾᴮᴵ,0.5,dims=2)
            xᴮ⁻ᴾᴮᴵ_plot_50=[reshape(d̄ᴮ⁻ᴾᴮᴵq50,10,6)[:,y] for y in 1:6]
            d̄ᴮ⁻ᴾᴮᴵq95=quantile(d̄ᴮ⁻ᴾᴮᴵ,0.95,dims=2)
            xᴮ⁻ᴾᴮᴵ_plot_95=[reshape(d̄ᴮ⁻ᴾᴮᴵq95,10,6)[:,y] for y in 1:6]
            
            d̄ᴺ⁻ᴾᴮᴵ=opti(interactions=false,
                        stochastic=true,
                        result_format=:response,
                        full_renewables=renewables,
                        human_interact=human_interact,
                        dac=0,
                        q=q,
                        h2_leak=0,samples=samples)

            d̄ᴺ⁻ᴾᴮᴵq05=quantile(d̄ᴺ⁻ᴾᴮᴵ,0.05,dims=2)
            xᴺ⁻ᴾᴮᴵ_plot_05=[reshape(d̄ᴺ⁻ᴾᴮᴵq05,10,6)[:,y] for y in 1:6]
            d̄ᴺ⁻ᴾᴮᴵq50=quantile(d̄ᴺ⁻ᴾᴮᴵ,0.5,dims=2)
            xᴺ⁻ᴾᴮᴵ_plot_50=[reshape(d̄ᴺ⁻ᴾᴮᴵq50,10,6)[:,y] for y in 1:6]
            d̄ᴺ⁻ᴾᴮᴵq95=quantile(d̄ᴺ⁻ᴾᴮᴵ,0.95,dims=2)
            xᴺ⁻ᴾᴮᴵ_plot_95=[reshape(d̄ᴺ⁻ᴾᴮᴵq95,10,6)[:,y] for y in 1:6]


            sᴺ⁻ᴾᴮᴵ=opti(interactions=false,
                        result_format=:scale,
                        full_renewables=renewables,
                        human_interact=human_interact,
                        dac=0,
                        h2_leak=0.0,q=q)|>sparse
        
            sᴮ⁻ᴾᴮᴵ=opti(interactions=true,
                        result_format=:scale,
                        full_renewables=renewables,
                        human_interact=human_interact,
                        dac=0,
                        h2_leak=0.0,q=q)|>sparse

            s = interactions ? sᴮ⁻ᴾᴮᴵ : sᴺ⁻ᴾᴮᴵ

        _,legds=pbplot(xᴺ⁻ᴾᴮᴵ_plot_50,xᴺ⁻ᴾᴮᴵ_plot_95,xᴺ⁻ᴾᴮᴵ_plot_05,categories=categories,
                            legend=["2025", "2030", "2035", "2040", "2045", "2050"], scale=7, minscale=-4, median_lw=0.8,axis=ax1)

        pbplot(xᴮ⁻ᴾᴮᴵ_plot_50,xᴮ⁻ᴾᴮᴵ_plot_95,xᴮ⁻ᴾᴮᴵ_plot_05,categories=categories,
                legend=["2025", "2030", "2035", "2040", "2045", "2050"], scale=7, minscale=-4, median_lw=0.8,axis=ax3)
        Fig3b(ax2,s=s)
        Fig3d(ax4,s=s)

        ax1.legend(handles=legds,loc="upper center",bbox_to_anchor=(0.5,-0.05),prop=font_prop,frameon=false,ncol=6)
        ax1.set_title("(a) No interaction", font_properties=font_prop_titles)
        ax2.set_title("(b)", font_properties=font_prop_titles)
        ax3.set_title("(c) With interactions", font_properties=font_prop_titles)
        ax4.set_title("(d)", font_properties=font_prop_titles)

        for ticklabel in ax2.get_xticklabels()
        ticklabel.set_fontproperties(font_prop_ticks)
        end
        for ticklabel in ax4.get_xticklabels()
            ticklabel.set_fontproperties(font_prop_ticks)
        end
        for ticklabel in ax2.get_yticklabels()
            ticklabel.set_fontproperties(font_prop_ticks)
        end
        for ticklabel in ax4.get_yticklabels()
            ticklabel.set_fontproperties(font_prop_ticks)
        end
        ax2.tick_params(top=false)
        fig.tight_layout()

        if renewables
            fig.savefig(respath3*"Fig3_renewables.svg",transparent=true, bbox_inches="tight")
        else
            fig.savefig(respath3*"Fig3.svg",transparent=true, bbox_inches="tight")
        end
        display(fig)
        plt.close("all")


        ## printing
        if isfile(respath3*"Fig3a.xlsx")
            rm(respath3*"Fig3a.xlsx")
        end
        for (x,name) in zip([xᴺ⁻ᴾᴮᴵ_plot_05,xᴺ⁻ᴾᴮᴵ_plot_50,xᴺ⁻ᴾᴮᴵ_plot_95],["q05","q50","q95"])
            dataf=DataFrame(hcat(categories,hcat(x...)),["Category","2025","2030","2035","2040","2045","2050"])
            writetable(dataf,workbook=respath3*"Fig3a.xlsx",worksheet="no_interactions_"*name);
        end

        if isfile(respath3*"Fig3c.xlsx")
            rm(respath3*"Fig3c.xlsx")
        end
        for (x,name) in zip([xᴮ⁻ᴾᴮᴵ_plot_05,xᴮ⁻ᴾᴮᴵ_plot_50,xᴮ⁻ᴾᴮᴵ_plot_95],["q05","q50","q95"])
            dataf=DataFrame(hcat(categories,hcat(x...)),["Category","2025","2030","2035","2040","2045","2050"])
            writetable(dataf,workbook=respath3*"Fig3c.xlsx",worksheet="interactions_"*name);
        end

    end

    """
    ## Mitigation potentials
    ### Description 
    > Fig(a) 2050 focus, 2 bars on the magnitude and the interactions, with and without.
    > Fig (b) 2050 focus, PB chart with different emission factors, 2 bars comparing interactions and without.
    """
    function Fig4(;samples=5000,human_interact=false)
        respath4=mkpath(respath*"/Fig4/")*"/"
        if isfile(respath4*"Fig4.xlsx")
                rm(respath4*"Fig4.xlsx")
        end 
        rcParams["xtick.top"] = false
        fig = plt.figure(figsize=(11,11))
        ax1 = fig.add_subplot(221, projection="polar")
        ax2 = fig.add_subplot(222, projection="polar")
        # ax3 = fig.add_subplot(223, projection="polar")
        # ax4 = fig.add_subplot(224, projection="polar")

        function Fig4a(ax;inter=true,legd=true)
            respath4=mkpath(respath*"/Fig4/")*"/"
            @info "optimising biomass"
            xᵇᶦᵒ=opti(interactions=inter,
                        result_format=:response,
                        stochastic=true,
                        human_interact=human_interact,
                        dac=0,
                        h2_leak=0,
                        samples=samples,
                        full_biomass=true,
                        full_renewables=true
                        )
            #@info "done"
            xᵇᶦᵒq05=quantile(xᵇᶦᵒ,0.05,dims=2)
            xᵇᶦᵒ_plot_05=[reshape(xᵇᶦᵒq05,10,6)[:,y] for y in 6:6]
            xᵇᶦᵒq50=quantile(xᵇᶦᵒ,0.5,dims=2)
            xᵇᶦᵒ_plot_50=[reshape(xᵇᶦᵒq50,10,6)[:,y] for y in 6:6]
            xᵇᶦᵒq95=quantile(xᵇᶦᵒ,0.95,dims=2)
            xᵇᶦᵒ_plot_95=[reshape(xᵇᶦᵒq95,10,6)[:,y] for y in 6:6]

            #@info "optimising electrolysis"
            xᵉˡᵉᶜᵗʳᵒˡʸˢⁱˢ=opti(interactions=inter,
                            result_format=:response,
                            stochastic=true,
                            human_interact=human_interact,
                            dac=0,
                            h2_leak=0,
                            samples=samples,
                            full_electrolysis=true,
                            full_renewables=true
                            )
            xᵉˡᵉᶜᵗʳᵒˡʸˢⁱˢq05=quantile(xᵉˡᵉᶜᵗʳᵒˡʸˢⁱˢ,0.05,dims=2)
            xᵉˡᵉᶜᵗʳᵒˡʸˢⁱˢ_plot_05=[reshape(xᵉˡᵉᶜᵗʳᵒˡʸˢⁱˢq05,10,6)[:,y] for y in 6:6]
            xᵉˡᵉᶜᵗʳᵒˡʸˢⁱˢq50=quantile(xᵉˡᵉᶜᵗʳᵒˡʸˢⁱˢ,0.5,dims=2)
            xᵉˡᵉᶜᵗʳᵒˡʸˢⁱˢ_plot_50=[reshape(xᵉˡᵉᶜᵗʳᵒˡʸˢⁱˢq50,10,6)[:,y] for y in 6:6]
            xᵉˡᵉᶜᵗʳᵒˡʸˢⁱˢq95=quantile(xᵉˡᵉᶜᵗʳᵒˡʸˢⁱˢ,0.95,dims=2)
            xᵉˡᵉᶜᵗʳᵒˡʸˢⁱˢ_plot_95=[reshape(xᵉˡᵉᶜᵗʳᵒˡʸˢⁱˢq95,10,6)[:,y] for y in 6:6]

            # @info "optimising fossil+CCS"
            xᶠᵒˢˢⁱˡ⁻ᶜᶜˢ=opti(interactions=inter,
                            result_format=:response,
                            stochastic=true,
                            human_interact=human_interact,
                            dac=0,
                            h2_leak=0,
                            samples=samples,
                            full_fossil_ccs=true,
                            full_renewables=true
                            )

            xᶠᵒˢˢⁱˡ⁻ᶜᶜˢq05=quantile(xᶠᵒˢˢⁱˡ⁻ᶜᶜˢ,0.05,dims=2)
            xᶠᵒˢˢⁱˡ⁻ᶜᶜˢ_plot_05=[reshape(xᶠᵒˢˢⁱˡ⁻ᶜᶜˢq05,10,6)[:,y] for y in 6:6]
            xᶠᵒˢˢⁱˡ⁻ᶜᶜˢq50=quantile(xᶠᵒˢˢⁱˡ⁻ᶜᶜˢ,0.5,dims=2)
            xᶠᵒˢˢⁱˡ⁻ᶜᶜˢ_plot_50=[reshape(xᶠᵒˢˢⁱˡ⁻ᶜᶜˢq50,10,6)[:,y] for y in 6:6]
            xᶠᵒˢˢⁱˡ⁻ᶜᶜˢq95=quantile(xᶠᵒˢˢⁱˡ⁻ᶜᶜˢ,0.95,dims=2)
            xᶠᵒˢˢⁱˡ⁻ᶜᶜˢ_plot_95=[reshape(xᶠᵒˢˢⁱˡ⁻ᶜᶜˢq95,10,6)[:,y] for y in 6:6]
            

            x05=hcat(xᵉˡᵉᶜᵗʳᵒˡʸˢⁱˢ_plot_05,xᵇᶦᵒ_plot_05,xᶠᵒˢˢⁱˡ⁻ᶜᶜˢ_plot_05 )|> vec
            x50=hcat(xᵉˡᵉᶜᵗʳᵒˡʸˢⁱˢ_plot_50,xᵇᶦᵒ_plot_50,xᶠᵒˢˢⁱˡ⁻ᶜᶜˢ_plot_50)|> vec
            x95=hcat(xᵉˡᵉᶜᵗʳᵒˡʸˢⁱˢ_plot_95,xᵇᶦᵒ_plot_95,xᶠᵒˢˢⁱˡ⁻ᶜᶜˢ_plot_95)|> vec

            _,legds=pbplot(x50,x95,x05,categories=categories,
                            legend=["Electrolysis","Biomass","Fossil+CCS"], scale=8, minscale=-5, median_lw=0.8,axis=ax,pal=["#0a9396","#0a9396","#ee9b00",colors[2]])
                
            if legd
                ax.legend(handles=legds,loc="upper right",bbox_to_anchor=(1.12,0.1),prop=font_prop,frameon=false,ncol=1)
            end

            sheetname=["bio","electrolysis","fossilCCS"]
            sheetname=inter ? "interactions_".*sheetname : sheetname
            f°=hcat(xᵇᶦᵒ_plot_05...,xᵇᶦᵒ_plot_50...,xᵇᶦᵒ_plot_95...)
            dataf=DataFrame(hcat(categories,f°),["Category","q05","q50","q95"])
            writetable(dataf,workbook=respath4*"Fig4.xlsx",worksheet=sheetname[1]);
            f°=hcat(xᵉˡᵉᶜᵗʳᵒˡʸˢⁱˢ_plot_05...,xᵉˡᵉᶜᵗʳᵒˡʸˢⁱˢ_plot_50...,xᵉˡᵉᶜᵗʳᵒˡʸˢⁱˢ_plot_95...)
            dataf=DataFrame(hcat(categories,f°),["Category","q05","q50","q95"])
            writetable(dataf,workbook=respath4*"Fig4.xlsx",worksheet=sheetname[2]);
            f°=hcat(xᶠᵒˢˢⁱˡ⁻ᶜᶜˢ_plot_05...,xᶠᵒˢˢⁱˡ⁻ᶜᶜˢ_plot_50...,xᶠᵒˢˢⁱˡ⁻ᶜᶜˢ_plot_95...)
            dataf=DataFrame(hcat(categories,f°),["Category","q05","q50","q95"])
            writetable(dataf,workbook=respath4*"Fig4.xlsx",worksheet=sheetname[3]);
            
        end 
        # function Fig4b(ax;inter=true,legd=true)
        #     respath4=mkpath(respath*"/Fig4/")*"/"
        #     xbalanced=opti(interactions=inter,
        #                 result_format=:response,
        #                 stochastic=true,
        #                 impact_selection=6,
        #                 dac=0,
        #                 h2_leak=0,
        #                 samples=samples,
        #                 full_biomass=false,
        #                 full_renewables=true
        #                 )
        #     xbalancedq05=quantile(xbalanced,0.05,dims=2)
        #     xbalanced_plot_05=[reshape(xbalancedq05,10,6)[:,y] for y in 6:6]
        #     xbalancedq50=quantile(xbalanced,0.5,dims=2)
        #     xbalanced_plot_50=[reshape(xbalancedq50,10,6)[:,y] for y in 6:6]
        #     xbalancedq95=quantile(xbalanced,0.95,dims=2)
        #     xbalanced_plot_95=[reshape(xbalancedq95,10,6)[:,y] for y in 6:6]

        
        #     xclimate=opti(interactions=inter,
        #                     result_format=:response,
        #                     stochastic=true,
        #                     climate_impact=true,
        #                     biosphere_integrity_impact=false,
        #                     human_interact=human_interact,
        #                     dac=0,
        #                     h2_leak=0,
        #                     samples=samples,
        #                     full_electrolysis=false,
        #                     full_renewables=true
        #                     )
        #     xclimateq05=quantile(xclimate,0.05,dims=2)
        #     xclimate_plot_05=[reshape(xclimateq05,10,6)[:,y] for y in 6:6]
        #     xclimateq50=quantile(xclimate,0.5,dims=2)
        #     xclimate_plot_50=[reshape(xclimateq50,10,6)[:,y] for y in 6:6]
        #     xclimateq95=quantile(xclimate,0.95,dims=2)
        #     xclimate_plot_95=[reshape(xclimateq95,10,6)[:,y] for y in 6:6]
            
            
        #     xbioint=opti(interactions=inter,
        #                     result_format=:response,
        #                     stochastic=true,
        #                     human_interact=human_interact,
        #                     dac=0,
        #                     h2_leak=0,
        #                     biosphere_integrity_impact=true,
        #                     samples=samples,
        #                     full_fossil_ccs=true,
        #                     full_renewables=true
        #                     )

        #     xbiointq05=quantile(xbioint,0.05,dims=2)
        #     xbioint_plot_05=[reshape(xbiointq05,10,6)[:,y] for y in 6:6]
        #     xbiointq50=quantile(xbioint,0.5,dims=2)
        #     xbioint_plot_50=[reshape(xbiointq50,10,6)[:,y] for y in 6:6]
        #     xbiointq95=quantile(xbioint,0.95,dims=2)
        #     xbioint_plot_95=[reshape(xbiointq95,10,6)[:,y] for y in 6:6]
            

        #     x05=hcat(xbalanced_plot_05,xclimate_plot_05,xbioint_plot_05 )|> vec
        #     x50=hcat(xbalanced_plot_50,xclimate_plot_50,xbioint_plot_50)|> vec
        #     x95=hcat(xbalanced_plot_95,xclimate_plot_95,xbioint_plot_95)|> vec

        #     _,legds=pbplot(x50,x95,x05,categories=categories,
        #                     legend=["Biochemical\nPhosphorus","Climate","Biosphere\nintegrity"], scale=7, minscale=-4, median_lw=0.8,axis=ax,pal=["#0a9396",colors[17],colors[2],colors[6]])
        #     if legd
        #         ax.legend(handles=legds,loc="upper right",bbox_to_anchor=(1.13,0.12),prop=font_prop,frameon=false,ncol=1)
        #     end

        #     sheetname=["Phosphorus","Climate","Biosphere"]
        #     sheetname=inter ? "interactions_".*sheetname : sheetname

        #     f°=hcat(xbalanced_plot_05...,xbalanced_plot_50...,xbalanced_plot_95...)
        #     dataf=DataFrame(hcat(categories,f°),["Category","q05","q50","q95"])
        #     writetable(dataf,workbook=respath4*"Fig4.xlsx",worksheet=sheetname[1]);

        #     f°=hcat(xbioint_plot_05...,xbioint_plot_50...,xbioint_plot_95...)
        #     dataf=DataFrame(hcat(categories,f°),["Category","q05","q50","q95"])
        #     writetable(dataf,workbook=respath4*"Fig4.xlsx",worksheet=sheetname[3]);

        #     f°=hcat(xclimate_plot_05...,xclimate_plot_50...,xclimate_plot_95...)
        #     dataf=DataFrame(hcat(categories,f°),["Category","q05","q50","q95"])
        #     writetable(dataf,workbook=respath4*"Fig4.xlsx",worksheet=sheetname[2]); 
        # end

        Fig4a(ax2,legd=false)
        # Fig4b(ax4,legd=false)

        Fig4a(ax1,inter=false)
        # Fig4b(ax3,inter=false)

        ax1.set_title("(a)", font_properties=font_prop_titles)
        ax2.set_title("(b)", font_properties=font_prop_titles)
        # ax3.set_title("(c)", font_properties=font_prop_titles)
        # ax4.set_title("(d)", font_properties=font_prop_titles)

        fig.tight_layout()
        fig.savefig(respath4*"Fig4.svg",transparent=true, bbox_inches="tight")

        display(fig)
        plt.close("all")

    end

    """
    ## Implementation window for direct air capture
    ### Description 
    > contour plots showing the 
    """
    function Fig5(;dac_range=0:1:30,
                    interactions=true,
                    full_electrolysis=false,
                    full_biomass=false,
                    human_interact=false,
                    full_fossil_ccs=false
                    ,renewables=true
                    ,q=0.65)
        rcParams["xtick.top"] = true
        respath5=mkpath(respath*"/Fig5/")*"/"
        fig, axs = plt.subplots(3,3,figsize=(10,7.5), sharey=true,sharex=true)

        lendac=length(dac_range)
        s=[opti(interactions=interactions,
                result_format=:response,
                full_electrolysis=full_electrolysis,
                human_interact=human_interact,
                full_biomass=full_biomass,
                full_fossil_ccs=full_fossil_ccs,
                full_renewables=renewables,
                dac=y,
                h2_leak=0,q=q
                ) for y in dac_range]

        k=(reshape(cat(s...;dims=3),10,6,lendac))[Not(2),:,:]

        if full_electrolysis
            figsave_name="Fig5_electrolysis"
        elseif full_biomass
            figsave_name="Fig5_biomass"
        elseif full_fossil_ccs
            figsave_name="Fig5_fossilccs"
        else
            figsave_name="Fig5"
        end

        if interactions
            figsave_name=figsave_name*"_interactions"
        else
            figsave_name=figsave_name
        end

        if isfile(respath5*figsave_name*".xlsx")
            rm(respath5*figsave_name*".xlsx")
            rm(respath5*figsave_name*"_optimal points.xlsx")
        end

        for i in 1:9
            letters =["(a) ", "(b) ", "(c) ", "(d) ", "(e) ", "(f) ", "(g) ", "(h) ", "(i) "]
            f°=hcat(dac_range,k[i,:,:]')
            df°=DataFrame(f°,["DAC_rate (kgCO₂ kgH₂⁻¹)","2025","2030","2035","2040","2045","2050"])
            writetable(df°; workbook=respath5*figsave_name*".xlsx", worksheet=letters[i])
        end


        # norm = SymLogNorm(linthresh=20, linscale=1, vmin=-2000, vmax=2000)
        norm = SymLogNorm(linthresh=20, linscale=1, vmin=-2000, vmax=2000)
        csf = nothing
        for i in 1:9
            csf = axs[i].contourf(k[i,:,:]',levels=30,cmap="BrBG_r",norm=norm) #"RdBu_r"
            # fig.colorbar(csf, ax=axs[i])
            letters = ["(a) ", "(b) ", "(c) ", "(d) ", "(e) ", "(f) ", "(g) ", "(h) ", "(i) "]
            axs[i].set_title(letters[i]*categories[Not(2)][i], fontproperties=font_prop_titles)#categories[Not(2)][i]
            axs[i].set_xticks(0:5)
            axs[i].set_xticklabels(2025:5:2050,fontproperties=font_prop_ticks)

            cs_lines = axs[i].contour(k[i,:,:]', levels=[1], linewidths=2,colors="black")
            
            try
                segments = cs_lines[:allsegs]
                verts = segments[1]
                df = DataFrame(verts,["Year","optimal DAC_rate (kgCO₂ kgH₂⁻¹)"])
                df[:, 1] .= df[:, 1] .* 5 .+ 2025
                writetable(df; workbook=respath5*figsave_name*"_optimal points.xlsx", worksheet=letters[i]*"_boundary");
                axs[i].clabel(cs_lines, inline=1, fontsize=10,fmt=Dict(1=> "Boundary"),zorder=5)
            catch
                continue
            end
            
        
        if i==1 || i==2
            for z in [-100,-80,-60,-10,10,40,80]
                        cs_lines_min= axs[i].contour(k[i,:,:]', levels=[z], linewidths=1,colors="black")
                        axs[i].clabel(
                                    cs_lines_min,    
                                    inline=true,      
                                    fontsize=8,
                                    fmt="%d"    
                                        )
            end

        else
            for z in [-80,-60,-10,10,40,60,70,80]
                        cs_lines_min= axs[i].contour(k[i,:,:]', levels=[z], linewidths=1,colors="black")
                        axs[i].clabel(
                                    cs_lines_min,    
                                    inline=true,      
                                    fontsize=8,
                                    fmt="%d"    
                                        )
                    end
        end
            

            axs[i].tick_params(axis="both", direction="in")

        end

        for i in 1:3
            axs[i].set_ylabel("DAC (kgCO₂ kgH₂⁻¹)", fontproperties=font_prop_labels)
        end
        

        for ax in axs
            for ticklabel in ax.get_xticklabels()
                ticklabel.set_fontproperties(font_prop_ticks)
            end
            for ticklabel in ax.get_yticklabels()
                ticklabel.set_fontproperties(font_prop_ticks)
            end
        end

        fig.tight_layout()


        plt.savefig(respath5*figsave_name*".svg",transparent=true)
        plt.savefig(respath5*figsave_name*".png",dpi=800,transparent=true)
        display(fig)
        plt.close("all")
    end

    """
    ## Contribution analysis
    ### Description 
    > contour plots showing the 
    """
    function Fig6(;
                full_electrolysis=false,
                full_renewables=true,
                full_biomass=false,
                full_fossil_ccs=false,
                human_interact=false,
                dac=0,
                h2_leak=0,
                cutoff=0.02,step=2,legposa=-0.25,legposb=-0.25,q=0.65,contrib_year=2050,project=𝐏2050)
        respath6=mkpath(respath*"/Fig6/")*"/"
        cmap = plt.get_cmap("tab20c")
        filename="Fig6"
        if full_electrolysis
            filename=filename*"_electrolysis"
        elseif full_biomass
            filename=filename*"_biomass"
        elseif full_fossil_ccs
            filename=filename*"_fossilccs"
        end     
        
        if isfile(respath6*filename*".xlsx")
                    rm(respath6*filename*".xlsx")
        end
            fig, axs = subplots(2,1,figsize=(13, 16.5))

            function fig6a(ax;inter,title="",legpos=legposa)
                respath6=mkpath(respath*"/Fig6/")*"/"
                    

                cont=opti(interactions=inter,
                        result_format=:contribution,
                        human_interact=human_interact,
                        full_electrolysis=full_electrolysis,
                        full_renewables=full_renewables,
                        full_biomass=full_biomass,
                        full_fossil_ccs=full_fossil_ccs,
                        dac=dac,
                        h2_leak=h2_leak,
                        contrib_year=contrib_year,q=q
                        );

                rcParams["ytick.right"] = false
                rcParams["xtick.top"] = false
                rcParams["xtick.bottom"] = true
                rcParams["ytick.direction"] = "in"
                rcParams["ytick.minor.visible"] = false
                rcParams["xtick.direction"] = "out"
                rcParams["xtick.minor.visible"] = true
                rcParams["figure.facecolor"] = "white"

                j_indices=unique(vcat([findall(x -> x > (cutoff)/100, cont[i,:]) for i in 1:10]...));

                rest=sum(cont,dims=2).-sum(cont[:,j_indices],dims=2)
                res=hcat(cont[:,j_indices],rest).*100

                labels=[getTcmAct(i,project).act for i in j_indices]
                labels=vcat(labels, "Others")
                df°=DataFrame(hcat(labels,res'),["Process", catnames...])
                if isfile("Fig6.xlsx")
                    rm("Fig6.xlsx")
                end

                sheetna=string(contrib_year)
                if inter
                    sheetna=sheetna*"_interactions"
                end
                if full_electrolysis
                    sheetna=sheetna*"_electrolysis"
                elseif full_biomass
                    sheetna=sheetna*"_biomass"
                elseif full_fossil_ccs
                    sheetna=sheetna*"_fossilccs"
                end
                writetable(df°; workbook=respath6*filename*".xlsx", worksheet=sheetna);

                co = [cmap(i) for i in 1:1:length(labels)]

                

                bottom_pos = zeros(size(res, 1))
                bottom_neg = zeros(size(res, 1))
                bar_width = 0.7

                

                for (i,l,c) in zip(1:size(res, 2),labels,co)
                    pos_values = ifelse.(res[:, i] .> 0, res[:, i], 0)
                    neg_values = ifelse.(res[:, i] .< 0, res[:, i], 0)
                    
                    ax.barh(1:10, pos_values, left=bottom_pos, label=l, edgecolor="black",lw=0.8,zorder=1,height=bar_width,color=c)
                    ax.barh(1:10, neg_values, left=bottom_neg, edgecolor="black",lw=0.8,zorder=1,height=bar_width,color=c)#width=bar_width
                    bottom_pos .+= pos_values
                    bottom_neg .+= neg_values
                end

                ax.spines["top"].set_visible(false)
                ax.spines["right"].set_visible(false)
                ax.set_xlabel("%",fontproperties=font_prop_labels)
                ax.set_xlim(0,100)
                ax.set_ylim(0.5,10.5)
                ax.set_yticks(1:10)
                ax.set_yticklabels(catnames_ticks,fontproperties=font_prop_labels, fontsize=12)
                for ticklabel in ax.get_xticklabels()
                    ticklabel.set_fontproperties(font_prop_labels)
                end
                ax.set_title(title,fontproperties=font_prop_titles, fontsize=14)
                ax.legend(loc="lower center", bbox_to_anchor=(0.5, legpos), frameon=false, prop=font_prop_labels,fontsize=12, ncol=2)

                fig.tight_layout()
                rcParams["ytick.right"] = false
                rcParams["xtick.top"] = false
                rcParams["xtick.bottom"] = true
                rcParams["ytick.direction"] = "out"
                rcParams["ytick.minor.visible"] = false
                rcParams["xtick.direction"] = "out"
                rcParams["xtick.minor.visible"] = false
                rcParams["figure.facecolor"] = "white"
            end

        fig6a(axs[1],inter=false,title="(a) No interaction",legpos=legposa)
        fig6a(axs[2],inter=true,title="(b) With interactions",legpos=legposb)
        
        figname="Fig6"

        if full_electrolysis
            figname=figname*"_electrolysis"
        elseif full_biomass
            figname=figname*"_biomass"
        elseif full_fossil_ccs
            figname=figname*"_fossilccs"
        end

        plt.savefig(respath6*figname*".svg", transparent=true, bbox_inches="tight")
        plt.savefig(respath6*figname*".png", dpi=800, transparent=true, bbox_inches="tight")
        display(fig)
    end

    """ DAC vs hydrogen emissions"""
    function Fig7(;q=0.95,Rangedac=3.8:0.5:6.8,
                human_interact=false)

        rcParams["xtick.top"] = false
        fig,ax = plt.subplots(figsize=(6,6))

        function Fig7a(ax)  

            x_ref⁺ = opti(interactions=true,
                        human_interact=human_interact,
                            full_renewables=true,
                            result_format=:response,q=q,
                            dac=3.86, # we place ourselves at the optimial point
                            h2_leak=0)[1,6]
            
            rangeh2_leak=0:0.05:0.2

            𝐦=[((opti(interactions=true,
                        full_renewables=true,
                        human_interact=human_interact,
                        q=q,
                        result_format=:response,
                        dac=c,
                        h2_leak=h)[1,6])/x_ref⁺)-1 for c in Rangedac, h in rangeh2_leak]    
            
            # norma = SymLogNorm(linthresh=5, linscale=3, vmin=-10, vmax=20)
            cs=ax.contourf(rangeh2_leak,Rangedac, 𝐦.*100, levels=50, cmap="BrBG_r")#"BrBG_r",norm=norma
            cbar = plt.colorbar(cs,label="Relative deviation from optimal solution (%)", ax=ax, orientation="vertical", fraction=0.046, pad=0.04)
            cbar.set_label("Relative deviation from optimal solution (%)", fontproperties=font_prop_labels)
            
            for ticklabel in cbar.ax.get_yticklabels()
                ticklabel.set_fontproperties(font_prop_ticks)
            end

            cs_lines2=ax.contour(rangeh2_leak,Rangedac,𝐦.*100, levels=[0], colors="black", linewidths=1.5,linestyle="--")

            segments = cs_lines2[:allsegs]
            verts = segments[1]

            df = DataFrame(verts,:auto)
            writetable(df; workbook="test.xlsx", worksheet="_boundary")
            ax.set_xticks(rangeh2_leak)
            ax.set_xticklabels(rangeh2_leak.*100,fontproperties=font_prop_ticks)

            ax.set_xlabel("Hydrogen emissions (% production)", fontproperties=font_prop_labels, fontsize=10)
            ax.set_ylabel("Carbon captured (kgCO₂ kgH₂⁻¹)", fontproperties=font_prop_labels, fontsize=10)
            ax.grid(false)

            for ticklabel in ax.get_xticklabels()
            ticklabel.set_fontproperties(font_prop_ticks)
            end
            for ticklabel in ax.get_yticklabels()
                ticklabel.set_fontproperties(font_prop_ticks)
            end
        end

        Fig7a(ax)
        ax.axvline(0.1,color="black",linestyle="-.",lw=1)
        ax.axvline(0.15,color="black",linestyle="-.",lw=1)

        fig.tight_layout()
        fig.savefig("Fig7.svg",transparent=true, bbox_inches="tight")
        display(fig)
        plt.close("all")
    end

    """ tehcnology choice matrix rectangularisation"""
    function Sfig10()

        fig,axs = plt.subplots(1,2,figsize=(10,10))
        
        axs[1].spy(ChoiceModel(𝐏)[1])
        axs[1].set_title("(a) Original technology choice matrix", fontproperties=font_prop_titles)
        axs[2].spy(ChoiceModel(𝐏)[2])
        axs[2].set_title("(b) Rectangularised technology choice matrix", fontproperties=font_prop_titles)

        for ax in axs
            ax.set_xlabel("Processes", fontproperties=font_prop_labels, fontsize=12)
            ax.set_ylabel("reference flows", fontproperties=font_prop_labels, fontsize=12)
            for ticklabel in ax.get_xticklabels()
                ticklabel.set_fontproperties(font_prop_ticks)
            end
            for ticklabel in ax.get_yticklabels()
                ticklabel.set_fontproperties(font_prop_ticks)
            end
        end

        display(fig)
        suprespath=mkpath(config_suprespath*"/main/")*"/"
        fig.savefig(suprespath*"rectangularisation.svg",transparent=true, bbox_inches="tight")
        fig.savefig(suprespath*"rectangularisation.png",dpi=800,transparent=true, bbox_inches="tight")
        plt.close("all")
    end

    """ capacity utilisation"""
    function Sfig11(;impact_selection=nothing,
                    full_electrolysis=false,
                    full_renewables=true,
                    human_interact=false,
                    full_biomass=false,
                    full_fossil_ccs=false,
                    dac=0,
                    h2_leak=0.0)
    
        set=vcat(𝖘ᶠᵒˢˢⁱˡ,𝖘ᶠᵒˢˢⁱˡ⁻ᶜᶜˢ,𝖘ᵇᶦᵒ,𝖘ᵉˡᵉᶜᵗʳᵒˡʸˢⁱˢ)
        fullset_names=vcat(fossil_names, fossil_ccs_names, bio_names, electrolysis_names)

        filename="Sfig11_capacity_check"
        if full_electrolysis
            filename=filename*"_electrolysis"
        elseif full_biomass
            filename=filename*"_biomass"
        elseif full_fossil_ccs
            filename=filename*"_fossilccs"
        end


        if isfile(respath*filename*".xlsx")
                rm(respath*filename*".xlsx")
        end

        fig,axs= plt.subplots(2,2,figsize=(12,11),sharey=true,sharex=true)
        kw_ag_font=Dict("fontproperties"=>font_prop, "fontsize"=> 8)

        s65int=opti(interactions=true,
                result_format=:scale,
                stochastic=false,
                human_interact=human_interact,
                full_electrolysis=full_electrolysis,
                impact_selection=impact_selection,
                full_renewables=full_renewables,
                full_biomass=full_biomass,
                full_fossil_ccs=full_fossil_ccs,
                opti_dac=false,
                dac=0,
                h2_leak=0.0,q=0.65)
        s95int=opti(interactions=true,
                result_format=:scale,
                stochastic=false,
                human_interact=human_interact,
                full_electrolysis=full_electrolysis,
                impact_selection=impact_selection,
                full_renewables=full_renewables,
                full_biomass=full_biomass,
                full_fossil_ccs=full_fossil_ccs,
                opti_dac=false,
                dac=0,
                h2_leak=0.0,q=0.95)
        s65=opti(interactions=false,
                result_format=:scale,
                stochastic=false,
                human_interact=human_interact,
                full_electrolysis=full_electrolysis,
                impact_selection=impact_selection,
                full_renewables=full_renewables,
                full_biomass=full_biomass,
                full_fossil_ccs=full_fossil_ccs,
                opti_dac=false,
                dac=0,
                h2_leak=0.0,q=0.65)
        s95=opti(interactions=false,
                result_format=:scale,
                stochastic=false,
                human_interact=human_interact,
                full_electrolysis=full_electrolysis,
                impact_selection=impact_selection,
                full_renewables=full_renewables,
                full_biomass=full_biomass,
                full_fossil_ccs=full_fossil_ccs,
                opti_dac=false,
                dac=0,
                h2_leak=0.0,q=0.95)

        for (ind,(s,q)) in enumerate(zip([s65,s65int,s95,s95int],[0.65,0.65,0.95,0.95]))

            f=(s[set,:]./quantile.(δ𝐜,q)[set,1,:])
            f°=hcat(fullset_names,f)
            
            df°=DataFrame(f°,["Process","2025","2030","2035","2040","2045","2050"])
            
            clr=["Purples","Oranges","Purples","Oranges"]

            Seaborn.heatmap(f,ax=axs[ind],cbar=false,annot=true, fmt=".0%",annot_kws=kw_ag_font,cmap=clr[ind])
            sheetname=["a","b","c","d"][ind]
            axs[ind].set_title(["(a) less capacity","(b) less capacity","(c) More capacity","(d) More capacity"][ind], fontproperties=font_prop_titles)
            writetable(df°; workbook=respath*filename*".xlsx",worksheet=sheetname);
            axs[ind].set_xticklabels(2025:5:2050,fontproperties=font_prop_labels,fontsize=10)
            axs[ind].set_yticklabels(fullset_names, rotation=0, ha="right",fontproperties=font_prop_labels,fontsize=10)
        end
        # axs[2].set_title("(b) 95th percentile", fontproperties=font_prop_titles)
        # axs[1].set_title("(a) 65th percentile", fontproperties=font_prop_titles)

        fig.tight_layout()
        display(fig)
        fig.savefig(respath*"capacity_check.svg",transparent=true, bbox_inches="tight")
        fig.savefig(respath*"capacity_check.png",dpi=800,transparent=true, bbox_inches="tight")
        plt.close("all")
    end

    """ building a systemp configuration plot """
    function sysconfig(;full_biomass=false,
                            full_electrolysis=true,
                            full_fossil_ccs=false,
                            dac=0,
                            h2_leak=0, pth="../Source data/02_results/main/Fig3/other system configurations/")
        s=opti(interactions=true,
                                result_format=:scale,
                                stochastic=false,
                                dac=dac,
                                h2_leak=h2_leak,
                                human_interact=true,
                                full_biomass=full_biomass,
                                full_electrolysis=full_electrolysis,
                                full_fossil_ccs=full_fossil_ccs,
                                full_renewables=true,
                                q=0.95)
        if full_biomass
            filename="biomass"
        elseif full_electrolysis
            filename="electrolysis"
        elseif full_fossil_ccs
            filename="fossilccs"
        else
            filename="balanced"
        end
        if dac>0
            filename=filename*"_dac"*(string(dac))
        end

        fig,axs = plt.subplots(1,2,figsize=(12,6))
        Fig3b(axs[1],s=s,filename=filename)
        Fig3d(axs[2],s=s,filename=filename)
        for ax in axs
            for ticklabel in ax.get_xticklabels()
                    ticklabel.set_fontproperties(font_prop_ticks)
                end
            for ticklabel in ax.get_yticklabels()
                ticklabel.set_fontproperties(font_prop_ticks)
            end
        end
        axs[1].set_title("(a)", font_properties=font_prop_titles)
        axs[2].set_title("(b)", font_properties=font_prop_titles)
        fig.tight_layout()
       
        plt.savefig(pth*"Fig3_"*filename*".svg",transparent=true, bbox_inches="tight")
        display(fig)
        plt.close("all")
    end
end