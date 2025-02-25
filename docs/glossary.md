# Glossary

------

**CAM**
Community Atmosphere Model (CAM). The prognostically active atmosphere model component of CESM.

**CESM**
Community Earth System Model (CESM). The coupled earth system model that CLM is a component of.

**CIME**
The Common Infrastructure for Modeling the Earth (CIME - pronounced “SEAM”) provides a Case Control System for configuring, compiling and executing Earth system models, data and stub model components, a driver and associated tools and libraries.

**CLM**
Community Land Model (CLM). The prognostically active land model component of CESM.

**CLMBGC**
Community Land Model (CTSM1) with BGC Biogeochemistry. Uses CN Biogeochemistry with vertically resolved soil Carbon, CENTURY model like pools, and Nitrification/De-Nitrification. The CLM_CONFIG_OPTS option for this is

```
./xmlchange CLM_CONFIG_OPTS="phys clm5_0 -bgc bgc
```

**CLMBGC-Crop**
Community Land Model (CTSM1) with BGC Biogeochemistry and prognotic crop. The CLM_CONFIG_OPTS option for this is

```
./xmlchange CLM_CONFIG_OPTS="phys clm5_0 -bgc bgc -crop
```

**CLMCN**
Community Land Model (CLM) with Carbon Nitrogen (CN) Biogeochemistry (either CLM4.0, CLM4.5 or CTSM1) The CLM_CONFIG_OPTS option for this is

```
./xmlchange CLM_CONFIG_OPTS="-bgc cn" -append
```

__CMEPS__

The Community Mediator for Earth Prediction Systems (CMEPS) is a NUOPC-compliant Mediator component used for coupling Earth system model components. It is currently being used in NCAR’s Community Earth System Model (CESM) and NOAA’s subseasonal-to-seasonal coupled system.

**CLMSP**
Community Land Model (CLM) with Satellite Phenology (SP) (either CLM4.0, CLM4.5 or CTSM1) The CLM_CONFIG_OPTS option for this is

```
./xmlchange CLM_CONFIG_OPTS="-bgc sp" -append
```

**CLMU**
Community Land Model (CLM) Urban Model (either CLM4.0, CLM4.5 or CTSM1). The urban model component of CLM is ALWAYS active (unless you create special surface datasets that have zero urban percent, or for regional/single-point simulations for a non-urban area).

__CLM_USRDAT_NAME__

