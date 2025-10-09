using PyCall
using PyPlot

pushfirst!(pyimport("sys")."path", "./planetary-boundaries-visualisation/source");
pb= pyimport("PB4");
PyPlot.svg(true)
tkr=pyimport("matplotlib.ticker")

fm=pyimport("matplotlib.font_manager")
font_prop = fm.FontProperties(fname="/Users/mickael/Library/Fonts/Harding Text Web Regular Regular.ttf",size=10, weight="bold");
rcParams = PyPlot.PyDict(PyPlot.matplotlib."rcParams")
rcParams["font.size"] = 8

font_prop_ticks = fm.FontProperties(fname="/Users/mickael/Library/Fonts/Harding Text Web Regular Regular.ttf",size=8);
font_prop_titles = fm.FontProperties(fname="/Users/mickael/Library/Fonts/Harding Text Web Regular Regular.ttf",size=11, weight="bold");
font_prop_labels = fm.FontProperties(fname="/Users/mickael/Library/Fonts/Harding Text Web Regular Regular.ttf",size=10);
font_prop_legend = fm.FontProperties(fname="/Users/mickael/Library/Fonts/Harding Text Web Regular Regular.ttf",size=6);


# ASR1=[[68.74067820317244, 71.03041919054864, 34.774681118853685, -37.604505315723046, 16.43542427256074, 46.06502671606711, 13.187003949086417, 12.588207309850208, 83.57443062800218, 17.35816190253552],
#  [53.140908099018006, 54.880908480478126, 26.362042850595707, -28.7496376382472, 12.304857605507898, 36.98845024348026, 9.749665293540119, 9.62573114615943, 66.66173234824808, 12.976815383434607],
#  [43.27619929661161, 44.685705478633714, 20.95812071280091, -23.174480078884688, 9.576056743571606, 31.23697876615428, 7.396949073333978, 7.790619687774011, 55.96144470419866, 10.090128144757143],
#  [40.0288337360242, 41.30549085888848, 19.15175505049916, -21.334935124501328, 8.72005563244028, 30.090932165148796, 6.6181336538057245, 7.062234868509222, 53.304854726323555, 9.19274317419553],
#  [37.275253078197736, 38.33210848958359, 17.499227051653815, -19.72305707887253, 8.18685667591015, 32.02148772600313, 6.0328558782394595, 5.950584449631086, 54.486763822098865, 8.65457384203294],
#  [34.251753602105055, 35.07265693847176, 15.696932000903136, -17.96195815241014, 7.595838338802221, 33.938560218845694, 5.391940714366681, 4.7631916136859225, 55.53769813489924, 8.056153331033928]]

# ASR2=[[97.3794419585048, 100.62313558225958, 49.262520099527386, -53.27130657552544, 23.282756089237512, 65.25665315893272, 18.68097783194944, 17.832710341729083, 118.39323715283082, 24.589924971329086],
#  [75.28049054965156, 77.74541045709513, 37.34500573430081, -40.72732104049176, 17.431311391221087, 52.39859043831485, 13.811574025513798, 13.636006393261692, 94.43436500398128, 18.383220437576114],
#  [61.305943551115355, 63.30267865804423, 29.689699794340186, -32.8294395218249, 13.565636624879026, 44.25093903972255, 10.478668406904067, 11.036350201027869, 79.27612003448478, 14.29388062076041],
#  [56.705659492371886, 58.51419792182161, 27.130765481122545, -30.22350274904562, 12.35300805186065, 42.62742613031391, 9.375382653478956, 10.004505460983127, 75.51274067425474, 13.022626831309054],
#  [52.80488116350027, 54.302044020802875, 24.789760728845636, -27.94008354674201, 11.597667572293421, 45.36229037809212, 8.546266260316463, 8.429718882309325, 77.18705712269166, 12.260245216593537],
#  [48.52173035033084, 49.68463870222393, 22.236592926690086, -25.445275011601378, 10.760418982968948, 48.07805423766942, 7.6383328119991845, 6.747634056085856, 78.67583203138642, 11.41251055727914]]

# ASR3=[[51.29283949606263, 53.00139576904428, 25.94813120528397, -28.059686140821327, 12.263765812296628, 34.372748181876716, 9.839863304741407, 9.39305392331015, 62.36147166757366, 12.95229310630126],
#  [39.65262114146773, 40.95097260703711, 19.67079854416576, -21.452371252288845, 9.181624369718454, 27.599998881875635, 7.274993935378518, 7.182516897097192, 49.741574090410616, 9.683025044722777],
#  [32.291784174138016, 33.34352786147089, 15.638506194010619, -17.292306653967156, 7.145450909015589, 23.308372568839797, 5.51944687623927, 5.8131955585130655, 41.757245872616, 7.529040110632003],
#  [29.86866870832982, 30.82128323885624, 14.29063436019204, -15.919677134483841, 6.506720993201577, 22.453216845955623, 4.938311290220601, 5.269690219280127, 39.77495464558955, 6.859430434609466],
#  [27.814005088283704, 28.602608232793536, 13.057552935580608, -14.716927844793977, 6.108859214533445, 23.8937565541682, 4.50158939879551, 4.440200199662959, 40.65687020320682, 6.457859866819448],
#  [25.557933757633187, 26.17047445660023, 11.712718505965746, -13.402833091397222, 5.667853837558451, 25.32423548233729, 4.023352065524597, 3.5541927911690028, 41.44105514924488, 6.0113311443197714]]
categories=["Energy  Imbalance",
            "CO2  Concentration",
            "Ocean  Acidification",
            "Atmospheric  Aerosol  Loading",
            "Freshwater  Use",
            "Biogeochemical  Flows  P",
            "Biogeochemical  Flows  N",
            "Stratospheric  Ozone  Depletion",
            "Land-System  Change",
            "Biosphere  Integrity"
            ]
