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

./gen_mksurfdata_build --machine hipergator
```

but was met with the following error.

```
The PIO directory for the PIO build is required and was not set in the configure
Make sure a PIO build is provided for gnu with openmpi in config_machines
```

## Building The PIO Library

There is a parallelio directory in `$CTSMROOT/libraries/parralelio`. However it's just a clone of the PIO github page.


```
cd $CTSMROOT/libraries/parallelio

# set the installation point for PIO
mkdir bld

# link netcdf paths, disable pnetcdf and enable netcdf integration
cmake -DNetCDF_C_PATH=/apps/gcc/12.2.0/openmpi/4.1.6/netcdf-c/4.9.2 -DNetCDF_Fortran_PATH=/apps/gcc/12.2.0/openmpi/4.1.6/netcdf-f/4.6.1 -DWITH_PNETCDF=OFF -DCMAKE_INSTALL_PREFIX=`pwd`/bld

make

make check

make install

```

It looks like a successful install. I'm not 100% sure about the directory structure, so I may redo it later.

To get the mksurfdata build script, I added the following environment variable to config_machine.xml:

```
<env name="PIO">/blue/gerber/earth_models/ctsm5.3/libraries/parallelio/bld</env>
```

and the following to gnu_hipergator.cmake:

```
if(DEFINED ENV{PIO})
  set(PIO_LIBDIR "$ENV{PIO}/lib")
  set(PIO_INCDIR "$ENV{PIO}/include")
