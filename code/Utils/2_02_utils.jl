include("./general_utils/config.jl");
include("./general_utils/ssp_utils.jl");


respath = mkpath(config_respath* "2_02_allocated_space/")*"/";
config_respath = mkpath(config_respath* "2_02_allocated_space/")*"/";

rcParams["axes.prop_cycle"] = plt.cycler("color",["#e32f27"
                                                "#fca082"
                                                "#3787c0"]);

EJ_to_kwh=1/3.6e-12
LHVH2=33.33 # kWh/kgH2
EJH2_to_kgH2=1*EJ_to_kwh/LHVH2

function add_missingr(model, scn)
    # Filter AR6a for given model & scenario
    RM = filter(r -> r[:Model] == model && r[:Scenario] == scn, AR6a)

    # Helper to aggregate rows matching a variable pattern
    function aggregate(pattern::String, label::String)
        df = filter(r -> contains(r[:Variable], pattern) && count(==('|'), r[:Variable]) <= 1, RM)
        isempty(df) && error("add_missingr: No '$label' data for $model, $scn")
        row = DataFrame(df[1, :])
        row[1, :Variable] = label
        for col in names(df)[6:end]
            row[1, Symbol(col)] = sum(df[:, Symbol(col)])
        end
        return row
    end

    # Aggregate CCS and Secondary Energy
    new_rowCCS = aggregate("Carbon Sequestration", "Carbon Sequestration")
    new_rowSE  = aggregate("Secondary Energy",      "Secondary Energy")

    # Extract supply and emissions series
    lookup(var) = filter(r -> r[:Variable] == var, RM)
    emi_supply = lookup("Emissions|CO2|Energy|Supply"); isempty(emi_supply) && error("No supply emissions for $model, $scn")
    emi       = lookup("Emissions|CO2");                  isempty(emi) && error("No total emissions for $model, $scn")
    fossil    = lookup("Carbon Sequestration|CCS|Fossil|Energy|Supply")
    bio       = lookup("Carbon Sequestration|CCS|Biomass|Energy|Supply")

    # Build gross supply emissions row
    gross_sup = DataFrame(emi_supply[1, :])
    gross_sup[1, :Variable] = "Emissions|CO2|Gross|Energy|Supply"
    # Sum supply emissions with any available CCS components
    vals = copy(emi_supply[!, 6:end])
    if !isempty(fossil)
        vals .= vals .+ fossil[!, 6:end]
    end
    if !isempty(bio)
        vals .= vals .+ bio[!, 6:end]
    end
    gross_sup[!, 6:end] = vals

    # Build total gross emissions row
    gross_tot = DataFrame(emi[1, :]); gross_tot[1, :Variable] = "Emissions|CO2|Gross"
    gross_tot[!, 6:end] = emi[!, 6:end] .+ new_rowCCS[!, 6:end]

    # Assemble rows in correct order, handling special case
    rows = (model, scn) != ("REMIND 2.1", "CEMICS_HotellingConst_1p5") ? [new_rowSE, gross_sup, gross_tot] : [gross_sup, gross_tot]
    return append!(AR6a, vcat(rows...))
end


# Simplified interpolate_data: linear fill of 5-year steps from 10-year data
function interpolate_data(df)
    years10 = 2020:10:2060
    years5  = 2020:5:2060
    cols10  = string.(years10)
    cols5   = string.(years5)

    # Rows with full 5-year data
    df5 = dropmissing(select(df, cols5))

    # Rows that need interpolation based on 10-year series
    df_gap = filter(r -> any(ismissing, r[cols10]), df)

    # Perform interpolation for each gap row
    interpolated = [
        interpolate((years10,), collect(r[cols10]), Gridded(Linear()))(years5)
        for r in eachrow(df_gap)
    ]

    if !isempty(interpolated)
        df_interp = DataFrame(interpolated, Symbol.(cols5))
        return Matrix(vcat(df_interp, df5))
    else
        return Matrix(df5)
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
function highres(mat)
    original_years = 2020:5:2060
    new_years = 2020:1:2060
    nmat=zeros(length(oo)+3,41)
    for (index, row) in enumerate(eachrow(mat))
        itp = interpolate((original_years,), row, Gridded(Linear()))
        nmat[index,:]= [itp(y) for y in new_years]
    end
    return nmat
end