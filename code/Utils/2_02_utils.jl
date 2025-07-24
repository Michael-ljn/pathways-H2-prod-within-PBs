include("./general_utils/config.jl");
include("./general_utils/ssp_utils.jl");
using DataFrames, Interpolations,CSV

respath = mkpath(config_respath* "2_02_allocated_space/")*"/";
config_respath = mkpath(config_respath* "2_02_allocated_space/")*"/";

rcParams["axes.prop_cycle"] = plt.cycler("color",["#e32f27"
                                                "#fca082"
                                                "#3787c0"]);


AR6 = CSV.read("../Source data/01_input/IPCC AR6 scenarios/AR6_Scenarios_Database_World_v1.1.csv", DataFrame);
rmd_SSP1 = CSV.read(scenario_path*"remind_SSP1-PkBudg500.csv", DataFrame) # REMIND SSP1-pkbudg500
rmd_SSP2 = CSV.read(scenario_path*"remind_SSP2-PkBudg500.csv", DataFrame) # REMIND SSP2-pkbudg500
rmd_SSP5 = CSV.read(scenario_path*"remind_SSP5-PkBudg500.csv", DataFrame) # REMIND SSP5-pkbudg500
rmd_scenarios=vcat(rmd_SSP1, rmd_SSP2,rmd_SSP5);
img_SSP2 = CSV.read(scenario_path*"image_SSP2-RCP19.csv", DataFrame) # IMAGE SSP2-1.9
tucl_SSP2 = CSV.read(scenario_path*"tiam-ucl_SSP2-RCP19.csv", DataFrame) # TIAM-UCL SSP2-1.9
# other_scenarios=vcat(img_SSP2,tucl_SSP2);

"""
    fill_missing!(df)
In‑place: for each row of `df`, any missing entries are filled by linear
interpolation of the non‑missing columns. Assumes column names are the years
(e.g. "2020","2025",…).
"""
function fill_missing!(df::DataFrame)
    yrs = parse.(Float64, names(df))
    mat = Matrix{Union{Missing,Float64}}(df)

    for i in 1:size(mat,1)
        row   = mat[i, :]
        good  = .!ismissing.(row)
        # need at least two known points
        if sum(good) < 2
            continue
        end

        # # build a Gridded(Linear) interpolant…
        # base_itp = interpolate((yrs[good],), Float64.(row[good]), Gridded(Linear()))
        # # …and wrap it so it *extrapolates* linearly outside the domain
        # itp      = extrapolate(base_itp, Line())

        # # fill every missing slot
        # for j in findall(ismissing, row)
        #     mat[i, j] = itp(yrs[j])
        # end

        itp = LinearInterpolation(
                                    Float64.(yrs[good]),             # x‑coords of known points
                                    Float64.(row[good]),             # y‑coords of known points
                                    extrapolation_bc = Line()        # allows linear extrapolation
                                )

        # fill every missing slot
        for j in findall(ismissing, row)
            mat[i, j] = itp( Float64(yrs[j]) )  # query at the missing year
        end

        


    end

    # write back
    for (j, col) in enumerate(names(df))
        df[!, col] = mat[:, j]
    end

    return df
end

function add_gross_emissions_rows(df::DataFrame)
    # 1) All column names (as Strings)
    cols = names(df)
    # 2) Year columns = exactly four‑digit names
    year_cols = filter(n -> occursin(r"^\d{4}$", n), cols)
    # 3) Metadata = everything except "Variable" & the years
    meta_cols = setdiff(cols, vcat("Variable", year_cols))

    # 4) Prepare an empty clone for the new rows
    gross = df[1:0, cols]

    # 5) Loop per metadata group
    for sub in groupby(df, meta_cols)
        # If they already have a Gross row, skip
        if any(sub.Variable .== "Emissions|CO2|Gross")
            continue
        end

        # a) base emissions row (skip if missing)
        em = sub[sub.Variable .== "Emissions|CO2", year_cols]
        isempty(em) && continue
        emv = vec(Matrix{Float64}(em))

        # b) sum whatever Carbon Sequestration rows are present
        cs = sub[startswith.(sub.Variable, "Carbon Sequestration|"), year_cols]
        csv = isempty(cs) ? zeros(length(year_cols)) :
              vec(sum(Float64.(Matrix(cs)); dims=1))

        # c) compute Gross = Em + CS
        grossv = emv .+ csv

        # d) assemble a NamedTuple row (Symbol keys) and push!
        pairs = Pair{Symbol,Any}[]
        for col in cols
            key = Symbol(col)
            val = col == "Variable" ? "Emissions|CO2|Gross" :
                  col in year_cols    ? grossv[findfirst(==(col), year_cols)] :
                  sub[1, col]          # copy metadata
            push!(pairs, key => val)
        end
        push!(gross, (; pairs...))
    end

    return gross