pal = ["#001219","#005f73","#0a9396","#94d2bd","#e9d8a6","#ee9b00","#ca6702","#bb3e03","#ae2012","#9b2226"]
offsets=Dict(
                10 => 0,  # For 10 categories
                9 => 0.2,   # For 9 categories
                8 => 0.4,   # For 8 categories
                )
# typeof(ASR1)
function pbplot(mean::Vector{Vector{Float64}}, upper::Vector{Vector{Float64}}, lower::Vector{Vector{Float64}};
                axis=nothing,categories=categories,
                legend=["2025", "2030", "2035", "2040", "2045", "2050"],
                figsize=(5, 5), scale=4, minscale=-2, median_lw=0.8,pal=pal)

    offsetcat=offsets[length(categories)]

    if isnothing(axis)
        fig, ax = plt.subplots(subplot_kw=Dict("projection" => "polar"),
                               figsize=figsize)
 
        ax,legend_elements= pb.PBchart_(categories=categories,
                                    values=mean,upper=upper, lower=lower,
                                    legend=legend,
                                    figsize=(5, 5),
                                    offsetcat=offsetcat, scale=scale, minscale=minscale, median_lw=0.8,axis=ax,pal=pal)
        return fig,ax,legend_elements
    else
        ax,legend_elements= pb.PBchart_(categories=categories,
                                    values=mean,upper=upper, lower=lower,
                                    legend=legend,
                                    figsize=(5, 5),
                                    offsetcat=offsetcat, scale=scale, minscale=minscale, median_lw=0.8,axis=axis,pal=pal)
        return ax,legend_elements
    end

end
function pbplot(vals::Vector{Vector{Float64}};
                axis=nothing,categories=categories,
                legend=["2025", "2030", "2035", "2040", "2045", "2050"],
                figsize=(5, 5), scale=4, minscale=-2, median_lw=0.8,pal=pal)

    offsetcat=offsets[length(categories)]
    if isnothing(axis)
        fig, ax = plt.subplots(subplot_kw=Dict("projection" => "polar"))

        ax,legend_elements= pb.PBchart_(categories=categories,
                        values=vals,
                        legend=legend,
                        figsize=figsize,
                        offsetcat=offsetcat, scale=scale, minscale=minscale, median_lw=0.8,axis=axis,pal=pal)
    
        return fig, axis,legend_elements
    else
        ax,legend_elements= pb.PBchart_(categories=categories,
                        values=vals,
                        legend=legend,
                        figsize=figsize,
                        offsetcat=offsetcat, scale=scale, minscale=minscale, median_lw=0.8,axis=axis,pal=pal)
        return ax,legend_elements
    end
end
function pbplot(mean::Vector, upper::Vector, lower::Vector;
                axis=nothing,categories=categories,
                legend=["2025", "2030", "2035", "2040", "2045", "2050"],
                figsize=(5, 5), scale=4, minscale=-2, median_lw=0.8,pal=pal)
    offsetcat=offsets[length(categories)]
    if isnothing(axis)
        fig, ax = plt.subplots(subplot_kw=Dict("projection" => "polar"),
                               figsize=figsize)
 
        ax,legend_elements= pb.PBchart(categories=categories,
                                    values=[mean],upper=[upper], lower=[lower],
                                    legend=legend,
                                    figsize=(5, 5),
                                    offsetcat=offsetcat, scale=4, minscale=-2, median_lw=0.8,axis=ax,pal=pal)
        return fig,ax,legend_elements
    else
        ax,legend_elements= pb.PBchart(categories=categories,
                                    values=[mean],upper=[upper], lower=[lower],
                                    legend=legend,
                                    figsize=(5, 5),
                                    offsetcat=offsetca, scale=4, minscale=-2, median_lw=0.8,axis=axis,pal=pal)
        return ax,legend_elements
    end

end
function pbplot(vals::Vector;
                axis=nothing,categories=categories,
                legend=["2025", "2030", "2035", "2040", "2045", "2050"],
                figsize=(5, 5), scale=4, minscale=-2, median_lw=0.8)
    
    offsetcat=offsets[length(categories)]
    if isnothing(axis)
        fig, axis = plt.subplots(subplot_kw=Dict("projection" => "polar"))
        ax,legend_elements= pb.PBchart_(categories=categories,
                            values=[vals],
                            legend=legend,
                            figsize=figsize,
                            offsetcat=offsetcat, scale=scale, minscale=minscale, median_lw=0.8,axis=axis,pal=pal)
    
        return fig, ax, legend_elements
    else
        ax,legend_elements= pb.PBchart_(categories=categories,
                        values=[vals],
                        legend=legend,
                        figsize=figsize,
                        offsetcat=offsetcat, scale=scale, minscale=minscale, median_lw=0.8,axis=axis,pal=pal)
        return ax,legend_elements
    end
end