endif()
```

This makes the PIO library recognized by the mksurfdata build script.

## The mksurfdata build script

Running `gen_mksurfdata_build` now, I can seeget the following output:

```
[cdevaneprugh@login12 mksurfdata_esmf]$ ./gen_mksurfdata_build --machine hipergator
copying /blue/gerber/earth_models/ctsm5.3/ccs_config/machines/cmake_macros/../hipergator/gnu_hipergator.cmake to /blue/gerber/earth_models/ctsm5.3/tools/mksurfdata_esmf/tool_bld
-- The Fortran compiler identification is GNU 12.2.0
-- Detecting Fortran compiler ABI info
-- Detecting Fortran compiler ABI info - done
-- Check for working Fortran compiler: /apps/mpi/gcc/12.2.0/openmpi/4.1.6/bin/mpif90 - skipped
-- Found MPI_Fortran: /apps/mpi/gcc/12.2.0/openmpi/4.1.6/bin/mpif90 (found version "3.1") 
-- Found MPI: TRUE (found version "3.1")  
-- Found NetCDF: /apps/gcc/12.2.0/openmpi/4.1.6/netcdf-c/4.9.2/include;/apps/gcc/12.2.0/openmpi/4.1.6/netcdf-f/4.6.1/include (found suitable version "4.9.2", minimum required is "4.7.4") found components: Fortran 
-- FindNetCDF defines targets:
--   - NetCDF_VERSION [4.9.2]
--   - NetCDF_PARALLEL [TRUE]
--   - NetCDF_C_CONFIG_EXECUTABLE [/apps/gcc/12.2.0/openmpi/4.1.6/netcdf-c/4.9.2/bin/nc-config]
--   - NetCDF::NetCDF_C [SHARED] [Root: /apps/gcc/12.2.0/openmpi/4.1.6/netcdf-c/4.9.2] Lib: /apps/gcc/12.2.0/openmpi/4.1.6/netcdf-c/4.9.2/lib64/libnetcdf.so 
--   - NetCDF_Fortran_CONFIG_EXECUTABLE [/apps/gcc/12.2.0/openmpi/4.1.6/netcdf-f/4.6.1/bin/nf-config]
--   - NetCDF::NetCDF_Fortran [SHARED] [Root: /apps/gcc/12.2.0/openmpi/4.1.6/netcdf-f/4.6.1] Lib: /apps/gcc/12.2.0/openmpi/4.1.6/netcdf-f/4.6.1/lib/libnetcdff.so 
-- Found ESMF library: /apps/gcc/12.2.0/openmpi/4.1.6/esmf/8.7.0/lib/libO/Linux.gfortran.64.openmpi.default/libesmf.a
-- Found ESMF: /apps/gcc/12.2.0/openmpi/4.1.6/esmf/8.7.0/lib/libO/Linux.gfortran.64.openmpi.default (found suitable version "8.7.0", minimum required is "8.2.0")  
-- Configuring done (3.2s)
-- Generating done (0.0s)
-- Build files have been written to: /blue/gerber/earth_models/ctsm5.3/tools/mksurfdata_esmf/tool_bld
```

This is followed by an attempt to build the Fortran objects located in `tool_bld/CMakeFiles/mksurfdata.dir/`. The attempts fail, throwing the error `Rank mismatch between actual argument at (1) and actual argument at (2) (rank-1 and scalar)`.

This is an error that should be ignored by the `-fallow-argument-mismatch` flag in our `gnu_hipergator.cmake` file.
For some reason, it seems like the fortran flags are not being carried over when the `make` command is run.

If we look at the files in `tool_bld/CMakeFiles/mksurfdata.dir` we might be able to get an idea of whats going on.
This is where the Fortran programs are located, as well as the `make` flags and apprently other important files.

Looking at `flags.make` in this directory, we can see the only fortran flag included is `-g`. This is strange, as there should be several others that we defined from our compiler config file.
The other interesting thing is that the `-g` flag is associated with debugging. I'll looke and see if this flag was run while building the PIO library, or is used in general with CTSM.
In the gen_mksurfdata_build script, the cmake command is run with the flag: -DCMAKE_BUILD_TYPE=Debug which is probably what causes the -g flag to appear. Removing it does cause the -g flag to disappear, still fails to build though.

PIO library: Has these flags -fallow-argument-mismatch -O3 -DNDEBUG -O3 -flto=auto -ffat-lto-objects
CTSM:

We also get this output:

```
make[2]: [CMakeFiles/mksurfdata.dir/build.make:101: CMakeFiles/mksurfdata.dir/mkdiagnosticsMod.F90.o] Error 1
make[2]: Leaving directory '/blue/gerber/earth_models/ctsm5.3/tools/mksurfdata_esmf/tool_bld'
make[1]: [CMakeFiles/Makefile2:83: CMakeFiles/mksurfdata.dir/all] Error 2
make[1]: Leaving directory '/blue/gerber/earth_models/ctsm5.3/tools/mksurfdata_esmf/tool_bld'
make: [Makefile:136: all] Error 2
```

Which I would like to spend time going through the files parsing them out.

File 1: CMakeFiles/mksurfdata.dir/build.make line 101 includes some variables $(Fortran_DEFINES) $(Fortran_INCLUDES) $(Fortran_FLAGS) which are defined in the flags.make file.

File 2: CMakeFiles/Makefile2 line 83 runs the make command for build.make

File 3: Makefile runs the make command for Makefile2

### Modifying gen_mksurfdata_build

The goal is to find the minimum flags that get the installation further along. We'll start with the first error.

Removing the Debug build type, and adding in `-DCMAKE_Fortran_FLAGS=" -fallow-argument-mismatch"` at line 170.

Running the script again gets us further along, however we still fail with the following output:

```
Error: BOZ literal constant at (1) is neither a data-stmt-constant nor an actual argument to INT, REAL, DBLE, or CMPLX intrinsic function [see ‘-fno-allow-invalid-boz’]
```

This is the other flag in our compiler config that should be `-fallow-invalid-boz`. Adding this to the cmake flags and rerunning, we get further in the install with the following output errors.

1. Nonnegative width required in format string at (1)
* The format string in your Fortran code contains an invalid field width specifier (e.g., I, F, or E descriptors missing a nonnegative integer width)
* Correct the code by adding a valid width to the width specifier (I --> I5)
* ignore with -fallow-invalid-format

2. Line truncated at (1) [-Werror=line-truncation]
* This error occurs when a line in your Fortran source code exceeds the maximum allowed length
* ignore with -Wno-line-truncation

3. Syntax error in argument list at (1)
* This error indicates a syntax problem in a subroutine or function call's argument list
* must fix in source code

Possible to allow a legacy standard to relax the syntax rules with `-std=legacy`. I should check whether the legacy standard flag has been used in PIO or CTSM builds.

I tried adding `-std=legacy` to the CMAKE flags with no luck.

## Current Combo that works except the syntac error

-DCMAKE_Fortran_FLAGS=" -g -fallow-argument-mismatch -fallow-invalid-boz -ffree-line-length-none"

The ffree line length deals with some type of truncation issue that is treated as a syntax error.

It appears the invalid width error is a proper syntax error and cannot be suppressed. I don't know why this is happening in the slightest.
I fixed it by adding widths to the lines that needed them. You can see the modified version of the script on github.

When we run it not spits out the error that:
```
No rule to make target '/blue/gerber/earth_models/ctsm5.3/libraries/parallelio/bld/lib/libpiof.so', needed by 'mksurfdata'.  Stop.
```

This looks like one of the things that popped up in the github issue. Exploring now.

When I built the PIO library, the static libraries were built instead of the shared. After rebuilding PIO with the shared libraries, we get the following error when running the gen_mksurfdata_build script.

```
/usr/bin/ld: warning: libgptl.so, needed by /blue/gerber/earth_models/ctsm5.3/libraries/parallelio/bld/lib/libpiof.so, not found (try using -rpath or -rpath-link)
/blue/gerber/earth_models/ctsm5.3/libraries/parallelio/bld/lib/libpiof.so: undefined reference to `__perf_mod_MOD_t_startf'
/blue/gerber/earth_models/ctsm5.3/libraries/parallelio/bld/lib/libpioc.so: undefined reference to `GPTLstart'
/blue/gerber/earth_models/ctsm5.3/libraries/parallelio/bld/lib/libpioc.so: undefined reference to `GPTLstop'
/blue/gerber/earth_models/ctsm5.3/libraries/parallelio/bld/lib/libpiof.so: undefined reference to `__perf_mod_MOD_t_stopf'
collect2: error: ld returned 1 exit status
```

I removed the `-g` flag and reran, getting the same output as above. I wonder if the gptl lib is 100% necessary or if there's a flag I can pass to the compiler to avoid this.

Looking at the error, `libgptl.so` is required by `libpiof.so` and `libpioc.so` meaning the `parallelio` library needs it.
I wonder if there is an option in the PIO library to build it, or if I need to install it separately, then link it while building `pio`. If I do need to link it manually, I need to figure out how to do that.

There is an option in `parallelio/CMakeLists.txt` at line 86.

```
option (PIO_ENABLE_TIMING    "Enable the use of the GPTL timing library"    ON)
```

Rebuilding the PIO library:

```
cmake -DNetCDF_C_PATH=/apps/gcc/12.2.0/openmpi/4.1.6/netcdf-c/4.9.2 -DNetCDF_Fortran_PATH=/apps/gcc/12.2.0/openmpi/4.1.6/netcdf-f/4.6.1 -DWITH_PNETCDF=OFF -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX=`pwd`/bld
```

Could possibly disable `PIO_ENABLE_TIMING` to see if it is even necessary.

I disabled `PIO_ENABLE_TIMING` and was able to build `mksurfdata` finally. When we try to run the script or run `ldd` it looks like `libpiof.so` and `libpioc.so` were not linked properly.

I can confirm they were built in `libraries/parallelio/bld/lib`.

In the open issue on GitHub, when developers were trying to port this to another platform, they changed a relative path to an absolute one in something related to the PIO library.

I added the absolute path to the libraries in `CMakeLists.txt`, rebuilt the executable with the same issue.

I wonder if adding the absolute paths to PIO/inc and PIO/lib in our cmake macros would help. This is how we approached linking libraries with netcdf.

I updated the configs and this didn't work. I also noticed that if you run `ldd` on libpiof.so that libpioc.so is not found.

The line in CMakeLists.txt add_library(pioc STATIC IMPORTED) implies that pioc and piof are static libraries. I built them as shared libraries.
This gives two options: 1 rebuild pio with static libraries (I thought I got an error the first time). 2 change the line to SHARED IMPORTED.

Changing STATIC to SHARED does seem to work. The libraries are in the correct spot. What's weird is I'm not sure if what _should_ have been done is static and shared libraries being built for PIO, then linking with GPTL.

I think I should try to rebuild PIO with default settings, or have chatGPT help me determine what settings are needed and what/how to link needed libraries.
Then I can rebuild mksurfdata with possibly the default CMakeLists.txt file? I'll also throw an update on the forms. 

I'll upload files and documentation to chatGPT and see if it can help walk me through some of this stuff.
Figuring out how to build some of the optional documentation will also be helpful.

## Building Documentation

### CTSM
To build the CTSM docs I think I need to use conda to install python and sphinx. Awesome

I just did this on my personal computer as it was easier to get sphinx and some other sphinx libraries installed.
On my PC I had to run the following commands to get the docs to build.

```
sudo apt install sphinx
pip install sphinx sphinx_rtd_theme

