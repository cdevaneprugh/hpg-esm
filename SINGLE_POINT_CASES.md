## Section 1.6.1
Starting from section [1.6.1](https://escomp.github.io/ctsm-docs/versions/master/html/users_guide/running-single-points/single-point-and-regional-grid-configurations.html) of the CTSM docs.

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

## Section 1.6.2

Continuing through the docs brings us to the instructions for using `PTS_MODE`. This is what we used on CESM, and may still be a useful method here for certain cases.

Following the instructions I first tried:

```
# load appropriate modules
module restore gcc_env

# from their docs
./create_newcase --case /blue/gerber/cdevaneprugh/cases/testPTS_MODE --res f19_g17_gl4 --compset I1850Clm50BgcCropCru
```

However I was returned with the error:

```
ERROR: grid alias f19_g17_gl4 not valid for compset 1850_DATM%CRUv7_CLM50%BGC-CROP_SICE_SOCN_MOSART_SGLC_SWAV_SESP
```

I then opted for the following which worked.

```
./create_newcase --case /blue/gerber/cdevaneprugh/cases/testPTS_MODE --res f19_g17 --compset I1850Clm50BgcCropCru
```

After `cd`-ing into the case directory, I changed the following variables.

```
# make sure there is no space after the comma
./xmlchange PTS_LAT=40.0,PTS_LON=-105.0
./xmlchange CLM_FORCE_COLDSTART=on,RUN_TYPE=startup
./xmlchange NTASKS=1
```

__NOTE:__ It is not mentioned in the documentation, but for CESM2.1.5 we used to set a variable called `PTS_MODE` to TRUE before building.

This variable doesn't seem to exist anymore, as when I try to set it a "variable not found error" is returned.

Results:

Model builds.

Case submits.

Case fails with errors:
```
ERROR:  (esm_get_single_column_attributes)  ERROR: ROF does not support single column mode

MPI_ABORT was invoked on rank 0 in communicator MPI_COMM_WORLD
with errorcode 1001.

NOTE: invoking MPI_ABORT causes Open MPI to kill all MPI processes.
You may or may not see output from other processes, depending on
exactly when Open MPI kills them.
```

Retrying by setting `MPILIB=mpi-serial`

Failed with errors:

```
*** The MPI_Query_thread() function was called before MPI_INIT was invoked.
*** This is disallowed by the MPI standard.
*** Your MPI job will now abort.
[c0704a-s1.ufhpc:51591] Local abort before MPI_INIT completed completed successfully, but am not able to aggregate error messages, and not able to guarantee that all other processes were killed!
```

Retrying after changing more variables to run on single core:
```
./xmlchange COST_PES=1,COSTPES_PER_NODE=1,MAX_TASKS_PER_NODE=1,MAX_MPITASKS_PER_NODE=1
```

Failed with same errors:

```
ERROR:  (esm_get_single_column_attributes)  ERROR: ROF does not support single column mode

MPI_ABORT was invoked on rank 0 in communicator MPI_COMM_WORLD
with errorcode 1001.

NOTE: invoking MPI_ABORT causes Open MPI to kill all MPI processes.
You may or may not see output from other processes, depending on
exactly when Open MPI kills them.
```

Wondering if this just can't run on one core. Will try on 2 cores, then I'll try a compset I _know_ worked on 1 core with `cesm`.

Switched to 2 nodes with 4 cores each. Case builds.

Failed again. Possibly a compset issue? I'll switch to something we know works single point with `CESM`

I ran a compset that worked in single point mode on CESM and it worked here too. Here was my input.

```
./create_newcase --case /blue/gerber/cdevaneprugh/cases/testPTS_MODE2 --res f19_g17 --compset 1850_DATM%CRUv7_CLM50%SP_SICE_SOCN_SROF_SGLC_SWAV --run-unsupported
ls
./xmlquery --listall
./xmlchange NTASKS=1
./xmlchange PTS_LAT=40.0,PTS_LON=-105.0
./xmlchange CLM_FORCE_COLDSTART=on,RUN_TYPE=startup
```

__From a CSEG liaison:__
"Support for PTS_MODE in cime was dropped at some point so you are likely using a version of the model in which support was dropped."

Looks like `PTS_MODE` isn't even a thing anymore? So I'm slightly unsure what is actually going on in this test run.

# Section 1.6.3

The docs are definitely out of date.

To get a list of supported dataset resolutions do this:

```
cd /blue/gerber/earth_models/ctsm5.3.012/cime/scripts

./query_config --grids
```
# 1.6.3.1. Single-point runs with global climate forcings
## 1.6.3.1.1. Example: Use global forcings at a site without its own special forcings

This example uses the single-point site in Brazil.

```
cd cime/scripts

export SITE=1x1_brazil

./create_newcase --case /blue/gerber/$USER/cases/testSPDATASET --res $SITE --compset I1850Clm50SpCru --run-unsupported

cd testSPDATASET
```

The test build and ran normally.

## 1.6.3.1.2. Example: Use global forcings at a site WITH its own special forcings

```
cd cime/scripts

# Set a variable to the site you want to use (as it's used several times below)
export SITE=1x1_mexicocityMEX

./create_newcase --case /blue/gerber/$USER/cases/testSPDATASET_MEX --res $SITE --compset I1PtClm50SpRs --run-unsupported

cd testSPDATASET
```

This one failed in the compute node. However, the compset they suggest doesn't exist so I had to substitute somehting else. Furthermore this isn't particularly relevant to what we're doing so I'm just going to move on.


# CTSM 5.3 Tools

So based on this comment from a CSEG liaison:

"If you want to subset existing global datasets to regional or single point please see the README in tools/site_and_regional.

If you want to create your own regional datasets from scratch please see the README in tools/mksurfdata_esmf."

it seems like __everything__ in the documentation's single point case creation is outdated and basically broken in some form.

We are interested in making our own datasets, so let's look at the `mksurfdata_esmf` directory.

From the `README`:

```
mksurfdata_esmf has a cime configure and CMake based build using the following files:

        gen_mksurfdata_build ---- Build mksurfdata_esmf
        src/CMakeLists.txt ------ Tells CMake how to build the source code
        Makefile ---------------- GNU makefile to link the program together
        cmake ------------------- CMake macros for finding libraries
```

In `$CTSMROOT/tools/mksurfdata_esmf/` we first need to build the executable.

I tried building the executable as described in the `README` with

```
cd $CTSMROOT/tools/mksurfdata_esmf

./gen_mksurfdata_build -m hipergator
```

but was met with the following error.

```
The PIO directory for the PIO build is required and was not set in the configure
Make sure a PIO build is provided for gnu with openmpi in config_machines
```

There is a parallelio directory in `$CTSMROOT/libraries/parralelio`. However it's just a clone of the PIO github page.


```
cd $CTSMROOT/libraries/parallelio

# set the installation point for PIO
mkdir bld

# link netcdf paths, disable pnetcdf and enable netcdf integration
cmake -DNetCDF_C_PATH=/apps/gcc/12.2.0/openmpi/4.1.6/netcdf-c/4.9.2 -DNetCDF_Fortran_PATH=/apps/gcc/12.2.0/openmpi/4.1.6/netcdf-f/4.6.1 -DWITH_PNETCDF=OFF -DPIO_ENABLE_NETCDF_INTEGRATION=ON -DCMAKE_INSTALL_PREFIX=`pwd`/bld

make

make check

make install

```

It looks like a successful install. I'm not 100% sure about the directory structure, so I may redo it later.

Let's retest the mksurfdata build script again.

It's still hung up on the same thing. I think the path forward is to figure out how to point to the PIO libraries in the config files now. I'll look at some of the other configs and see how it's done.

There's a `config_pio.xml` file that I may be able to modify with what I just built.