end

function add_gross_supply_rows(df::DataFrame)
    # 1) all column names as Strings
    cols      = names(df)
    # 2) pick out your years (4‑digit names)
    year_cols = filter(n -> occursin(r"^\d{4}$", n), cols)
    # 3) metadata = everything except "Variable" & the years
    meta_cols = setdiff(cols, vcat("Variable", year_cols))

    # 4) prepare empty DataFrame for the new rows
    gross_sup = df[1:0, cols]

    # 5) group and process
    for sub in groupby(df, meta_cols)
        # skip if already computed
        if any(sub.Variable .== "Emissions|CO2|Gross|Energy|Supply")
            continue
        end

        # a) base supply emissions
        sup_df = sub[sub.Variable .== "Emissions|CO2|Energy|Supply", year_cols]
        isempty(sup_df) && continue
        supv = vec(Matrix{Float64}(sup_df))

        # b) fossil CCS on energy supply
        fccs_df = sub[sub.Variable .== "Carbon Sequestration|CCS|Fossil|Energy|Supply", year_cols]
        fccsv   = isempty(fccs_df) ? zeros(length(year_cols)) :
                  vec(Matrix{Float64}(fccs_df))

        # c) biomass CCS on energy supply
        bccs_df = sub[sub.Variable .== "Carbon Sequestration|CCS|Biomass|Energy|Supply", year_cols]
        bccsv   = isempty(bccs_df) ? zeros(length(year_cols)) :
                  vec(Matrix{Float64}(bccs_df))

        # d) compute gross supply = supply + fossil CCS + biomass CCS
        grossv = supv .+ fccsv .+ bccsv

        # e) assemble a NamedTuple row and push!
        pairs = Pair{Symbol,Any}[]
        for col in cols
            key = Symbol(col)
            val = col == "Variable" ? "Emissions|CO2|Gross|Energy|Supply" :
                  col in year_cols    ? grossv[findfirst(==(col), year_cols)] :
                  sub[1, col]
            push!(pairs, key => val)
        end
        push!(gross_sup, (; pairs...))
    end

    return gross_sup
end

function add_secondary_energy_rows(df::DataFrame)
    cols      = names(df)
    # pick your year columns (4‑digit names)
    year_cols = filter(c->occursin(r"^\d{4}$", c), cols)
    # metadata = everything except "Variable" + the years
    meta_cols = setdiff(cols, vcat("Variable", year_cols))

    sec = df[1:0, cols]   # empty clone for new rows

    for sub in groupby(df, meta_cols)
        # skip if they already have a top‑level Secondary Energy
        if any(sub.Variable .== "Secondary Energy")
            continue
        end

        # pick only those detail rows "Secondary Energy|x" with exactly one '|'
        detail = filter(r -> startswith(r.Variable, "Secondary Energy|") &&
                             count(==('|'), r.Variable) == 1,
                        sub)

        isempty(detail) && continue  # nothing to sum? skip

        # 1) interpolate any missing in‑place
        temp = detail[:, year_cols]  |> fill_missing!  

        # 2) now convert to Float64 safely
        mat  = Float64.(Matrix(temp))

        # 3) sum across columns
        sumv = vec(sum(mat; dims=1))

        # build one new NamedTuple row and push!
        pairs = Pair{Symbol,Any}[]
        for c in cols
            key = Symbol(c)
            val = c == "Variable" ? "Secondary Energy" :
                  c in year_cols    ? sumv[findfirst(==(c), year_cols)] :
                  sub[1, c]         # copy metadata
            push!(pairs, key => val)
        end
        push!(sec, (; pairs...))
    end

    return sec