Provides a way to enter your own datasets into the namelist. The files you create must be named with specific naming conventions outlined in [Creating your own single-point dataset](https://escomp.github.io/ctsm-docs/versions/master/html/users_guide/running-single-points/running-single-point-configurations.html#creating-your-own-singlepoint-dataset).

__cprnc__

Tool used to compare two NetCDF files. Appears to have been previously located at `$CIMEROOT/tools/cprnc`, now installed in `/blue/gerber/earth_models/cprnc` for the Gerber research group. 

**CRUNCEP**
The Climate Research Unit (CRU) analysis of the NCEP atmosphere reanalysis atmosphere forcing data. This can be used to drive CLM with atmosphere forcing from 1901 to 2016. This data is updated every year, the version we are currently using is Version-7. The las CESM1.2.2 release used Version-4 data.

**CTSM**
The Community Terrestrial Systems Model, of which CTSM1 and CLM4.5 are namelist option sets of. CTSM is a wider community that includes using CTSM for Numerical Weather Prediction (NWP) as well as climate.

**DATM**
Data Atmosphere Model (DATM) the prescribed data atmosphere component for CESM. Forcing data that we provide are either the CRUNCEP, Qian, or GSWP3 forcing datasets (see below).

**DV**
Dynamic global vegetation, where fractional PFT (see PFT below) changes in time prognostically. Can NOT be used with prescribed transient PFT (requires either CLMBGC or CLMCN for either CLM4.0, CLM4.5 or CTSM1). The CLM_CONFIG_OPTS option for this is

```
./xmlchange CLM_CONFIG_OPTS="-bgc cndv" -append
```

This option is being phased out for the different methodology of FATES (see below). DV is not currently scientifically validated and as such should be considered experimental.

__E3SM__

Energy Exascale Earth System Model. E3SM is the Department of Energy's climate model. Forked from CESM v1 and developed independently by the DOE, they describe E3SM as "an ongoing, state-of-the-science Earth system modeling, simulation, and prediction project that optimizes the use of DOE laboratory resources to meet the science needs of the nation and the mission needs of DOE."

**ESMF**
Earth System Modeling Framework (ESMF). They are a software project that provides a software library to support Earth System modeling. We provide interfaces for ESMF as well as use their regridding capabilities for offline CLM tools.

**FATES**
Functionally Assembled Terrestrial Ecosystem Simulator. This is being developed by the Next Generation Ecosystem Experiment Tropics’ (NGEE-T) project and uses both CTSM1 and the land model component of E3SM (Energy Exascale Earth System Model).

**FUN**
Fixation and Uptake of Nitrogen model, a parameter option of CTSM1.

__GGCMI__ 

[Global Gridded Crop Model Inter comparisons](https://agmip.org/aggrid-ggcmi/). Group of crop modelers who provide gridded crop and climate data. Relevant to the scripts in `$CTSMROOT/tools/crop_calendars`

**GSWP3**
Global Soil Wetness Project (GSPW3) atmospheric forcing data. It is a 3-hourly 0.5° global forcing product (1901-2014) that is based on the NCEP 20th Century Reanalysis, with additional bias corrections added by GSWP3.

__HPG__ - HiPerGator. The supercomputer used at UF. I'll use HPG and HiPerGator interchangeably throughout the documentation.

**LUNA**
Leaf Utilization of Nitrogen for Assimilation parameterization option as part of CTSM1.

__Namelist__ (in the context of `mksurfdata`)

Looks like different variables/parameters for the model.

**NCAR**
National Center for Atmospheric Research (NCAR). This is the research facility that maintains CLM with contributions from other national labs and Universities.

**NCEP**
The National Center for Environmental Prediction (NCEP). In this document this normally refers to the reanalysis atmosphere data produced by NCEP.

__nuopc__ 

[The National Unified Operational Prediction Capability](https://earthsystemmodeling.org). A consortium of Navy, NOAA, and Air Force modelers and their research partners. It aims to advance the weather prediction modeling systems used by meteorologists, mission planners, and decision makers. NUOPC partners are working toward a standard way of building models in order to make it easier to collaboratively build modeling systems. To this end, they have developed the NUOPC Layer that defines conventions and a set of generic components for building coupled models using the Earth System Modeling Framework (ESMF).

**MOSART**
Model for Scale Adaptive River Transport, ROF model component option added as part of CTSM1. It is the standard ROF model used in CTSM1 compsets.

**PFT**
Plant Function Type (PFT). A type of vegetation that CLM parameterizes.

__PTS_MODE__

* A deprecated way to run single point simulations (still works on cesm 2.1.5).
* Okay for quick and dirty runs.
* Lacks restart capability.

**ROF**
River runOff Model to route flow of surface water over land out to the ocean. CESM2.2 beta has two components options for this the new model MOSART and previous model RTM.

**RTM**
River Transport Model, ROF model component option that has been a part of all versions of CESM. It is the standard ROF model used in CLM4.5 and CLM4.0 compsets.

__SCRIP__ [Spherical Coordinate Remapping and Interpolation Package](https://github.com/SCRIP-Project/SCRIP)

* Spherical Coordinate Remapping and Interpolation Package (SCRIP). We use it’s file format for specifying both grid coordinates as well as mapping between different grids.
* Computes addresses and weights for remapping and interpolating fields between grids in spherical coordinates.
* Looks like they are used to create the surface datasets.

**VIC**
Variable Infiltration Capacity (VIC) model for hydrology. This is an option to CTSM1 in place of the standard CTSM1 hydrology. The CLM_CONFIG_OPTS option for this is

```
./xmlchange CLM_CONFIG_OPTS="-vichydro on" -append
```
