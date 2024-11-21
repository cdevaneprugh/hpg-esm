# hpg-esm

# Table of Contents

1. [Introduction](#intro)
   1. [Glossary](#glossary)
2. [General Linux Info](#linux_title)
   1. [Linux Command Line and Bash Overview](#linux_intro)
   2. [Basic Commands](#linux_commands)
   3. [Text Editors](#linux_editors)
   4. [External Resources](#linux_resources)
3. [HiPerGator Specific Information](#hpg_title)
   1. [Module Systems](#hpg_lmod)
   2. [Job Schedulers](#hpg_slurm)

4. [Earth Models](#esm_title)
   1. [Prerequisites](#esm_prereqs)
   2. [Porting CESM](#cesm_port)
      1. [Downloading CESM](#cesm_download)
      2. [CPRNC Install](#cprnc_install)
   3. [Porting and Validating CIME](#cime_port)
      1. [Regression Testing](#reg_tests)
      2. [Ensemble Consistency Testing](#ect)
5. [Single Point Cases](#pts_mode)
   1. [Best Practices & Where We Went Wrong](#clm_best_practices)
   2. [Compset Testing](#clm_compset_testing)


# Introduction <a name="intro"></a>

The primary goal of this document is to serve as a guide for porting the [CESM](https://www.cesm.ucar.edu/) and [E3SM](https://e3sm.org/) Earth models to HiPerGator. I follow the official documentation for each Earth model, and add steps specific to HiPerGator as needed. Additionally, I'm including a section that can serve as an introduction to using Linux, which many students have limited exposure to.

## Glossary <a name="glossary"></a>

__CESM__ - Community Earth System Model. CESM is a fully-coupled, community maintained, global climate model that provides state-of-the-art computer simulations of the Earth's past, present, and future climate states.

__CIME__ - Common Infrastructure for Modeling the Earth (pronounced “SEAM”) provides a Case Control System for configuring, compiling and executing Earth system models, data and stub model components, a driver and associated tools and libraries.

__CLM__ - [Community Land Model](https://www.cesm.ucar.edu/models/clm). The land component used in CESM. It has the capability to model specific processes such as vegetation composition, heat transfer in soil, carbon-nitrogen cycling, canopy hydrology, and many more.

__E3SM__ - Energy Exascale Earth System Model. E3SM is the Department of Energy's climate model. Forked from CESM v1 and developed independently by the DOE, they describe E3SM as "an ongoing, state-of-the-science Earth system modeling, simulation, and prediction project that optimizes the use of DOE laboratory resources to meet the science needs of the nation and the mission needs of DOE."

__HPG__ - HiPerGator. The supercomputer used at UF. I'll use HPG and HiPerGator interchangeably throughout the documentation.

# General Linux Information <a name="linux_title"></a>

If you are new to HiPerGator or Linux I suggest you read through this section and utilize at least one of the resources linked below. While HiPerGator offers access to the system with a GUI or the ability to code via Jupyter notebooks, the Earth models will require you to use the command line exclusively, so it's important you are comfortable doing so.

## Linux Command Line and Bash Overview <a name="linux_intro"></a>

The Linux command line, also referred to as the terminal or shell, is a text-based interface for interacting with the Linux operating system. It allows users to execute commands and perform various tasks efficiently, without relying on a graphical user interface.

**Command Line Advantages:**

- **Efficiency:** The command line provides quick access to powerful tools and utilities, enabling you to perform tasks more efficiently compared to a GUI.
- **Automation:** Command line scripting allows for the automation of repetitive tasks, saving time and effort.
- **Flexibility:** Advanced users can customize and tailor their workflow to suit their specific needs, leveraging the extensive capabilities of the command line.

**Bash:**
Bash (Bourne Again Shell) is one of the most commonly used command line interpreters in Linux. It is the default shell for most Linux distributions (including HiPerGator) and provides a powerful scripting environment for automation and system administration tasks.

## Basic Commands: <a name="linux_commands"></a>

1. **pwd (Print Working Directory):**
   - Displays the current directory path.
   - Example: If you are in the "home" directory of the user "cooper," `pwd` would output `/home/cooper` in your terminal.
2. **ls (List):**
   - Lists files and directories in the specified directory (or current directory if one isn't given).
   - Example: `ls my_files` would list the contents of the directory "my_files."
3. **cd (Change Directory):**
   - Changes the current directory to the specified one.
   - Example: `cd dir1` will change your current working directory to `dir1` so long as that directory is in your current working path.
   - If no directory is specified, `cd` will move you to your `home` directory.
4. **touch:**
   - Creates an empty file.
   - Example: `touch filename.txt` creates an empty text file.
5. **mkdir (Make Directory):**
   - Similar to `touch`, but creates an empty directory instead. 
   - As with all these commands, you can use relative or absolute paths. For example `mkdir dir1` creates an empty directory named "dir1" in the current directory. `mkdir /home/cooper/dir1` creates "dir1" in Cooper's home directory.
6. **rm (Remove):**
   - Delete files or directories.
   - Example: `rm filename.txt` (for files), `rm -r directory` (for directories where the `-r` flag specifies to remove things recursively).
7. **cp (Copy):**
   - Copies files or directories.
   - Example: `cp file1 file2` (to copy file1 to file2), `cp -r dir1 dir2` (to copy dir1 to dir2 recursively).
8. **mv (Move):**
   - Moves or renames files or directories.
   - Example: `mv file1 file2` (to rename file1 to file2), `mv file1 /path/to/directory` (to move file1 to another directory).
9. **grep (Global Regular Expression Print):**
   - Searches for text patterns.
   - Example: `grep foo notes.txt` searches for the term "foo" in the file notes.txt.
10. **man (Manual):**
    - Displays manual pages for commands, providing detailed information about their usage and options.
    - Example: `man ls` displays the manual page for the `ls` command.
11. **Piping (|):**
    - Allows the output of one command to be used as input to another command.
    - Example: `command1 | command2` (output of `command1` is used as input for `command2`).
    - Example: `ls Documents | grep my_file` Will search the "Documents" directory for files titled "my_file." You could also add the `-r` flag to the `grep` command to search within each file for the search term.

## Text Editors<a name="linux_editors"></a>

The three main text editors used on Linux are [Vim](https://en.wikipedia.org/wiki/Vim_(text_editor)), [Emacs](https://en.wikipedia.org/wiki/GNU_Emacs), and [Nano](https://en.wikipedia.org/wiki/GNU_nano). `nano` is the most basic, and easiest to use. `vim` and `emacs` are extremely customizable, but have a substantially steeper learning curve. Between `vim` and `emacs`, `vim` is arguably the most difficult to get comfortable with, but is powerful once you do. If you decide you are brave enough to try it, sites like [openvim](https://www.openvim.com/) or running the command `vimtutor` (which starts an interactive tutorial) on any Linux machine are good places to start. Additionally [here](https://vim.rtorr.com/) is a cheat sheet of `vim` commands that serve as a nice reference.

__WARNING__ The default text editor on Linux is usually `vim`. There may be a time when you accidentally open a file in `vim` and can't figure out how to exit the program. This may sound silly, but I promise you, the jokes about `vim` being confusing are endless in the Linux community. If you do find yourself trapped in and need to exit. Hit the `esc` key, then type `:q!` and hit `enter`. This will exit whatever file you got yourself into without saving any changes. If you _would_ like to make a quick change to the file you got into, hit `esc`, followed by the `i` key to enter "insert" mode. At this point you can type up whatever you need (use the arrow keys for navigation). To save, use `esc` to exit insert mode, then type `:wq` and hit `enter`. This will write the file (`w`) then quit out of the editor (`q`). 

## External Resources<a name="linux_resources"></a>

Here are some resources to get started using the Linux command line, and learn a bit more about what is going on "under the hood." You don't need to memorize everything in these links, but they can serve as a good starting point.

1. https://linuxjourney.com/

   The "Grasshopper" and "Journeyman" sections will give you a good chunk of background knowledge. I should note that because HiPerGator is not a traditional computer, some of the information (like package management) will not directly translate. However, it will help build a foundation of Linux knowledge and is certainly worth being exposed to. 

2. Hipergator's [Introduction to the Linux Command Line](https://github.com/UFResearchComputing/Linux_training/blob/main/non_HiPerGator.md)

   A good demonstration of basic Linux commands you will be using on a daily basis, along with some practice exercises. I highly recommend going through this entire lesson and watching the accompanying [training video](https://help.rc.ufl.edu/doc/Training_Videos).

3. jlevy's [art of the command line](https://github.com/jlevy/the-art-of-command-line)

   This write up covers a wide range of commands and could serve as a good reference sheet. 

4. YouTube has plenty of tutorials. [Here's a good one](https://www.youtube.com/watch?v=s3ii48qYBxA) that serves as an introduction to the command line.

5. [ChatGPT](https://chat.openai.com/) is actually pretty good at BASH scripting and serving as an interactive assistant.

# HiPerGator Specific Information<a name="hpg_title"></a>

HiPerGator is not set up like a traditional personal computer. While Google and sites like [stack overflow](https://stackoverflow.com/) are great resources to use when you run into problems, remember to check HiPerGator's [documentation](https://help.rc.ufl.edu/doc/UFRC_Help_and_Documentation) first, as it will have information specific to our system.

Additionally, when using Linux, you should build the habit of using the commands `man` and `--help` to get yourself out of trouble. `man` will access the built in documentation for Linux commands and programs that are on the system. For example, say you want to learn about the `ls` command, and all the options it has. You can type `$ man ls` (where the $ sign is your `bash` prompt) to pull up the documentation page. You can also type `$ ls --help` for a list available arguments and options. 

If you are new to HiPerGator I would highly recommend reading through their [FAQ](https://www.rc.ufl.edu/documentation/frequently-asked-questions/),  [Getting Started](https://help.rc.ufl.edu/doc/Getting_Started) page, and watching all of the available training videos provided in the [documentation](https://help.rc.ufl.edu/doc/Training_Videos).

## Module Systems and lmod<a name="hpg_lmod"></a>

HiPerGator uses a program called `lmod` to be able to have multiple versions of the same software installed for different use cases. [Here is a good article](https://www.admin-magazine.com/HPC/Articles/Lmod-Alternative-Environment-Modules?utm_source=ADMIN+Newsletter&utm_campaign=HPC_Update_31_Lmod_Alternative_to_Environment_Modules_2013-01-30) that gives an overview of module systems and how they work. While the HiPerGator [documentation](https://help.rc.ufl.edu/doc/Modules) has great info that I suggest you read, the full documentation for `lmod` can be found [here](https://lmod.readthedocs.io/en/latest/). 

## Job Schedulers and slurm<a name="hpg_slurm"></a>

Unlike a personal computer, HiPerGator is a collection of connected computers (called nodes) that share resources. The node that you login to (unsurprisingly called a login node) has a limited amount of resources, and is generally used for tasks like writing code, file management, and very light jobs. As such, you will submit more computationally "expensive" jobs to the SLURM scheduler to run on the dedicated compute nodes.

Please read the page on our scheduler [here](https://help.rc.ufl.edu/doc/HPG_Scheduling). The full documentation for the SLURM scheduler can be found [here](https://slurm.schedmd.com/documentation.html).

# Earth Models<a name="esm_title"></a>

Both Earth models (E3SM and CESM) use the same underlying infrastructure (CIME) to build and run cases (experiments). CIME generates the scripts necessary to download appropriate files, build the case, and push it to the scheduler to run on a compute node. In some sense, downloading and porting the Earth models is not so much about the specific Earth model, and more about getting CIME to interact with HiPerGator properly. The configuration files CIME uses are almost entirely the same (except for a couple extra parameters for E3SM). 

Ultimately, the goal at UF is to have both the Earth models installed in some shared directory on HiPerGator, but until then this can serve as a guide to do an install for your research group. Going forward, I am assuming you are reasonably comfortable navigating HiPerGator and using basic Linux commands.

## Prerequisites<a name="esm_prereqs"></a>

__Default Loaded Modules__

To download the external components (like CLM), as well as boundary conditions, we need a program called `subversion`. Additionally, the Earth models need to utilize `perl` scripts and `cmake`. While there is a `perl` library loaded by default, it is generally a better practice to specify which version we want to use. This will make future debugging easier. To load the programs needed, we can do something like:

```bash
module load perl/5.24.1
module load subversion/1.9.7
module load cmake/3.26.4
module save default
```

This will ensure that the needed programs are loaded by default when you log in to HiPerGator.

## Porting CESM<a name="cesm_port"></a>

CESM has [two primary releases](https://www.cesm.ucar.edu/models), the current development release (v2.2.2 at the time of this writing), and the production release (v2.1.5). We will be using the production release. I am following the [CESM documentation](https://escomp.github.io/CESM/versions/cesm2.1/html/index.html), as well as the [CIME porting documentation](https://esmci.github.io/cime/versions/master/html/users_guide/porting-cime.html) while adding the steps needed to get this working on HiPerGator.

### Downloading the code<a name="cesm_download"></a>

While the repository is not that large, it should be put on the `/blue` drive for fast access. It is completely up to the user and group how the file structure is organized. We decided to have a shared directory called `/earth_models` that contains the source code for the CESM and E3SM models, as well as the input data directory (which can get rather large). Remember to make sure that all users in the group have read/write privileges to this directory.

Follow directions in the [CESM documentation](https://escomp.github.io/CESM/versions/cesm2.1/html/downloading_cesm.html) to clone the repository and checkout the external components.

```bash
# cd into the directory you want cesm installed
cd /blue/GROUP/earth_models

# clone the cesm repository
git clone -b release-cesm2.1.5 https://github.com/ESCOMP/CESM.git cesm2.1.5

# cd into your cesm directory
cd cesm215

# download the external components
./manage_externals/checkout_externals

# check that the components were installed correctly
./manage_externals/checkout_externals -S
```

The last command should output something like:

```bash
Processing externals description file : Externals.cfg
Processing externals description file : Externals_CLM.cfg
Processing externals description file : Externals_POP.cfg
Processing externals description file : Externals_CISM.cfg
Checking status of externals: clm, fates, ptclm, mosart, ww3, cime, cice, pop, cvmix, marbl, cism, source_cism, rtm, cam,
    ./cime
    ./components/cam
    ./components/cice
    ./components/cism
    ./components/cism/source_cism
    ./components/clm
    ./components/clm/src/fates
    ./components/clm/tools/PTCLM
    ./components/mosart
    ./components/pop
    ./components/pop/externals/CVMix
    ./components/pop/externals/MARBL
    ./components/rtm
    ./components/ww3
```

If there were issues with any of the components, you would see an error:

```bash
e-  ./components/clm
```

By default, CESM downloads the most recent version of the CIME code, which unfortunately causes some bugs. We can fix that by checking out an older, more stable version.

```bash
cd cime
git pull origin maint-5.6
git checkout maint-5.6
```

If you run `./checkout_externals -S` after changing the CIME branch, it may show an error that CIME is not using the correct version. You can ignore this.

### Install the cprnc tool<a name="cprnc_install"></a>

While this is _technically_ optional, you should download [cprnc](https://github.com/ESMCI/cprnc), a tool used to compare netcdf files. We installed this in `/blue/GROUP/earth_models` as it is a utility shared by both CESM and E3SM.

Make sure `cmake` a compiler suite, and the corresponding `netcdf` libraries are loaded.

```bash
module load gcc/12.2.0 openmpi/4.1.6 netcdf-c/4.9.2
module load gcc/12.2.0 openmpi/4.1.6 netcdf-f/4.6.1
```

Clone the repository and `cd` into it.

```bash
git clone https://github.com/ESMCI/cprnc.git cprnc
cd cprnc
```

Follow directions in the README. `cprnc` is a fortran-90 program, and it may throw an error that it can't find the `netcdf-c` libraries, but this doesn't seem to matter as far as building the executable.

```bash
mkdir bld
cd bld
cmake ../
make
```

The executable will be located at `/blue/GROUP/earth_models/cprnc/bld/cprnc`.

## Porting and Validating CIME<a name="cime_port"></a>

HPG has all the appropriate software and libraries installed and checked for functionality. However, we have to set up three configuration files to ensure CIME knows how to access the resources it needs. There are two ways we can do this.

1. You can edit **$CIMEROOT/config/$model/machines/config_machines.xml** and add an appropriate section for your machine.
2. You can use your **$HOME/.cime** directory (see [CIME config and hooks](https://esmci.github.io/cime/versions/master/html/users_guide/cime-customize.html#customizing-cime)). In particular, you can create a **$HOME/.cime/config_machines.xml** file with the definition for your machine. A template to create this definition is provided in **$CIMEROOT/config/xml_schemas/config_machines_template.xml**. More details are provided in the template file. In addition, if you have a batch system, you will also need to add a **config_batch.xml** file to your **$HOME/.cime** directory. All files in **$HOME/.cime/** are appended to the xml objects that are read into memory from the **$CIME/config/$model**, where **$model** is either `e3sm` or `cesm`.

We are using method two, as there some parameters in the config files that need to be defined by the user, such as their email address, preferred IO directory structure, etc. I have created config files that are set up for hpg. The files are available on this github repository, and should be saved in `/home/$USER/.cime`. You should just be able to do a `git checkout` in your home directory, then modify the appropriate parameters. Most parameters in the config files will be the same for every research group at UF. There are detailed comments in the config files explaining what needs to be changed for each user.

```bash
# make sure you're in your home directory
cd

# checkout the files
git checkout -r URL_HERE .cime

# make sure the files are there
ls .cime
```

### Regression Testing<a name="reg_tests"></a>

Once the config files are setup, we need to run regression tests to ensure things are working correctly. The regression tests script will test various parameters of the Earth model in isolation, then send a dozen or two small cases to the scheduler to be run. This script is not resource intensive and can be run from a login node.

You'll need python to run the script. Version 3.11 seems to work just fine.

```bash
# load python
module load python/3.11

# go to the location of the regression tests
cd /blue/GROUP/earth_models/CESM/cime/scripts/tests
```

You can run the script with several options. Use the `--help` tag when running the script for the full list of them. For example, if you want to run the script and test the intel compilers, using a specific output directory, you could do something like:

```
./scripts_regression_tests.py --compiler intel --test-root PATH_TO_OUTPUT_DIR
```

By default, the test output will be saved in the `$CIME_OUTPUT_ROOT` directory defined in your `config_machines.xml` file.

These tests can take up to an hour or two to finish everything (depending how busy your scheduler is as well as how many cores your group has paid for).

Once all these tests are passed we can move onto the ECT tests. 

__Note:__ When all the tests are run at once, occasionally you get failures on individual components. They are usually the Q_TestBlessTestResults  T_TestRunRestart or Z_FullSystem tests. But if you rerun these tests individually, and they pass, overall your system should be good.

### Ensemble Consistency Testing<a name="ect"></a>

Follow the guide [here](https://www.cesm.ucar.edu/models/cesm2/python-tools) in order to complete these tests. You'll just need to change the case output location, machine, and compiler name to reflect your setup. I should note that to run the script to create these tests we have to load an older version of python.

```bash
module load python-core/2.7.14
```

Additionally, to use the `addmetadata` script we need the `nco` tool `ncks`. The version available on hipergator is not new enough so we will have to create a conda environment and install the tool ourselves. Instructions for using conda on hipergator can be found [here](https://help.rc.ufl.edu/doc/Conda). You just need to download the most recent version of `nco` with something like `mamba install nco`.

# Single Point Cases<a name="pts_mode"></a>

Following the instructions [here](https://escomp.github.io/ctsm-docs/versions/release-clm5.0/html/users_guide/running-single-points/running-pts_mode-configurations.html), we can run the clm model on a single grid cell by specifying a latitude and longitude. However, the instructions on the clm website seem to be a bit outdated. CIME no longer supports the `-pts_lat` or `-pts_lon`  arguments with the `create_newcase` script, also multi-character arguments should begin with `--` rather than `-`.  We can still run on a single point by creating a new case, then changing the appropriate variables before building the executable.

The compset used to test the Ordway Swisher Biological Station has the full name `1850_DATM%CRUv7_CLM50%SP_SICE_SOCN_MOSART_CISM2%NOEVOLVE_SWAV` however the short name given (`I1850Clm50BSpCru`) is not found in our supported compset lists. I think you added an extra "B" in the short compset name. We can use the `query_config` script to find supported compsets.

```bash
# cd to cime/scripts 
cd /blue/gerber/earth_models/cime/scripts

# find the shortname for the compset
./query_config --compsets all | grep 1850_DATM%CRUv7_CLM50%SP_SICE_SOCN_MOSART_CISM2%NOEVOLVE_SWAV
```

Which outputs the following to the terminal.

```
I1850Clm50SpCru      : 1850_DATM%CRUv7_CLM50%SP_SICE_SOCN_MOSART_CISM2%NOEVOLVE_SWAV
```

To create our case we can do something like:

```bash
./create_newcase --case /blue/gerber/cdevaneprugh/cases/testPTS_OSBS --res f19_g17 --compset I1850Clm50SpCru

# cd to the case directory
cd /blue/gerber/cdevaneprugh/cases/testPTS_OSBS

# change variables to run on a single point
./xmlchange PTS_MODE=TRUE,PTS_LAT=29.7,PTS_LON=-82.0
./xmlchange CLM_FORCE_COLDSTART=on,RUN_TYPE=startup

# change variables to use a single core and adjust wall time
./xmlchange NTASKS=1
./xmlchange JOB_WALLCLOCK_TIME=1:00:00

# setup, build, and submit the case as usual
./case.setup
./case.build
./case.submit
```

This case will build and download input data, but fail during runtime with the following mpi error.  

```bash
MPI_ABORT was invoked on rank 0 in communicator MPI_COMM_WORLD with errorcode 2.

NOTE: invoking MPI_ABORT causes Open MPI to kill all MPI processes.
You may or may not see output from other processes, depending on exactly when Open MPI kills them.
```

Following advice on [my forum post](https://bb.cgd.ucar.edu/cesm/threads/issues-downloading-input-data-in-clm5-single-point-mode.9600/#post-55331), I tried a different compset which worked perfectly.

```bash
# create case
./create_newcase --case /blue/gerber/cdevaneprugh/cases/osbsPTSmod --compset 1850_DATM%CRUv7_CLM50%SP_SICE_SOCN_SROF_SGLC_SWAV --res f19_g17 --run-unsupported
cd /blue/gerber/cdevaneprugh/cases/osbsPTSmod

# change variables
./xmlchange NTASKS=1,JOB_WALLCLOCK_TIME=1:00:00
./xmlchange PTS_MODE=TRUE,PTS_LAT=29.7,PTS_LON=-82.0
./xmlchange CLM_FORCE_COLDSTART=on,RUN_TYPE=startup

# setup and build case like normal
./case.setup
./case.build

# check input data
./check_input_data

# submit case
./case.submit
```
The next section will go into where we went wrong, and some things we can do to have successful runs in the future.

## CLM Best Practices and Where Our PTS Run Went Wrong<a name="clm_best_practices"></a>

The full comment from my [post](https://bb.cgd.ucar.edu/cesm/threads/issues-downloading-input-data-in-clm5-single-point-mode.9600/#post-55331) is:

> The error message in the cesm log is:
>
> MCT::m_SparseMatrixPlus:: FATAL--length of vector y different from row count of sMat.Length of y = 1 Number of rows in sMat = 13824
> 000.MCT(MPEU)::die.: from MCT::m_SparseMatrixPlus::initDistributed_()
>
> It seems like there must be mismatch between two of the datasets you are using. One seems to be single point (y=1) and the other is 1.9x2.5 (144x96=13824). I think it might be because the compset you are using has CISM and MOSART in it. The long name for that compset is:
>
> 1850_DATM%CRUv7_CLM50%SP_SICE_SOCN_MOSART_CISM2%NOEVOLVE_SWAV
>
> Try specifying stubs for those, e.g.,
>
> 1850_DATM%CRUv7_CLM50%SP_SICE_SOCN_SROF_SGLC_SWAV

So the hypothesis is that any compset with MOSART or CISM will cause an issue in single point mode. Okay, so the easiest option is to just pick a compset we like, then specify stubs in the same way that was suggested in the post. The only problem is that doing this turns our compset into one that is not scientifically validated. This might not be an issue for our purposes. I also noticed an interesting thing in the [clm documentation's best practices section](https://escomp.github.io/ctsm-docs/versions/release-clm5.0/html/users_guide/overview/introduction.html#best-practices).

> CLM5.0 includes BOTH the old CLM4.0, CLM4.5 physics AND the new CLM5.0 physics and you can toggle between those three. The “standard” practice for CLM4.0 is to run with CN on, and with Qian atmospheric forcing. While the “standard” practice for CLM4.5 is to run with BGC on, and CRUNCEP atmospheric forcing. And finally the “standard” practice for CLM5.0 is to run with BGC and Prognostic Crop on, with the MOSART model for river routing, as well as the CISM ice sheet model, and using GSWP3 atmospheric forcing. “BGC” is the new CLM5.0 biogeochemistry and include CENTURY-like pools, vertical resolved carbon, as well as Nitrification and de-Nitrification

So if it is best practice to use MOSART as well as CISM for clm5.0, maybe we can just use the clm4.0 or 4.5 physics instead. For a test, I'm going to look at the initial compsets Stefan gave to me, then see if I can find the equivalent one that is running clm4.0 or 4.5 and test those.

Looking at the compsets, the one suggested in the forum post is effectively the clm4.0 version of what Stefan wanted, but with clm5.0 physics substituted (remember this doesn't follow best practices and is not scientifically validated). There are also plenty of scientifically valid compsets that don't use MOSART or CISM.

It would be interesting to see if I can narrow down which is messing us up. I'll find a compset with only CISM, see if that runs globally and in single point mode, then repeat with a compset containing MOSART.

With the abundance of compsets and resolutions, I'm going to need a better naming convention for my case directories. I think something like `compset.resolution.modifiers` would work. For example the name for our initial single point test (that failed) would be `I1850Clm50SpCru.f19_g17.PTS`.

### Compset Testing<a name="clm_compset_testing"></a>

__Compset Long Name	:	Compset Alias	:	Resolution Used__

1850_DATM%CRUv7_CLM40%SP_SICE_SOCN_RTM_SGLC_SWAV	:	I1850Clm40SpCruGs	:	f19_g17

1. Global: Success

2. PTS: Success

   

1850_DATM%GSWP3v1_CLM45%CN_SICE_SOCN_RTM_CISM2%NOEVOLVE_SWAV	:	I1850Clm45Cn	:	f19_g17

1. Global: Success

2. PTS: Fail 

   > MCT::m_SparseMatrixPlus:: FATAL--length of vector y different from row count of sMat.Length of y = 1 Number of rows in sMat = 13824
   >
   > 000.MCT(MPEU)::die.: from MCT::m_SparseMatrixPlus::initDistributed_()



1850_DATM%CRUv7_CLM50%SP_SICE_SOCN_MOSART_CISM2%NOEVOLVE_SWAV	:	I1850Clm50SpCru	:	f19_g17

1. Global: Success

2. PTS: Fail

   > MCT::m_SparseMatrixPlus:: FATAL--length of vector y different from row count of sMat.Length of y = 1 Number of rows in sMat = 13824
   >
   > 000.MCT(MPEU)::die.: from MCT::m_SparseMatrixPlus::initDistributed_()

   

1850_DATM%CRUv7_CLM50%SP_SICE_SOCN_SROF_SGLC_SWAV	:	NONE	:	f19_g17

1. Global: Success

2. PTS: Success

   

2000_DATM%GSWP3v1_CLM50%SP-VIC_SICE_SOCN_RTM_CISM2%NOEVOLVE_SWAV	:	I2000Clm50Vic	:	f09_g17

1. Global:

2. PTS:

   

HIST_DATM%GSWP3v1_CLM40%SP_SICE_SOCN_RTM_SGLC_SWAV	:	IHistClm40SpGswGs	:	f09_g17

1. Global: Success
2. PTS: Success



HIST_DATM%GSWP3v1_CLM45%SP_SICE_SOCN_RTM_SGLC_SWAV	:	IHistClm45SpGs	:	f09_g17

1. Global: Fail (Out of Memory)

   > Primary job  terminated normally, but 1 process returned
   > a non-zero exit code. Per user-direction, the job has been aborted.

2. PTS: Success



HIST_DATM%QIA_CLM50%BGC_SICE_SOCN_MOSART_SGLC_SWAV	:	IHistClm50BgcQianGs	:	f09_g17

1. Global:
2. PTS:



HIST_DATM%GSWP3v1_CLM50%SP_SICE_SOCN_MOSART_CISM2%NOEVOLVE_SWAV	:	IHistClm50Sp	:	f09_g17

1. Global: Fail (Out of Memory)

   > Primary job  terminated normally, but 1 process returned
   > a non-zero exit code. Per user-direction, the job has been aborted.

2. PTS: Fail

   > MCT::m_SparseMatrixPlus:: FATAL--length of vector y different from row count of sMat.Length of y = 1 Number of rows in sMat = 55296
   > 000.MCT(MPEU)::die.: from MCT::m_SparseMatrixPlus::initDistributed_()

