using DataFrames,XLSX


scenario_path="/Users/mickael/Library/CloudStorage/OneDrive-UNSW/Research/Code and data/lca/src/Scenario/"


"""
Function to plot a variable extracted from SSP data
"""
function plot_var(var::DataFrame;
    years::StepRange{Int64, Int64}=2025:5:2050,
    label::String="variable")

    plt.plot(years, Matrix(var)', label=["SSP1","SSP2", "SSP5"], linewidth=2)
    plt.ylabel(label)
    plt.legend(frameon=false)
    display(plt.gcf())
    plt.close("all")
end
function plot_var(var::Matrix;
    years::StepRange{Int64, Int64}=2025:5:2050,
    label::String="variable")
    plt.plot(years, var, label=["SSP1","SSP2", "SSP5"], linewidth=2)
    plt.ylabel(label)
    plt.legend(frameon=false)
    display(plt.gcf())
    plt.close("all")
end
function plot_var(var::Matrix;
    years::StepRange{Int64, Int64}=2025:5:2050,
    label::String="variable")
    plt.plot(years, var, label=["SSP1","SSP2", "SSP5"], linewidth=2)
    plt.ylabel(label)
    plt.legend(frameon=false)
    display(plt.gcf())
    plt.close("all")
end

"""
Function to get values from SSP data for a specific variable and region
"""
function get_vals(Variable::String;
                 Region::String="World",
                 SSP=SSP,start_year::String="2020",
                 end_year::String="2100",
                 show::Bool=false,)
    
    SSPa=filter(row -> row[:Variable] == Variable && row[:Region] == Region, SSP)
    global Scenario=reshape(SSPa[:,"Scenario"], 1, :)
    global Scenario[2]="SSP2-PkBudg500"
    global Unit=SSPa[1,"Unit"]
    start_idx = findfirst(==(start_year), names(SSPa))
    end_idx = findfirst(==(end_year), names(SSP))
    SSPb=SSPa[:, start_idx:end_idx]

    if show
        plot_var(SSPb; label=Variable*"  "*Unit)
    end
    return SSPb
end


function expt_ASR_excel(ASR,ssp,scenar,range=["median","5th percentile","95th percentile"])
    filename = string(respath, "SSP", ssp, "/$(scenar)_ASR_results.xlsx")
    if isfile(filename)
        rm(filename)
    end
    for (asr,sc) in zip(ASR,range)
        df_ASR_res=DataFrame(hcat(catnames,hcat(asr[:,ssp]...)),:auto)
        rename!(df_ASR_res, [:Boundary, (Symbol(i) for i in 2025:5:2050)...])
        
        if isfile(filename)
            XLSX.openxlsx(filename, mode="rw") do xf
                if sc in XLSX.sheetnames(xf)
                    deletesheet!(xf, sc) 
                end
                ws = XLSX.addsheet!(xf, sc)
                XLSX.writetable!(ws, Tables.columntable(df_ASR_res))
            end
        else
            XLSX.writetable(filename, Tables.columntable(df_ASR_res), sheetname=sc)
        end

    end
end