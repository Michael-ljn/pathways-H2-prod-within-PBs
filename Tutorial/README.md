[![DOI](https://zenodo.org/badge/940091341.svg)](https://doi.org/10.5281/zenodo.14939868) <a href="https://www.globh2e.org.au/"><img src="https://img.shields.io/badge/ARC:Funding%20number-IC200100023-blue.svg"/></a>

# **Life cycle optimisation tutorial**

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

> Underlying publication: https://doi.org/10.21203/rs.3.rs-5917828/v1.

---
> [!CAUTION]<br>
> The underlying work for this repository is currently under review. Until the work is accepted for publication, all content should be considered as preliminary draft and may contain errors.

## **1. Introduction**

The full tutorial is accessible [here](https://www.youtube.com/@globalhydrogeneconomytrain5404).

This tutorial aims to provide sufficient information for the replication of:
> Lejeune, M. et al. (2025) ‘Pathways to global hydrogen production within planetary boundaries’. Research Square. Available at: https://doi.org/10.21203/rs.3.rs-5917828/v1.

The tutorial provides a step-by-step guide to create a stochastic optimisation model using JuMP.jl and Activity-browser based on a simple case study for producing hydrogen via PEM electrolysis. The optimisation will focus on minimising the effective planetary footprint by selecting and scaling the optimal renewable energy technology mix. 

![](./Images/PEM_unit1.svg)


This tutorial is self-contained and does not require any other code than what is available in this folder. The tutorial will cover the following steps:

1. Installing Planetary boundaries characterisation factors in Activity-browser.
2. Aggregating life cycle inventories using Activity-browser.
3. Data formatting using Microsoft Excel including:
    - Rectangularised technosphere matrix
    - Biosphere matrix
    - Characterisation matrix
    - Demand vector
    - Costs per process
    - Technology constraints
4. Optimisation model (see equations below) using JuMP.jl using Data from Lejeune et al. (2025)


$$\min _{\text {s.t. } s } x = \Gamma d$$
$$Q \tilde{ B } s \oslash \omega = d$$
$$A^* s = f$$
$$s ^{ j } \geq 0$$
$$s ^{el} \leq c ^{el} $$


## **2. Pre-requisites**

- Julia v1.10
- JuMP.jl
- Activity-browser (and knowledge of how to use it)
- Scenario link (and knowledge of how to use it)
- Microsoft Excel (and knowledge of how to use it)







