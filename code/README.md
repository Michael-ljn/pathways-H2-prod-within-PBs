[![DOI](https://zenodo.org/badge/940091341.svg)](https://doi.org/10.5281/zenodo.14939868) <a href="https://www.globh2e.org.au/"><img src="https://img.shields.io/badge/ARC:Funding%20number-IC200100023-blue.svg"/></a>

# **Code structure**

<div style="text-align: left; font-size: 16px;">Michaël Lejeune<sup>a,b</sup>, Sami Kara<sup>a,b</sup>, Michael Zwicky Hauschild<sup>c,d</sup>, Sareh Sharabifarahni<sup>a</sup>, Rahman Daiyan<sup>b,e</sup></div><br>
<div style="text-align: left; font-size: 13px;"><sup>a</sup>Sustainability in Manufacturing and Life Cycle Engineering Research Group, School of Mechanical and Manufacturing Engineering, the University of New South Wales, 2052, Sydney, Australia</div>

<div style="text-align: left; font-size: 13px;">
<sup>b</sup>Australian Research Council Training Centre for the Global Hydrogen Economy (GlobH2e), the University of New South Wales, 2052, Sydney, Australia</div>

<div style="text-align: left; font-size: 13px;">
<sup>c</sup>Centre for Absolute Sustainability, Technical University of Denmark, Kgs, Lyngby, Denmark</div>

<div style="text-align: left; font-size: 13px;">
<sup>d</sup>Section for Quantitative Sustainability Assessment (QSA), Department of Environmental and Resource Engineering, Technical University of Denmark, Kgs, Lyngby, Denmark</div>

<div style="text-align: left; font-size: 13px;">
<sup>e</sup>School of Minerals and Energy Engineering, The University of New South Wales, Sydney 2052, Australia</div>

---

> [!CAUTION]<br>
> The underlying work for this repository is currently under review. Until the work is accepted for publication, all content should be considered as preliminary draft and may contain errors.

> [!IMPORTANT]<br>
> The underlying code [lce.jl](https://github.com/Michael-ljn/lce.jl) for data pre-processing is not provided in this repository. As demonstrated in the [Tutorial](./../Tutorial/), the code is not required for reproducing the results. Therefore, access to this code can be provided upon reasonable request to the corresponding authors.

# Description of files

0. [Main.ipynb](./0_Main.ipynb) is the notebook we use to run the analysis. It is based on [mainl.jl](./Main/main.jl) where the code to generate figures is provided. The code should be relatively straightforward for Matplotlib users. The underlying code is described below:

    - The inventory can be found here: [inventory.jl](./Main/modules/inventories.jl).
    - The optimisation code can be found here: [optimisation.jl](./Main/modules/optimisation.jl). 
    - For technology contraints, we used [constraints.jl](./Main/modules/constraints.jl). 

1. Calculations for the global safe operating space and interaction matrices can be found in the [1_Planetary boundaries and interaction model.ipynb](./1_Planetary%20boundaries%20and%20interaction%20model.ipynb) notebook.

2. AR6 data processing and generation of Fig.2 can be found in [2_space_allocation.ipynb](./2_space_allocation.ipynb).

3. Generation of prospective life cycle assessment matrices is demonstrated in [3_pLCA_data.ipynb](./3_pLCA_data.ipynb).

4. The code used to calculate the hydrogen characterisation factor is given in [Hydrogen_CO2 characterisation.jl](./Hydrogen_CO2%20characterisation.jl). In this file, you will also find the code to generate a $CO_2$ decay matrix based on the integrated Impulse Response Function (IRF) method (Ocko and Hamburg, 2022).



# References

1. Ocko, I.B. and Hamburg, S.P. (2022) ‘Climate consequences of hydrogen emissions’, Atmospheric Chemistry and Physics, 22(14), pp. 9349–9368. Available at: https://doi.org/10.5194/acp-22-9349-2022.

