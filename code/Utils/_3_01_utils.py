import numpy as np
import matplotlib.pyplot as plt
import matplotlib.ticker as tkr
import matplotlib.font_manager as fm
import pandas as pd

# Brightway suite
import bw2data as bd
import bw2io as bi
import ecoinvent_interface

# Premise
import pickle
from premise import *
from datapackage import Package

from .general_utils.passkeys import *
from .general_utils.decryption import *


font_prop = fm.FontProperties(fname="/Users/mickael/Library/Fonts/Harding Text Web Regular Regular.ttf",size=10, weight="bold");
rcParams = plt.rcParams
rcParams["font.size"] = 8
rcParams["ytick.right"] = True
rcParams["xtick.top"] = True
rcParams["xtick.bottom"] = True
rcParams["ytick.direction"] = "in"
rcParams["ytick.minor.visible"] = True
rcParams["xtick.direction"] = "in"
rcParams["xtick.minor.visible"] = True
rcParams["figure.facecolor"] = "white"
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

pal=["#f94144", "#f3722c", "#f8961e", "#f9844a", "#f9c74f", "#90be6d", "#43aa8b", "#4d908e", "#577590", "#277da1"]
plt.rcParams["axes.prop_cycle"] = plt.cycler('color', pal)


def ei_import(project_name,version="3.9.1",system_model="cutoff"):
    ei_name = f"ecoinvent-{version}-{system_model}"
    bd.projects.set_current(project_name)
    if ei_name in bd.databases:
        print(f"{ei_name} has already been imported.")
    else:
        bi.import_ecoinvent_release(version=version,system_model=system_model,username=ei_username,password=ei_password)
