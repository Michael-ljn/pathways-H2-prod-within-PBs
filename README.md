[![DOI](https://zenodo.org/badge/940091341.svg)](https://doi.org/10.5281/zenodo.14939868) <a href="https://www.globh2e.org.au/"><img src="https://img.shields.io/badge/ARC:Funding%20number-IC200100023-blue.svg"/></a>

# **Pathways to global hydrogen production within planetary boundaries: Code repository**

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

<br>

> Available at: https://doi.org/10.21203/rs.3.rs-5917828/v1.

---
> [!CAUTION]<br>
> The underlying work for this repository is currently under review. Until the work is accepted for publication, all content should be considered as preliminary draft and may contain errors.

> [!IMPORTANT]<br>
> The underlying code [lce.jl](https://github.com/Michael-ljn/lce.jl) for data pre-processing is not provided in this repository. As demonstrated in the [Tutorial](./Tutorial/), the code is not required for reproducing the results. Therefore, access to this code can be provided upon reasonable request to the corresponding authors.

<br>


![system boundaries](./Source%20data/Supplementary%20Materials/Other%20Figures/sys_boundaries.svg)


## **1. Code availability**

We provide in the [code ](./code/) used to generate results. However, we used an in-house software for data formatting and processing [lce.jl](https://github.com/Michael-ljn/lce.jl/), which is not publicly available yet. The software is currently hard to use for external users and undocumented. We recommend using [PULPO](https://github.com/flechtenberg/pulpo) which is already comprehensive enough to perform the analysis. That said, we are working on making [lce.jl](https://github.com/Michael-ljn/lce.jl/) open-source in the future. 

## **2. Results**
All results can be found in [Source data Folder](./Source%20data/).

## **3. Replication**

### **3.1 AR6 scenario ensemble**

The AR6 dataset is publicly available:
> Byers, E. et al. (2022) ‘AR6 Scenarios Database’. Integrated Assessment Modeling Consortium & International Institute for Applied Systems Analysis. Available at: https://doi.org/10.5281/ZENODO.5886911.

The data set can be filtered using [the list of scenarios considered](./Source%20data/Supplementary%20Materials/Supplementary%20Data/Scenario%20ensemble/Ensembles.xlsx).

### **3.2 Premise scenario ensemble**

We generated prospective life cycle assessment data using [Premise](https://github.com/polca/premise). The notebook used to generate scenarios is available [here](./code/3_pLCA_data.ipynb). To run this code, you will need:

1. access to [ecoinvent](https://www.ecoinvent.org/) database (here we used 3.9.1).
2. decryption key from the premise developers.


### **3.3 Optimisation model**

For replication of results, we provide a simple [tutorial](./Tutorial/) with step by step instructions using [Activity-browser](https://github.com/LCA-ActivityBrowser/activity-browser), [ScenarioLink](https://github.com/polca/ScenarioLink), Microsoft Excel and [JuMP.jl](https://github.com/jump-dev/JuMP.jl). Experienced python developers can also adapt the [optimisation code](./Tutorial/Tutorial.ipynb) to python using the [pyomo](https://github.com/Pyomo/pyomo) pacakage


## **4. Relevant publications to check out**

1. Bachmann, M. et al. (2023) ‘Towards circular plastics within planetary boundaries’, Nature Sustainability, 6(5), pp. 599–610. Available at: https://doi.org/10.1038/s41893-022-01054-9.

2. Kätelhön, A., Bardow, A. and Suh, S. (2016) ‘Stochastic Technology Choice Model for Consequential Life Cycle Assessment’, Environmental Science & Technology, 50(23), pp. 12575–12583. Available at: https://doi.org/10.1021/acs.est.6b04270.

3. Heijungs, R. and Suh, S. (2002) The computational structure of life cycle assessment. Dordrecht: Springer-Science + Business Media (Eco-efficiency in industry and science, 11).

4. Lade, S.J. et al. (2020) ‘Human impacts on planetary boundaries amplified by Earth system interactions’, 3(2), pp. 119–128. Available at: https://doi.org/10.1038/s41893-019-0454-4.

5. Lechtenberg, F. et al. (2024) ‘PULPO: A framework for efficient integration of life cycle inventory models into life cycle product optimization’, Journal of Industrial Ecology, n/a(n/a). Available at: https://doi.org/10.1111/jiec.13561.



