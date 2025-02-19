## Basic Usage of CTSM

See the section in `CESM`. The scripts for general use are located in `$CTSMROOT/cime/scripts`.

# Section 1.6.1

From section [1.6.1](https://escomp.github.io/ctsm-docs/versions/master/html/users_guide/running-single-points/single-point-and-regional-grid-configurations.html) of the CTSM docs.

"CLM allows you to set up and run cases with a single-point or a local region as well as global resolutions. "

Two ways to do this:

1. `PTS_MODE` - for single point global datasets
* Quick and dirty method.
* Good for initial testing.
* No restart capability.

2. `CLM_USRDAT_NAME` - runs using user regional or single point datasets
* Best way to set up cases quickly where we have to create your own data sets.
* Don't have to change DATM or add files to XML database - just follow a naming convention for files.
* Once files are named (and located) correctly, setting up cases using the custom data is easy.
* This is good for a particular model version of CTSM. For CLM devs and tracking dataset changes with different model versions, it would be better to add the datasets as supported datasets in "normal supported datasets" method.

The "normal supported datasets" method is great if one of the supported datasets is your region of interest.
Unfortunately for us this is not the case. If we want to use this method for our data sets, we need to create them,
then add them to the XML database in scripts, to CLM and the DATM. It could potentially be worthwhile down the road.
However, right now we should use the directions starting in the section 1.6.3.3.2 example. 

# Documentation Issues

After reading the documentation and the following two comments from CESM forum admins, it looks like __everything__ in the documentation's single point case creation is either outdated or broken.

1. "Support for PTS_MODE in cime was dropped at some point so you are likely using a version of the model in which support was dropped."
   * It is still fine to use on our `CESM` install.

2. "If you want to subset existing global datasets to regional or single point please see the README in `tools/site_and_regional`. If you want to create your own regional datasets from scratch please see the `README` in `tools/mksurfdata_esmf`."
