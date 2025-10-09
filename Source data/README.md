[![DOI](https://zenodo.org/badge/940091341.svg)](https://doi.org/10.5281/zenodo.14939868) <a href="https://www.globh2e.org.au/"><img src="https://img.shields.io/badge/ARC:Funding%20number-IC200100023-blue.svg"/></a>

# **Source data**

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


This folder contains all results generated in the paper. It is organised by by figures, supplementary figures and supplementary data. below is a description of the files:

# **1. Manuscript figures**

- **[Fig.1](./Fig1/): General framework used in the study available in PDF format.**
- **[Fig.2](./Fig2/): Future emissions, hydrogen production volumes and environmental space for global hydrogen production.** All figures are available in vector format along with all data in excel format described below:

    - [Fig.2a.xlsx](./Fig2/Fig2a.xlsx): Future $CO_2$ concentration.
    - [Fig.2b.xlsx](./Fig2/Fig2b.xlsx): Global hydrogen production volumes.
    - [Fig.2c.xlsx](./Fig2/Fig2c.xlsx): Planetary boundaries and environmental space.

- **[Fig.3](./Fig3/): Prospective planetary footprint and system composition for global hydrogen production.** All figures are available in vector format along with all data in excel format described below:
    - [Fig.3a.xlsx](./Fig3/Fig3a.xlsx): Planetary footprint results without biophysical interactions.
    - [Fig.3b.xlsx](./Fig3/Fig3b.xlsx): Future hydrogen production system composition and scale.
    - [Fig.3c.xlsx](./Fig3/Fig3c.xlsx): Planetary footprint results with biophysical interactions.
    - [Fig.3d.xlsx](./Fig3/Fig3d.xlsx): Future electricty supply system composition and scale.


- **[Fig.4](./Fig4/): Process contribution to the planetary footprint.** All figures are available in vector format along with all data in excel format described below:
    - [Fig.4a.xlsx](./Fig4/Fig4a.xlsx): Process contribution without biophysical interactions.
    - [Fig.4b.xlsx](./Fig4/Fig4b.xlsx): Process contribution with biophysical interactions.

- **[Fig.5](./Fig5/): 2050 planetary footprint of alternative production systems.** All figures are available in vector format along with all data in excel format described below:
    - [Fig.5.xlsx](./Fig5/Fig5a.xlsx): Planetary footprints, with and without biophysical interactions, for each alternative production system.

- **[Fig.6](./Fig6/): Influence of direct air capture and sequestration of $CO_2$ (DACS) on the planetary footprint.** All figures are available in vector format along with all data in excel format described below:
    - [Fig.6.xlsx](./Fig6/Fig6.xlsx): DACS on each Earth-system process.
    - [Fig.6 optimal points.xlsx](./Fig6/Fig6_optimal%20points.xlsx): Opitmal DACS rate ($kgCO_2$/$kgH_2$) to remain within planetary boundaries. Results provided per Earth-system process.

# **2. Supplmentary Materials**

## **2.1 Supplementary data**

- [Characterisation factors](./Supplementary%20Materials/Supplementary%20Data/Chacterisation%20factors/): Planetary boundary-based characterisation factors used in the study.

- [Scenario ensemble](./Supplementary%20Materials/Supplementary%20Data/Scenario%20ensemble/): List of scenarios considered from the AR6 scenario database and from the premise software.

-  [Supplementary Table 3](./Supplementary%20Materials/Supplementary%20Data/Supplementary%20Table%203/Supplementary%20Table3.xlsx): Calculated global safe operating space.

- [Interaction matrices](./Supplementary%20Materials/Supplementary%20Figures/Supplementary%20Fig8/Supplementary%20Fig8.xlsx): Interaction matrices data used in the study. 

## **2.2 Supplementary figures**

- **[Supplementary Figure 6](./Supplementary%20Materials/Supplementary%20Figures/Supplementary%20Fig6/Supplementary%20Fig6.svg):Force interaction diagram considering human + biophysically mediated interactions between Earth-system processes** 
- **[Supplementary Figure 7](./Supplementary%20Materials/Supplementary%20Figures/Supplementary%20Fig7/Supplementary%20Fig7.svg):Force interaction diagram considering only biophysically mediated interactions between Earth-system processes**
- **[Supplementary Figure 8](./Supplementary%20Materials/Supplementary%20Figures/Supplementary%20Fig8/Supplementary%20Fig8.xlsx): Interaction matrices**
- **[Supplementary Figure 11](./Supplementary%20Materials/Supplementary%20Figures/Supplementary%20Fig11/Supplementary%20Fig11.svg): Example of Technosphere matrix rectangulation**
- **[Supplementary Figure 14](./Supplementary%20Materials/Supplementary%20Figures/Supplementary%20Fig14/Supplementary%20Fig14.svg): Hydrogen technology constrains**
    - Note that we do not reproduce data from the AR6 scenario database. Scenario variables need to be extracted using the below which we futher split the data using proportions from Wei et al.(2024), these are available [here](../code/Main/data/iea_data.jl).
        - 'Secondary Energy|Hydrogen|Fossil|w/o CCS'
        - 'Secondary Energy|Hydrogen|Renewable (incl. biomass)'
        - 'Secondary Energy|Hydrogen|Electricity'
- **[Supplementary Figure 15](./Supplementary%20Materials/Supplementary%20Figures/Supplementary%20Fig15/Supplementary%20Fig15.svg): Electricity technology constrains** 
    - Note that we do not reproduce data from the AR6 scenario database. Scenario variables need to be extracted using the below.
        - 'Secondary Energy|Electricity|Nuclear'
        - 'Secondary Energy|Electricity|Hydro'
        - 'Secondary Energy|Electricity|Wind'
        - 'Secondary Energy|Electricity|Solar|PV'
        - 'Secondary Energy|Electricity|Solar|CSP'
        - 'Secondary Energy|Electricity|Geothermal'

- **[Supplementary Figure 17](./Supplementary%20Materials/Supplementary%20Figures/Supplementary%20Fig17/Supplementary%20Fig17.svg): Scenario ensembles validation**

- **[Supplementary Figure 18](./Supplementary%20Materials/Supplementary%20Figures/Supplementary%20Fig18/Supplementary%20Fig18.svg): Electrolytic hydrogen production mix**

- **[Supplementary Figure 19](./Supplementary%20Materials/Supplementary%20Figures/Supplementary%20Fig19/Supplementary%20Fig19.svg): Planetary footprint process contribution of electrolytic hydrogen production system (2050)**

- **[Supplementary Figure 20](./Supplementary%20Materials/Supplementary%20Figures/Supplementary%20Fig20/Supplementary%20Fig20.svg): Bio-based hydrogen production mix**

- **[Supplementary Figure 21](./Supplementary%20Materials/Supplementary%20Figures/Supplementary%20Fig21/Supplementary%20Fig21.svg): Planetary footprint process contribution of bio-based hydrogen production system (2050)**

- **[Supplementary Figure 22](./Supplementary%20Materials/Supplementary%20Figures/Supplementary%20Fig22/Supplementary%20Fig22.svg): Abated fossil hydrogen production mix**

- **[Supplementary Figure 23](./Supplementary%20Materials/Supplementary%20Figures/Supplementary%20Fig23/Supplementary%20Fig23.svg): Planetary footprint process contribution of abated fossil hydrogen production system (2050)**

- **[Supplementary Figure 24](./Supplementary%20Materials/Supplementary%20Figures/Supplementary%20Fig24/Supplementary%20Fig24.svg): Influence of DACS on the planerary footprint of the electrolytic production system**

- **[Supplementary Figure 25](./Supplementary%20Materials/Supplementary%20Figures/Supplementary%20Fig25/Supplementary%20Fig25.svg): Influence of DACS on the planerary footprint of the bio-based production system**

- **[Supplementary Figure 26](./Supplementary%20Materials/Supplementary%20Figures/Supplementary%20Fig26/Supplementary%20Fig26.svg): Influence of DACS on the planerary footprint of the abated fossil production system**

- **[Supplementary Figure 27](./Supplementary%20Materials/Supplementary%20Figures/Supplementary%20Fig27/Supplementary%20Fig27.pdf): Influence of potential hydrogen emissions**

- **[Supplementary Figure 28](./Supplementary%20Materials/Supplementary%20Figures/Supplementary%20Fig28/Supplementary%20Fig28.svg): Prospective planetary footprint and system composition for global hydrogen production considering human-mediated interactions**

- **[Supplementary Figure 29](./Supplementary%20Materials/Supplementary%20Figures/Supplementary%20Fig29/Supplementary%20Fig29.svg): Influence of DACS on the planerary footprint considering human-mediated interactions**

# **3. References**

Wei, S. et al. (2024) ‘Future environmental impacts of global hydrogen production’, Energy & Environmental Science. Available at: https://doi.org/10.1039/D3EE03875K.