end

"""
    AR6database_formating(target; accepted_models=accepted_mods, rejected_scenarios=rejected_scenarios, database=AR6)
This function formats the AR6 database to include only scenarios that meet the specified target and criteria.
- `target`: The target year for the climate diagnostics.
- `accepted_models`: A list of models that are accepted.
- `rejected_scenarios`: A list of scenarios that are rejected.
- `database`: The AR6 database to be filtered and formatted.
"""
function AR6database_formating(target;
                            accepted_models=accepted_mods,
                            rejected_scenarios=rejected_scenarios,
                            database=AR6,
                            debug=false,
                            itp_start=2020)

    AR6_filtered = filter(row -> !ismissing(row["2100"]) && row["2100"] <= target && row[:Variable] == "AR6 climate diagnostics|Effective Radiative Forcing|MAGICCv7.5.3|50.0th Percentile" && row[:Region] == "World", database);

    mask = Set((s[:Model], s[:Scenario]) for s in eachrow(AR6_filtered) if 
                any(mod -> occursin(mod, s[:Model]), accepted_models) && 
                all(mod -> !(occursin(mod, s[:Scenario]) && 
                            !(occursin("REMIND", s[:Model]) && occursin("CD-LINKS", s[:Scenario]))
                            ), 
                    rejected_scenarios
                    ))
                
    AR6a = filter(row -> (row[:Model], row[:Scenario]) in mask, AR6) # filtering the original AR6 database
    AR6° = filter(row -> (row[:Model], row[:Scenario]) in mask, AR6)
    
    ## Now we need to make sure the AR6 scenarios have the variables we need to derive the allocated space. We therefore filter out any model lacking the variables below.

    # df = your filtered & formatted AR6a
    sec_rows = add_secondary_energy_rows(AR6a)
    AR6a = vcat(AR6a, sec_rows; cols = :union)


    groups   = groupby(AR6a, [:Model, :Scenario])
    good_grps = filter(g ->
        # at least one “Carbon Sequestration|…” row
        any(contains.(g.Variable, "Carbon Sequestration|"))  &&
        # at least one “Secondary Energy|…” row
        any(contains.(g.Variable, "Secondary Energy|"))     &&
        # exact “Secondary Energy|Hydrogen” row
        "Secondary Energy|Hydrogen" ∈ g.Variable            &&
        # exact “Emissions|CO2|Energy|Supply” row
        "Secondary Energy" ∈ g.Variable,
    groups)

    AR6a_meta = vcat(good_grps...)[:,names(AR6a)[1:5]]
    AR6a_data = vcat(good_grps...)[:,string.(itp_start:1:2100)]|>fill_missing! # we perform a linear interpolation at this point to increase datapoints.
    AR6a=hcat(AR6a_meta, AR6a_data);

    ## now data the scenarios from the AR6 databased are formatted, we add the premise scenarios that we know lead to the climate target.
    AR6a⁰ = AR6a[1:0, :]  
    AR6a⁰ = vcat(AR6a⁰,rmd_scenarios; cols = :union) # 
    #AR6a⁰ = vcat(AR6a⁰, other_scenarios; cols = :union) # we do not include these because they lack variables to derive the allocated space.

    AR6a⁰_meta=AR6a⁰[:,names(AR6a)[1:5]]
    AR6a⁰_data=AR6a⁰[:,string.(itp_start:1:2100)]|>fill_missing!
    AR6a⁰=hcat(AR6a⁰_meta, AR6a⁰_data)
    AR6a⁰=filter(row -> row[:Region] == "World", AR6a⁰)

    # # concatenating the dataframes
    AR6a=vcat(AR6a,AR6a⁰);
    select!(AR6a, Not(:Region));# we remove the region as everything is for the world.

    var_mapping=Dict(

        # Emission data
        "Emi|CO2|Gross" => "Emissions|CO2|Gross",
        "Emi|CO2|Gross|Energy|+|Supply" => "Emissions|CO2|Gross|Energy|Supply",
        "Emi|CO2|Gross|Energy|Supply|+|Hydrogen" => "Emissions|CO2|Gross|Energy|Supply|Hydrogen",
        "Emi|CO2" => "Emissions|CO2",

        # Secondary energy data
        "SE" => "Secondary Energy",
        "SE|Hydrogen" => "Secondary Energy|Hydrogen",
        "SE|Hydrogen|+|Electricity" => "Secondary Energy|Hydrogen|Electricity",
        "SE|Hydrogen|Coal|+|w/ CC" => "Secondary Energy|Hydrogen|Coal|w/ CC",
        "SE|Hydrogen|Coal|+|w/o CC" => "Secondary Energy|Hydrogen|Coal|w/o CC",
        "SE|Hydrogen|Biomass|+|w/ CC" => "Secondary Energy|Hydrogen|Biomass|w/ CC",
        "SE|Hydrogen|Biomass|+|w/o CC" => "Secondary Energy|Hydrogen|Biomass|w/ oCC",
        "SE|Hydrogen|Gas|+|w/ CC" => "Secondary Energy|Hydrogen|Gas|w/ CC",
        "SE|Hydrogen|Gas|+|w/o CC" => "Secondary Energy|Hydrogen|Gas|w/o CC",

        "SE|Electricity|+|Biomass" => "Secondary Energy|Electricity|Biomass",
        "SE|Electricity|+|Gas" => "Secondary Energy|Electricity|Gas",
        "SE|Electricity|Gas|+|w/ CC" => "Secondary Energy|Electricity|Gas|w/ CCS",
        "SE|Electricity|Gas|+|w/o CC" => "Secondary Energy|Electricity|Gas|w/o CCS",
        "SE|Electricity|+|Coal" => "Secondary Energy|Electricity|Coal",
        "SE|Electricity|Coal|+|w/ CC" => "Secondary Energy|Electricity|Coal|w/ CCS",
        "SE|Electricity|Coal|+|w/o CC" => "Secondary Energy|Electricity|Coal|w/o CCS",
        "SE|Electricity|Oil|w/o CC" => "Secondary Energy|Electricity|Oil|w/o CCS",
        "SE|Electricity|+|Geothermal" => "Secondary Energy|Electricity|Geothermal",
        "SE|Electricity|+|Hydro" => "Secondary Energy|Electricity|Hydro",
        "SE|Electricity|+|Nuclear" => "Secondary Energy|Electricity|Nuclear",
        "SE|Electricity|+|Wind" => "Secondary Energy|Electricity|Wind",
        "SE|Electricity|+|Solar" => "Secondary Energy|Electricity|Solar",
        "SE|Electricity|Solar|+|PV" => "Secondary Energy|Electricity|Solar|PV",
        "SE|Electricity|Solar|+|CSP" => "Secondary Energy|Electricity|Solar|CSP",

        #### carbon sequestration


        ### efficiencies
        "Tech|Hydrogen|Electricity|Efficiency" => "Efficiency|Hydrogen|Electricity",
    )

    AR6a[!,:Variable] = [ get(var_mapping, v, v) for v in AR6a.Variable];

    df=AR6a;
    df_gross = add_gross_emissions_rows(AR6a)
    df_full  = vcat(AR6a, df_gross; cols = :union);
    df_gross_sup = add_gross_supply_rows(df_full)
    df=vcat(df_full, df_gross_sup; cols=:union)

    if debug
        @info "Debug mode: AR6 database aligned with the target with and without formatting returned as tuple"
        return df, AR6°
    else
        return df
    end
    
end

### constants
EJ_to_kwh=1/3.6e-12
LHVH2=33.33 # kWh/kgH2
EJH2_to_kgH2=1*EJ_to_kwh/LHVH2