cd doc

mkdir bld

./build_docs -b bld/
```

It appears to just mirror the documentation on their website. Nothing specific to the CTSM version.

### PARALLELIO
Documentation that is built is identical to the website. No need to build.
[Website Doc](https://ncar.github.io/ParallelIO/index.html)

```
# load cmake and doxyfile
module load cmake
module load doxyfile

# cd to the docs
cd $CTSMROOT/libraries/parallelio/doc

# make and cd into a build directory
mkdir bld
cd bld/

# run cmake to generate the build files
cmake ..

# modify the Doxyfile config if needed
# can change build dir, build latex docs, etc
vim Doxyfile

# build the documentation
doxygen Doxyfile
```

Look for a new directory called `docs`. Hipergator does not have an html viewer for the terminal. If you'd like the documentation downloaded to you personal computer go to https://ood.rc.ufl.edu/ and sign into your account. Then locate the `docs` directory from the file explorer in the top menu. You can download the docs, and then use your internet browser to view the documentation.

## New Build Try

This time we set the LD_LIBRARY_PATH before building the pio library

```
LD_LIBRARY_PATH=/blue/gerber/earth_models/ctsm5.3/libraries/parallelio/src/gptl/:$LD_LIBRARY_PATH

# make sure the library path makes sense
echo $LD_LIBRARY_PATH

