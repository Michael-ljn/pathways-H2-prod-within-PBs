using DataFrames,XLSX


scenario_path="../Source data/01_input/Premise scenarios/"

function getVals(Variable::String;
                years::StepRange{Int64, Int64}=2020:1:2100,
                df::DataFrame=df,matrix=true)
    dfa=filter(row -> row[:Variable] == Variable, df)
    if matrix
        return Float64.(dfa[:,string.(years)]|> Matrix)
    else
        return dfa
    end
end
function getModel(Model::String;
                  df::DataFrame=df,uni::Bool=false)
    dfa=filter(row -> row[:Model] == Model, df)
    if uni
        return unique(dfa[!,["Model","Scenario"]])
    else
        return dfa
    end
end
function getModel(Model::String,scenario::String;
                  df::DataFrame=df,uni=false)
                
    dfa=filter(row -> row[:Model] == Model && row[:Scenario]== scenario, df)
    if uni 
        return unique(dfa[!,["Variable"]])
    else
        return dfa
    end
end
function getModel(dataframe::DataFrame)          
    return unique(dataframe[!,["Model","Scenario"]])
end
function getScenario(Scenario::String;
                  df::DataFrame,uni=false)

    dfa=filter(row -> row[:Scenario] == Scenario, df)
    if uni
        dfa=unique(df_check[!,["Varibles"]])
    end
    return dfa
end
function writetable(table::DataFrame; worksheet="Model_Scenarios",workbook::String="output.xlsx")
    if isfile(workbook)
        XLSX.openxlsx(workbook, mode="rw") do xf
            if worksheet in XLSX.sheetnames(xf)
                XLSX.deletesheet!(xf, worksheet) 
            end
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




# """
# Function to get values from SSP data for a specific variable and region
# """
# function get_vals(Variable::String;
#                   years::StepRange{Int64, Int64}=2020:1:2100,
#                   SSP::DataFrame)
#     SSPa=filter(row -> row[:Variable] == Variable, SSP)
#     return Float64.(SSPa[:,string.(years)]|> Matrix)
# end

# function expt_ASR_excel(ASR,ssp,scenar,range=["median","5th percentile","95th percentile"])
#     filename = string(respath, "SSP", ssp, "/$(scenar)_ASR_results.xlsx")
#     if isfile(filename)
#         rm(filename)
#     end
#     for (asr,sc) in zip(ASR,range)
#         df_ASR_res=DataFrame(hcat(catnames,hcat(asr[:,ssp]...)),:auto)
#         rename!(df_ASR_res, [:Boundary, (Symbol(i) for i in 2025:5:2050)...])
        
#         if isfile(filename)
#             XLSX.openxlsx(filename, mode="rw") do xf
#                 if sc in XLSX.sheetnames(xf)
#                     deletesheet!(xf, sc) 
#                 end
#                 ws = XLSX.addsheet!(xf, sc)
#                 XLSX.writetable!(ws, Tables.columntable(df_ASR_res))
#             end
#         else
#             XLSX.writetable(filename, Tables.columntable(df_ASR_res), sheetname=sc)
#         end

#     end
# end