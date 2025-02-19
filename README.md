# README

A repository containing the documentation, configuration files, and custom scripts for Earth system models on HiPerGator.

Maintained by the Gerber research group.

Contact sgerber@ufl.edu, cdevaneprugh@ufl.edu with questions.

## Repository Tree

```bash
.
├── config							# Configuration files for using Earth system models on HiPerGator
│   ├── cesm						# CESM configuration files.
│   │   ├── config_batch.xml
│   │   ├── config_compilers.xml
│   │   └── config_machines.xml
│   ├── hpg							# Minimal HiPerGator configuration files.
│   │   ├── config_batch.xml
│   │   ├── config_compilers.xml
│   │   └── config_machines.xml
│   ├── README
│   ├── update.configs				# Script to deploy config files to Earth model install for the Gerber group.
│   └── verify.configs				# Script to verify config files using xmllint.
├── docs							# Documentation.
│   ├── glossary.md
│   ├── intro-to-earth-models.md
│   ├── linux-overview.md
│   ├── porting
│   │   ├── cesm-porting.md
│   │   ├── ctsm-porting.md
│   │   ├── forking-ctsm.md
│   │   ├── mksurfdata-fixes.md
│   │   └── shared-utils (READ FIRST).md
│   ├── README-FIRST.md
│   └── usage
│       ├── cesm-usage.md
│       ├── ctsm-doc-comparison.md
│       └── ctsm-usage.md
├── README.md						# This file
└── scripts							# Miscellaneous scripts.
    ├── mpi.testing					# Scripts for testing MPI environments.
    │   ├── connectivity_c.c
    │   ├── hello_world
    │   │   ├── fhello_world_mpi.f90
    │   │   ├── hello_c.c
    │   │   ├── hello_f08.f90
    │   │   ├── hello_f90.f90
    │   │   └── hello_mpifh.f
    │   ├── README
    │   └── ring
    │       ├── ring_c.c
    │       ├── ring_f08.f90
    │       ├── ring_f90.f90
    │       └── ring_mpifh.f
    └── ready_clm_case				# Script to prepare clm cases.
```
