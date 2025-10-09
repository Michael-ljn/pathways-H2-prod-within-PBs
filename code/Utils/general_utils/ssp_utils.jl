using DataFrames,XLSX
scenario_path="./Source data/01_input/IAM scenarios/"

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
