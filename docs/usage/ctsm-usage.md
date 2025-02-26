# Using CTSM On HiPerGator

[Basics](basic-usage-of-cesm)

1.1 [Recommended Reading](recommended-reading)

1.2 [File Structure](cesm-file-structure-on-hpg)

1.3 [Creating, Building, and Running a Case](cesm_case)

1.4 [Example](clm_example)

## 1. Basics<a name="basic-usage-of-cesm"></a>

This section is almost identical to the Basics section in `cesm-usage.md`. There are some subtle changes in directory locations and compsets. The documentation assumes you are using the shared CTSM install located at `/blue/gerber/earth_models/ctsm5.3`. If you are using a custom install, substitute your root CTSM path in place of the shared one.

### 1.1 Recommended Reading<a name="recommended-reading"></a>

There are three pieces of documentation that I strongly suggest you read through to familiarize yourself with the process of creating cases on CTSM.

1. The [quick start](https://escomp.github.io/CESM/versions/cesm2.1/html/quickstart.html) section of CESM's documentation.
2. The [Using the Case Control System](https://esmci.github.io/cime/versions/master/html/users_guide/index.html) section of the CIME documentation.
3. The [CTSM documentation](https://escomp.github.io/ctsm-docs/versions/master/html/users_guide/setting-up-and-running-a-case/index.html).

### 1.2 CESM File Structure on HPG<a name="cesm-file-structure-on-hpg"></a>

For the "gerber" group on HiPerGator, CESM has been installed in `/blue/gerber/earth_models/cesm2.1.5`. The scripts to create a new case or query information about case options are located in `/blue/gerber/earth_models/cesm2.1.5/cime/scripts`.

If you leave the `machine_config.xml` at its default settings, and create a "cases" directory at `/blue/GROUP/USER/cases`, the directory tree at `/blue/GROUP/USER` should look something like:

```bash
.
├── cases
│   └── EXAMPLE_CASE
└── earth_model_output
    ├── cesm_baselines
    ├── cime_output_root
    │   ├── archive
    │   └── EXAMPLE_CASE
    │       ├── bld
    │       └── run
    └── timings
```



### 1.3 Creating, Building, and Running a Case on HPG<a name="cesm_case"></a>

```bash
# cd to the cime scripts directory
cd /blue/gerber/earth_models/ctsm5.3/cime/scripts

# create your case, specifying the case location, compset, and resolution
./create_newcase --case /blue/GROUP/USER/cases/EXAMPLE-CASE --compset COMPSET --res RESOLUTION
```

CIME will output a bunch of text, then say whether the the case was created successfully, and where it was created.
If you are running a compset that is not scientifically validated, you will have to add the `--run-unsupported` option to your `create_newcase` command.

```bash
# go to the case directory
cd /blue/GROUP/USER/cases/EXAMPLE-CASE
```

For the "Gerber" group, there are a few variables that we will most likely need to change. The first is the number of cores used by the model. Most compsets will request one (or several) nodes (128-512 cores) by default.
Our research group only has access to 20 cores on our default queue, so we need to make sure we're under the QOS limit. We can do this with the `xmlchange` script.

First check how many cores each component is requesting by running `./pelayout`, which will list out the individual components, along with what resources they are asking for.
The variable we want to pay atention to is `NTASKS`. This corresponds to how many cores will be requested when the case is submitted.

```bash
# change the number of cores to something more sensible
./xmlchange NTASKS=8
```

This will take us down to using only 8 cores when we run the case.

The downside of using fewer cores, is that we may have to run the case for longer on the compute node. We can extend the time requested by changeing the `JOB_WALLCLOCK_TIME` variable.

```bash
# check the current setting
./xmlquery JOB_WALLCLOCK_TIME

# change the variable if needed
./xmlchange JOB_WALLCLOCK_TIME=1:00:00
```

If you're unsure of the exact name of the varibale you want to check/change, you can list all the defined variables, then pipe to grep and search.

```bash
# running grep with the -i flag will ignore case distinction
./xmlquery --listall | grep -i SEARCH_TERM
```

Once you've set all of your variables, setup, build, and submit the case as usual.

```bash
./case.setup
./case.build
./case.submit
```

If you setup and build the case but realize you need to change some variables before submitting, it's a good idea to clean the case before rebuilding. We can do this with something like:

```bash
./xmlchange SOME_VARIABLE

./case.setup --clean
./case.build --clean

./case.setup
./case.build
./case.submit
```

### 1.4 Example Case<a name="clm_example"></a>

Here is an example of creating, building, and running a case with a compset typical of what we would use in the SWES department.
The long name for our compset is `1850_DATM%CRUv7_CLM50%SP_SICE_SOCN_MOSART_CISM2%NOEVOLVE_SWAV` and the resolution we will be using is `f19_g17`. 
While we can certainly use the long name for the compset, sometimes it's nicer to use the alias (assuming one is available). Here's a trick for finding your compset's alias.

```bash
# cd to the cesm, cime scripts
cd /blue/gerber/earth_models/ctsm5.3/cime/scripts

# use the query config script, then pipe it to grep and search the compset's long name
./query_config --compsets all | grep 1850_DATM%CRUv7_CLM50%SP_SICE_SOCN_MOSART_CISM2%NOEVOLVE_SWAV
```

Which should output the following.

```bash
I1850Clm50SpCru      : 1850_DATM%CRUv7_CLM50%SP_SICE_SOCN_MOSART_CISM2%NOEVOLVE_SWAV
```

Now we can create the case.

```bash
# cd to the cesm, cime scripts
cd /blue/gerber/earth_models/ctsm5.3/cime/scripts

# create the case using a sensible name, the compset alias, and desired resolution
./create_newcase --case /blue/GROUP/USER/cases/EXAMPLE_CASE --compset I1850Clm50SpCru --res f19_g17

# cd to the case directory
cd /blue/GROUP/USER/cases/EXAMPLE-CASE

# check the amount of cores being requested by default
./xmlquery NTASKS

# it's probably going to be higher than our QOS, so we need to change it along with extending the job time
./xmlchange NTASKS=8,JOB_WALLCLOCK_TIME=1:00:00

# setup the case
./case.setup

# check the submit script to make sure it's requesting the correct amount of resources
./preview_run

# if everything looks good, build the case (this can take a few minutes)
./case.build

# submit the case to the scheduler and run the experiment
./case.submit
```

Check your UF email for updates from the `SLURM` scheduler. A case can fail for many reasons, most of which should be pretty obvious.
If you accidentally requested more resources than your QOS allows, it will tell you in the email. If your case fails with an OOM (out of memory) error, try increasing the number of cores by changing the `NTASKS` variable.
You may want to switch to your burst QOS sometimes. You can set this manually by changing the `JOB_QUEUE` variable (using the `xmlchange` script) to the name of your burst QOS. On hipergator your burst queue is your group name with "-b" appended. So the burst queue for the "gerber" group is gerber-b.

## Compset Testing

All compsets were tested at a resolution of `f19_g17`, with `NTASKS=8` and `JOB_WALLCLOCK_TIME=2:00:00`.

**I1850Clm45Bgc** - Successful run

**I1850Clm50Bgc** - Successful run

**I1850Clm50BgcCrop** - Successful run

**I1850Clm50SpCru** - Successful run

**I1850Clm50SpCru With STUBS** - Successful run

**I1850Clm60Sp** - Successful run

**I1850Clm60SpCru** - Successful run

**I1850Clm60BgcCropG** - ERROR: Could not find all input data on any server.

**IHistClm50Sp** - ERROR: Could not find all input data on any server.

**IHistClm50BgcQian** - ERROR: Could not find all input data on any server.

**IHistClm60SpCru** - MPI Runtime error

**I1PtClm50SpRs**- Build error, possibly with grid size.

```
ERROR: No default value found for streamslist with attributes {'model_grid': 'a%1.9x2.5_l%1.9x2.5_oi%null_r%null_g%null_w%null_z%null_m%gx1v7', 'datm_mode': '1PT', 'datm_co2_tseries': 'none', 'datm_presaero': 'clim_2000', 'datm_presndep': 'clim_2000', 'datm_preso3': 'clim_2000', 'clm_usrdat_name': 'UNSET'}.
```

**I1PtClm60Bgc** - Same build error as above.

## Documentation Issues

After reading the documentation and the following two comments from CESM forum admins, it looks like __everything__ in the documentation's single point case creation is either outdated or broken.

Admin Comments:
1. "Support for PTS_MODE in cime was dropped at some point so you are likely using a version of the model in which support was dropped."
   * It is still fine to use on our `CESM` install.

2. "If you want to subset existing global datasets to regional or single point please see the README in `tools/site_and_regional`. If you want to create your own regional datasets from scratch please see the `README` in `tools/mksurfdata_esmf`."
