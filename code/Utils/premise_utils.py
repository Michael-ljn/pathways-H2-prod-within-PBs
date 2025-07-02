import numpy as np
import matplotlib.pyplot as plt
import matplotlib.ticker as tkr
import matplotlib.font_manager as fm
import pandas as pd

# Brightway suite
import bw2data as bd
import bw2io as bi
import ecoinvent_interface



font_prop = fm.FontProperties(fname="/Users/mickael/Library/Fonts/Harding Text Web Regular Regular.ttf",size=10, weight="bold");
rcParams = plt.rcParams
# rcParams = PyPlot.PyDict(PyPlot.matplotlib."rcParams")
rcParams["font.size"] = 8
rcParams["ytick.right"] = True
rcParams["xtick.top"] = True
rcParams["xtick.bottom"] = True
rcParams["ytick.direction"] = "in"
rcParams["ytick.minor.visible"] = True
rcParams["xtick.direction"] = "in"
rcParams["xtick.minor.visible"] = True
rcParams["figure.facecolor"] = "white"
# rcParams["font.family"] = ["Harding Text Web Regular Regular"]
# rcParams["font.sans-serif"] = ["Harding Text Web Regular Regular"]
rcParams["axes.titlesize"] = 11
rcParams["axes.titleweight"] = "bold"
rcParams["axes.labelsize"] = 10
rcParams["legend.fontsize"] = 8
rcParams["xtick.labelsize"] = 8
rcParams["ytick.labelsize"] = 8

font_prop_ticks = fm.FontProperties(fname="/Users/mickael/Library/Fonts/Harding Text Web Regular Regular.ttf",size=8)
font_prop_titles = fm.FontProperties(fname="/Users/mickael/Library/Fonts/Harding Text Web Regular Regular.ttf",size=11, weight="bold")
font_prop_labels = fm.FontProperties(fname="/Users/mickael/Library/Fonts/Harding Text Web Regular Regular.ttf",size=10)
font_prop_legend = fm.FontProperties(fname="/Users/mickael/Library/Fonts/Harding Text Web Regular Regular.ttf",size=6)

# pal = ["#001219","#005f73","#0a9396","#94d2bd","#e9d8a6","#ee9b00","#ca6702","#bb3e03","#ae2012","#9b2226"]
pal=["#f94144", "#f3722c", "#f8961e", "#f9844a", "#f9c74f", "#90be6d", "#43aa8b", "#4d908e", "#577590", "#277da1"]
plt.rcParams["axes.prop_cycle"] = plt.cycler('color', pal)
# plt.rcParams['lines.linewidth'] = 1.5

# Premise
import pickle
from premise import *
from datapackage import Package

from .general_utils.passkeys import *
from .general_utils.decryption import *

def ei_import(project_name,version="3.9.1",system_model="cutoff"):
    ei_name = f"ecoinvent-{version}-{system_model}"
    bd.projects.set_current(project_name)
    if ei_name in bd.databases:
        print(f"{ei_name} has already been imported.")
    else:
        bi.import_ecoinvent_release(version=version,system_model=system_model,username=ei_username,password=ei_password)


### Some useful lines of code kept out of the way for now ###
# fp = r"../data/input/Premise/hydrogen_datapackage/datapackage.json"
# hydrogen = Package(fp)

# update the entire database according to the scneario file
# PkBudg500.update()

# How to access the scenario data 
# PkBudg500.scenarios[0]["iam data"].data

# how to export LCA matrices
# PkBudg500.write_db_to_matrices("data/test_20241")

### other function not used
# PkBudg500.write_datapackage("data/datapackage/")
# PkBudg500.generate_scenario_report(filepath="data/1.9a/")
# PkBudg500.write_db_to_brightway(["SSP1-PkBudg500","SSP2-PkBudg500","SSP2-RCP19","SSP5-PkBudg500"])
# PkBudg500.write_superstructure_db_to_brightway("2024_superstructure_data")