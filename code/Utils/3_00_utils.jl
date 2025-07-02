using PyCall

bd = pyimport("bw2data")
bi = pyimport("bw2io")
eio = pyimport("ecoinvent_interface")

sys = pyimport("sys")
# pushfirst!(sys["path"], joinpath(@__DIR__, "Utils"))
pushfirst!(sys["path"], joinpath(@__DIR__))


# # Premise
# import pickle
# from premise import *
# from datapackage import Package

# from general_utils.passkeys import *

# def ei_import(project_name,version="3.9.1",system_model="cutoff"):
#     ei_name = f"ecoinvent-{version}-{system_model}"
#     bd.projects.set_current(project_name)
#     if ei_name in bd.databases:
#         print(f"{ei_name} has already been imported.")
#     else:
#         bi.import_ecoinvent_release(version=version,system_model=system_model,username=ei_username,password=ei_password)

