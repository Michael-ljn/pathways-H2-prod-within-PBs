# # Julia environment settings NOTE: Run this only once
# ENV["PYTHON"] = "/Users/mickael/anaconda3/envs/ab/bin/python3.11"
# using Pkg
# Pkg.build("PyCall")
using PyCall
warn=pyimport("warnings")
warn.filterwarnings("ignore", message="pkg_resources is deprecated as an API")
using PyPlot
import Seaborn
using Plots
# Matplotlib configuration
PyPlot.svg(true)
tkr = pyimport("matplotlib.ticker")
fm = pyimport("matplotlib.font_manager")
nx = pyimport("networkx")



font_prop = fm.FontProperties(fname="/Users/mickael/Library/Fonts/Harding Text Web Regular Regular.ttf",size=10, weight="bold");
rcParams = PyPlot.PyDict(PyPlot.matplotlib."rcParams")

rcParams["font.size"] = 8
rcParams["ytick.right"] = true
rcParams["xtick.top"] = true
rcParams["xtick.bottom"] = true
rcParams["ytick.direction"] = "in"
rcParams["ytick.minor.visible"] = true
rcParams["xtick.direction"] = "in"
rcParams["xtick.minor.visible"] = true
rcParams["figure.facecolor"] = "white"
rcParams["axes.titlesize"] = 11
rcParams["axes.titleweight"] = "bold"
rcParams["axes.labelsize"] = 10
rcParams["legend.fontsize"] = 8
rcParams["xtick.labelsize"] = 8
rcParams["ytick.labelsize"] = 8

font_prop_ticks = fm.FontProperties(fname="/Users/mickael/Library/Fonts/Harding Text Web Regular Regular.ttf",size=8);
font_prop_titles = fm.FontProperties(fname="/Users/mickael/Library/Fonts/Harding Text Web Regular Regular.ttf",size=11, weight="bold");
font_prop_labels = fm.FontProperties(fname="/Users/mickael/Library/Fonts/Harding Text Web Regular Regular.ttf",size=10);
font_prop_legend = fm.FontProperties(fname="/Users/mickael/Library/Fonts/Harding Text Web Regular Regular.ttf",size=6);



function set_color_palette(pal::Union{Symbol,Vector{String},Vector{Union{Symbol,String}}},number;rev=true,set_rcParam=false,show=false)
    function colorpal(i)
        return "#"*string(round(Int, red(i) * 255), base=16, pad=2) * string(round(Int, green(i) * 255), base=16, pad=2) * string(round(Int, blue(i) * 255), base=16, pad=2)
    end
    if show
        display(palette(pal,number, rev=rev))
    end

    magma_r=[colorpal(i) for i in palette(pal,number, rev=rev)]
    if set_rcParam
        # println("Setting rcParams")
        rcParams["axes.prop_cycle"] = plt.cycler("color", magma_r)
    end
    return magma_r
end

alternate_c="#".*["f94144","f3722c","f8961e","f9844a","f9c74f","90be6d","43aa8b","4d908e","577590","277da1"];
set_color_palette(alternate_c[2:end-1],5,set_rcParam=true,show=false,rev=false);
# println(alternate_c);


# Directories for results and data

config_respath = "../Source data/02_results/";
config_datapath = "../Source data/01_input/";
config_suprespath = "../Source data/03_additional_data/";
mkpath(config_respath);
mkpath(config_datapath);
;
