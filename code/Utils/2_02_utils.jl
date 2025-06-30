include("./general_utils/config.jl");
include("./general_utils/ssp_utils.jl");


respath = mkpath(config_respath* "2_02_allocated_space/")*"/";
config_respath = mkpath(config_respath* "2_02_allocated_space/")*"/";

rcParams["axes.prop_cycle"] = plt.cycler("color",["#e32f27"
                                                "#fca082"
                                                "#3787c0"]);




function add_missingr(model,scn)
    RM=filter(row -> row[:Model]==model && row[:Scenario]==scn, AR6a)
    filtered_CCS = filter(row -> contains(row[:Variable], "Carbon Sequestration") && count(==('|'), row[:Variable]) <= 1, RM)
        new_rowCCS = DataFrame(filtered_CCS[1, :])
        new_rowCCS[1, :Variable] = "Carbon Sequestration"
        for col in names(filtered_CCS)[6:end]
            new_rowCCS[1, Symbol(col)] = sum(filtered_CCS[:, Symbol(col)])
        end

        filtered_SE = filter(row -> contains(row[:Variable], "Secondary Energy") && count(==('|'), row[:Variable]) <= 1, RM)
        new_rowSE  = DataFrame(filtered_SE[1, :])
        new_rowSE[1, :Variable] = "Secondary Energy"
        for col in names(filtered_SE)[6:end]
            new_rowSE[1, Symbol(col)] = sum(filtered_SE[:, Symbol(col)])
        end
    
        bioCCSsupply = filter(row -> row[:Variable]=="Carbon Sequestration|CCS|Biomass|Energy|Supply", RM)
        CCSsupply = filter(row -> row[:Variable]=="Carbon Sequestration|CCS|Fossil|Energy|Supply", RM)
        Emi_supply = filter(row -> row[:Variable]=="Emissions|CO2|Energy|Supply", RM)
        Emi = filter(row -> row[:Variable]=="Emissions|CO2", RM)
        
        emi_gross_suply= DataFrame(Emi_supply[1, :])
        emi_gross_suply[1, :Variable] = "Emissions|CO2|Gross|Energy|Supply"


        if size(CCSsupply)[1]>0 && size(bioCCSsupply)[1]>0
            emi_gross_suply[!, 6:end] = Emi_supply[!, 6:end] .+ CCSsupply[!, 6:end] .+ bioCCSsupply[!, 6:end]
        elseif size(CCSsupply)[1]>0 && size(bioCCSsupply)[1]==0
            emi_gross_suply[!, 6:end] = Emi_supply[!, 6:end] .+ CCSsupply[!, 6:end]  # .+ bioCCSsupply[!, 6:end]
        elseif size(CCSsupply)[1]==0 && size(bioCCSsupply)[1]>0
            emi_gross_suply[!, 6:end] = Emi_supply[!, 6:end] .+ bioCCSsupply[!, 6:end] # .+ CCSsupply[!, 6:end]
        else 
            println("No CCS option for SE for the model $model and scenario $scn")
            emi_gross_suply[!, 6:end] = Emi_supply[!, 6:end]
        end

        emi_gross= DataFrame(Emi[1, :])
        emi_gross[1, :Variable] = "Emissions|CO2|Gross"
        emi_gross[!, 6:end] = Emi[!, 6:end].+ new_rowCCS[!, 6:end]

        if (model,scn)!=("REMIND 2.1", "CEMICS_HotellingConst_1p5")
            d1=append!(new_rowSE,emi_gross_suply)
            d2=append!(d1,emi_gross)
            return append!(AR6a,d2)
        else
            d1=append!(emi_gross_suply,emi_gross)
            return append!(AR6a,d1)
        end
        # d3=append!(d2,new_rowCCS)
end
function has_missing_values_in_range(row, year_range)
    for year in year_range
        if ismissing(row[string(year)])
            return true
        end
    end
    return false
end
function interpolate_data(df)

    years_5_step = 2020:5:2060
    years_10_step = 2020:10:2060
    cols_in_range = [string(year) for year in years_5_step if string(year) in names(AR6a)]
    df5=df[:,cols_in_range]|>dropmissing


    year_range5 = 2025:5:2055
    df_filtered = filter(row -> has_missing_values_in_range(row, year_range5), df)

    # Create a matrix for interpolation
    
    df_interpolated = DataFrame()

    # Iterate over each row of the DataFrame
    for i in 1:size(df_filtered, 1)
        # Extract the 10-year step data for the current row
        row_data = df_filtered[i, string.(years_10_step)]
        values = collect(row_data)

        # Create an interpolation function
        itp = interpolate((years_10_step,), values, Gridded(Linear()))

        # Generate the new 5-year step data
        values_5_step = itp.(years_5_step)

        # Create a new DataFrame with the interpolated data
        df_row_interpolated = DataFrame(Row = i, Year = years_5_step, Value = values_5_step)

        # Add the interpolated data to the results DataFrame
        df_interpolated = vcat(df_interpolated, df_row_interpolated)
    end
    # # Reshape the DataFrame back to the original format

    if size(df_interpolated)[1]>0
        df_wide = unstack(df_interpolated, :Year, :Value; combine = first)
        return vcat(df_wide[:,2:end],df5)|>Matrix 
    else
        df_wide = df5
        return df5|>Matrix
    end
   
end

function highres(mat,oo)
    original_years = 2020:5:2060
    new_years = 2020:1:2060
    nmat=zeros(length(oo)+3,41)
    for (index, row) in enumerate(eachrow(mat))
        itp = interpolate((original_years,), row, Gridded(Linear()))
        nmat[index,:]= [itp(y) for y in new_years]
    end
    return nmat
end