string(APPEND FFLAGS " -fallow-argument-mismatch  -fallow-invalid-boz ")

set(ESMF_LIBDIR "/apps/gcc/12.2.0/openmpi/4.1.6/esmf/8.7.0/lib/libO/Linux.gfortran.64.openmpi.default")
set(LAPACK_LIBDIR "/apps/gcc/12.2.0/lapack/3.11.0/lib")
set(NETCDF_PATH "/apps/gcc/12.2.0/openmpi/4.1.6/netcdf-c/4.9.2")
set(NETCDF_C_PATH "/apps/gcc/12.2.0/openmpi/4.1.6/netcdf-c/4.9.2")
set(NETCDF_FORTRAN_PATH "/apps/gcc/12.2.0/openmpi/4.1.6/netcdf-f/4.6.1")

execute_process(COMMAND ${NETCDF_FORTRAN_PATH}/bin/nf-config --flibs OUTPUT_VARIABLE SHELL_CMD_OUTPUT_BUILD_INTERNAL_IGNORE0 OUTPUT_STRIP_TRAILING_WHITESPACE)
string(APPEND SLIBS " ${SHELL_CMD_OUTPUT_BUILD_INTERNAL_IGNORE0}")
string(APPEND SLIBS " -L$(LAPACK_LIBDIR) -llapack -lblas")
