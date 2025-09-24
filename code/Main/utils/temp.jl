           
            
            


[x.key for x in getTcmAct(𝖘ᵇᶦᵒ,𝐏)]

𝖘ᶠᵒˢˢⁱˡ= newSet([:SMR,:hydrogen_coal,:hydrogen_pyrolysis]) #grey
𝖘ᶠᵒˢˢⁱˡ⁻ᶜᶜˢ= newSet([:hydrogen_SMRccs,:hydrogen_coalccs])
𝖘ᵇᶦᵒ = newSet([:hydrogen_bSMR,:hydrogen_BioCccs,:hydrogen_bSMRccs])
𝖘ᵉˡᵉᶜᵗʳᵒˡʸˢⁱˢ = newSet([:hydrogen_PEM,:hydrogen_AE,:hydrogen_SOEC_steam,:hydrogen_SOEC_elec])




sᴺ⁻ᴾᴮᴵ





# end optimiser.
    getTcmAct(113,𝐏)

    𝖘ᵉˡᵉᶜᵗʳᵒˡʸˢⁱˢ = newSet([:hydrogen_PEM,:hydrogen_AE,:hydrogen_SOEC_steam,:hydrogen_SOEC_elec])
    s[𝖘ᵉˡᵉᶜᵗʳᵒˡʸˢⁱˢ,:]
    



    𝖘ᴱᴴⱽ=sort(getTcmChoices(:electricityHV,𝐏))
    𝖘ᴱᴸ = sort(vcat(𝖘ᴱᴴⱽ,[48]))




    [s=>getTcmAct(s,𝐏).act for s in 𝖘ᴱᴸ]

    



function printScale(process_set)
    act_to_tcm=Dict([x.second.act =>x.first for x ∈ pairs(filter(j -> j[1] in (s[process_set]).nzind, getTcmAct(𝐏)))]...)
    res_to_tcm = Dict(Symbol(process_names[k]) => v for (k, v) in act_to_tcm if haskey(process_names, k))
    return Dict(Symbol(code) => s[process_set][index] for (code, index) in pairs(res_to_tcm))
end

act_to_tcm=Dict([x.second.act =>x.first for x ∈ pairs(filter(j -> j[1] in (s[𝖘ᴴ²]), getTcmAct(𝐏)))]...)
res_to_tcm = Dict(Symbol(process_names[k]) => v for (k, v) in act_to_tcm if haskey(process_names, k))
Dict(Symbol(code) => s[process_set][index] for (code, index) in pairs(res_to_tcm))






findnz(s)
printScale(𝖘ᴴ²)



Characterisation!().categories
getTcmAct(9,𝐏)
getTcmKey("electricity production, photovoltaic, 570kWp open ground installation, multi-Si","RoW",𝐏)
getAct(:electricityHV,project=𝐏)




    # # constribution analysis for hydrogen production pathways 
    # 𝖘ᴴ² = sort(getTcmChoices(:hydrogen ,𝐏))
    # [x.label for x in getTcmAct(𝖘ᴴ²,𝐏)]











# Other plots
    # ##### Stochastic simulation
    # using KernelDensity
    # cate=1
    # fig, axs = plt.subplots(5,2,figsize=(10,9))
    # for i in 1:10
    #     #colors=["grey","red","blue","purple","green","orange",]
    #     axs[i].hist(d̄[i,:,1], bins=150,density=true, alpha=0.5)
    #     axs[i].axvline(mean(d̄[i,:,1]), color="black", linestyle="--", label="mean")
    #     axs[i].axvline(median(d̄[i,:,1]), color="red", linestyle="--", label="median")
    #     kd = kde(d̄[i,:,1])
    #     axs[i].plot(kd.x, kd.density)
    #     axs[i].set_title(catnames[i],font_properties=font_prop_titles)
    # end
    # # a.legend(frameon=false)
    # fig.tight_layout()
    # display(plt.gcf())
    # plt.close("all")


    xᵇᶦᵒ=opti(interactions=true,
                result_format=:response,
                stochastic=true,
                dac=0,
                h2_leak=0,
                samples=3,
                full_biomass=true
                )
    xᵇᶦᵒq05=quantile(xᵇᶦᵒ,0.05,dims=2)
    xᵇᶦᵒ_plot_05=[reshape(xᵇᶦᵒq05,10,6)[:,y] for y in 6:6]