# run cmake and make again
cmake -DNetCDF_C_PATH=/apps/gcc/12.2.0/openmpi/4.1.6/netcdf-c/4.9.2 -DNetCDF_Fortran_PATH=/apps/gcc/12.2.0/openmpi/4.1.6/netcdf-f/4.6.1 -DWITH_PNETCDF=OFF -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX=`pwd`/bld

make

make install
```

This in combination with modifying the CMakeLists.txt file to include shared libraries seemed to work.

## Update

Restarting HPG, GPTL seems to not be linked now. After trying again the same thing happens. It is linked when building, but after restarting terminal it forgets where `libgptl` is located.

Used RPATH to build parallelio and now it keeps the gptl library linked after logging out.

Some issues with libraries not linked in the `mksurfdata` executable now.

```
tool_bld/mksurfdata: /lib64/libstdc++.so.6: version `GLIBCXX_3.4.29' not found (required by tool_bld/mksurfdata)
tool_bld/mksurfdata: /lib64/libstdc++.so.6: version `GLIBCXX_3.4.26' not found (required by tool_bld/mksurfdata)
tool_bld/mksurfdata: /lib64/libgfortran.so.5: version `GFORTRAN_10' not found (required by tool_bld/mksurfdata)
tool_bld/mksurfdata: /lib64/libgfortran.so.5: version `GFORTRAN_10' not found (required by /blue/gerber/earth_models/ctsm5.3/libraries/parallelio/bld/lib/libpiof.so)
tool_bld/mksurfdata: /lib64/libgfortran.so.5: version `GFORTRAN_10' not found (required by /apps/gcc/12.2.0/openmpi/4.1.6/netcdf-f/4.6.1/lib/libnetcdff.so.7)
```

Additionally, libpiof.so shows similar issues:

```
bld/lib/libpiof.so: /lib64/libgfortran.so.5: version `GFORTRAN_10' not found (required by bld/lib/libpiof.so)
bld/lib/libpiof.so: /lib64/libgfortran.so.5: version `GFORTRAN_10' not found (required by /apps/gcc/12.2.0/openmpi/4.1.6/netcdf-f/4.6.1/lib/libnetcdff.so.7)
```

Hard to know if this 100% matters or could be ignored. It certainly looks like they were built correctly.

Solved: This is caused by `gcc 12.2.0` not being loaded upon login. Need to restore the `gcc` environment when running these scripts (likely).

# PIO AND MKSURFDATA BUILD

The `mksurfdata` executable requires four libraries be properly configured before building.
The first three (`MPI` `NetCDF` and `ESMF`) have already been configured on HiPerGator. The last library needed is `parallelio` (aka `PIO`), which we must build ourselves.

## Building PIO

First make sure the appropriate modules are loaded. Below are the standard modules used for most things `CESM` and `CTSM` related.

```
module load perl/5.24.1
module load subversion/1.9.7
module load cmake/3.26.4
module load gcc/12.2.0
module load python/3.11
module load openmpi/4.1.6
module load netcdf-c/4.9.2
module load netcdf-f/4.6.1
```

Go to the `parallelio` directory and create a build birectory.

