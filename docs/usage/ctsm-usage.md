## Basic Usage of CTSM

See the section in `CESM`. The scripts for general use are located in `$CTSMROOT/cime/scripts`.

# Documentation Issues

After reading the documentation and the following two comments from CESM forum admins, it looks like __everything__ in the documentation's single point case creation is either outdated or broken.

Admin Comments:
1. "Support for PTS_MODE in cime was dropped at some point so you are likely using a version of the model in which support was dropped."
   * It is still fine to use on our `CESM` install.

2. "If you want to subset existing global datasets to regional or single point please see the README in `tools/site_and_regional`. If you want to create your own regional datasets from scratch please see the `README` in `tools/mksurfdata_esmf`."