# function ext_excel()
    # ni=hcat(ASR_med_noI[:,1]...)
    # bi=hcat(ASR_med_bio[:,1]...)
    # full=hcat(ASR_med[:,1]...)

    # df=DataFrame((((bi.-ni)./ni)*100)',:auto)
    # rename!(df, categories)
    #     #     function expt_excel(;cutoff=0.05)
    #     #     for ssp in 1:3
    #     #         filename = string(respath, "SSP", ssp, "/contrib_results_H-PBI.xlsx")
    #     #         if isfile(filename)
    #     #             rm(filename)
    #     #         end
    #     #         for yr in 1:6
    #     #             sheetname = string("year ", 2020 + 5 * yr)
    #     #             mm = (res_contrib_med[yr, ssp] ./ sum(res_contrib_med[yr, ssp], dims=2))
    #     #             indices = unique(vcat([findall(x -> x > cutoff, mm[i, :]) for i in 1:10]...))
    #     #             rest = sum(mm, dims=2) .- sum(mm[:, indices], dims=2)
    #     #             mm1 = hcat(mm[:, indices], rest).*100
    #     #             labels = [getTcmAct(i, yr, 1).act for i in indices]
    #     #             labels = vcat(labels, "Others")
    #     #             df_res = DataFrame(hcat(labels, mm1'), :auto)
    #     #             rename!(df_res, vcat("Activities", catnames.*" [%]"))
    #     #             df_res = combine(groupby(df_res, :Activities), names(df_res, Not(:Activities)) .=> sum)

    #     #             for col in names(df_res)
    #     #                 if endswith(string(col), "_sum")
    #     #                     rename!(df_res, col => Symbol(replace(string(col), "_sum" => "")))
    #     #                 end
    #     #             end
    #     #             if isfile(filename)
    #     #                 XLSX.openxlsx(filename, mode="rw") do xf
    #     #                     if sheetname in XLSX.sheetnames(xf)
    #     #                         deletesheet!(xf, sheetname)  # Remove existing sheet if you want to replace it
    #     #                     end
    #     #                     ws = XLSX.addsheet!(xf, sheetname)
    #     #                     XLSX.writetable!(ws, Tables.columntable(df_res))
    #     #                 end
    #     #             else
    #     #                 XLSX.writetable(filename, Tables.columntable(df_res), sheetname=sheetname)
    #     #             end
    #     #         end
    #     #     end
    #     # end
    #     # expt_excel()
# end



# """
#     utility function to wrap text, use a double space to separate words
# """
# function wrap_text(str, width=9)
#     words = split(str)
#     lines = String[]
#     current_line = ""
#     for word in words
#         if length(current_line) + length(word) > width
#             push!(lines, strip(current_line))
#             current_line = word
#         else
#             current_line = current_line * " " * word
#         end
#     end
#     push!(lines, strip(current_line))
#     result = join(lines, "\n")
#     return replace(result, r"^\n+" => "")  # Remove leading newlines
# end


# catnames=[ # labels to match the dimensions of AESA categories.
#             "Climate  change  Energy  imbalance"
#             "Climate  change  CO2  Concentration"
#             "Ocean  acidification"
#             "Atmospheric  aerosol  loading"
#             "Freshwater  use"
#             "Biogeochemical  flows-P"
#             "Biogeochemical  flows-N"
#             "Stratospheric  ozone  depletion"
#             "Land-system  change"
#             "Biosphere  Integrity"]


# catnames_ticks=wrap_text.(catnames, 9)