```
cd /blue/gerber/earth_models/ctsm5.3/libraries/parallelio

mkdir bld
```

You can then run the following `cmake` command either via the command line or by a script. I find throwing it into a simple `bash` script is best as you can tweak settings easier and keep track of your build.

```
cmake \
  -DNetCDF_C_PATH=/apps/gcc/12.2.0/openmpi/4.1.6/netcdf-c/4.9.2 \
  -DNetCDF_Fortran_PATH=/apps/gcc/12.2.0/openmpi/4.1.6/netcdf-f/4.6.1 \
  -DWITH_PNETCDF=OFF \
  -DBUILD_SHARED_LIBS=ON \
  -DCMAKE_INSTALL_PREFIX=`pwd`/bld \
  -DCMAKE_INSTALL_RPATH=`pwd`/src/gptl \
  -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=TRUE \

make

make install
```

## Building mksurfdata

We need to modify several files in order to build the executable. I will try to make a fork of ctsm in the future with all of this already completed. If that is not available for some reason, here is how to fix the existing code.

First go to the directory at `CTSMROOT/tools/mksurfdata_esmf`.

Then modify the `CMakeLists.txt` file at `CTSMROOT/tools/mksurfdata_esmf/src/CMakeLists.txt`.
`CMakeLists.txt` is a configuration file that CMake uses to define the build process, including source files, dependencies, build targets, and project settings.

At lines 51 and 52, change the word STATIC to SHARED so the lines read as follows.

```
add_library(pioc SHARED IMPORTED)
add_library(piof SHARED IMPORTED)
set_property(TARGET pioc PROPERTY IMPORTED_LOCATION $ENV{PIO}/lib/libpioc.so)
set_property(TARGET piof PROPERTY IMPORTED_LOCATION $ENV{PIO}/lib/libpiof.so)
```

If you notice in the bottom two lines, we are looking for the shared libraries `libpioc.so` and `libpiof.so`. This conflicted with the previous two lines looking for static libraries.

Next we have to correct some Fortran syntax errors in `src/mksurfdata.F90`. If you try to compile you will be met with the following errors.

```
/ctsm5.3/tools/mksurfdata_esmf/src/mksurfdata.F90:271:24:

  271 |      write(ndiag,'(2(a,I))') ' npes = ', npes, ' grid size = ', grid_size
      |                        1
Error: Nonnegative width required in format string at (1)

/ctsm5.3/tools/mksurfdata_esmf/src/mksurfdata.F90:295:19:

  295 |      read(nfpio, '(i)', iostat=ier) pio_iotype
      |                   1
Error: Nonnegative width required in format string at (1)

/ctsm5.3/tools/mksurfdata_esmf/src/mksurfdata.F90:328:27:

  328 |         write (ndiag,'(a, I, a, I)') ' node_count = ', node_count, ' grid_size = ', grid_size
      |                           1
Error: Nonnegative width required in format string at (1)
```

To fix this we make the following changes at lines 271, 295, and 328 respectively.

```
271 |      write(ndiag,'(2(a,I10))') ' npes = ', npes, ' grid size = ', grid_size

295 |      read(nfpio, '(I5)', iostat=ier) pio_iotype

328 |         write (ndiag,'(a, I10, a, I10)') ' node_count = ', node_count, ' grid_size = ', grid_size
```

Finally, modify line 170 of the `gen_mksurfdata_build` script to the following.

```
CC=mpicc FC=mpif90 cmake -DCMAKE_BUILD_TYPE=Debug -DCMAKE_Fortran_FLAGS=" -fallow-argument-mismatch -fallow-invalid-boz -ffree-line-length-none" $options $cwd/src
```

Then run
```
./gen_mksurfdata_build --machine hipergator
```
and the executable should build with the following output.

```
Successfully created mksurfdata_esmf executable for: hipergator_gnu for openmpi library
```

It is a good idea to check that the `parallelio` libraries were properly linked.
```
# go to the build directory
cd tool_bld

# examine linked libraries in the executable
ldd mksurfdata | grep libpio
```

You should see something like
```
libpiof.so => /blue/gerber/earth_models/uf.ctsm/libraries/parallelio/bld/lib/libpiof.so (0x00001500753d4000)
libpioc.so => /blue/gerber/earth_models/uf.ctsm/libraries/parallelio/bld/lib/libpioc.so (0x0000150075182000)
```

If it says "not found" then the libraries were not linked correctly and you need to retry building the executable.
