#!/bin/bash

# PETSc
BASE_DIR="$INSTALL_DIR/petsc-$PETSC/"
if [ ! -d "$BASE_DIR" ]; then
  # PETSc
  echo "------------------------------Build petsc-$PETSC------------------------------"

  # Check PETSc External Packages Dir
  if [ ! -d "$SOURCE_DIR/petsc-external-$PETSC/" ]; then
    echo "PETSc External Packages Directory Does Not Exist!"
    exit 1
  fi

  # Get PETSc dependencies path
  DEPS=( chaco ctetgen hypre metis ml mumps parmetis ptscotch scalapack sowing suitesparse triangle zoltan )
  for DEP in ${DEPS[@]}; do
    _VARNAME="$DEP"_SRC_PATH
    declare "$_VARNAME"=$(ls "$SOURCE_DIR/petsc-external-$PETSC/$DEP"* | head -n 1 2>/dev/null)
    [ -z "${!_VARNAME}" ] && { echo "$DEP is not correctly downloaded at 'petsc-external-$PETSC' dir"; exit 1; }
    unset _VARNAME
  done

  cd "$SOURCE_DIR/petsc-$PETSC/"

  export PETSC_DIR="$SOURCE_DIR/petsc-$PETSC/"
  export PETSC_ARCH="sunway-opt"

  rm -rf "$SOURCE_DIR/petsc-$PETSC/$PETSC_ARCH/"
  FFLAGS=-OPT:IEEE-arith=1                                          \
  CFLAGS=-OPT:IEEE-arith=1                                          \
  ./configure                                                       \
    --prefix="$BASE_DIR"                                            \
    --with-cc='mpicc'                                               \
    --with-cxx='mpiCC'                                              \
    --with-fc='mpif90'                                              \
    --known-mpi-shared-libraries=0                                  \
    --with-single-library=1                                         \
    --with-shared-libraries=0                                       \
    --with-blas-lapack-lib='-lxMath_manycore'                       \
    --with-batch=1                                                  \
    --with-64-bit-indices                                           \
    --with-mpi=1                                                    \
    --with-debugging=0                                              \
    --with-packages-dir="$SOURCE_DIR/petsc-external-$PETSC"         \
    --download-chaco="$chaco_SRC_PATH"                              \
    --download-ctetgen="$ctetgen_SRC_PATH"                          \
    --download-hypre="$hypre_SRC_PATH"                              \
    --download-metis="$metis_SRC_PATH"                              \
    --download-ml="$ml_SRC_PATH"                                    \
    --download-mumps="$mumps_SRC_PATH"                              \
    --download-parmetis="$parmetis_SRC_PATH"                        \
    --download-ptscotch="$ptscotch_SRC_PATH"                        \
    --download-scalapack="$scalapack_SRC_PATH"                      \
    --download-sowing="$sowing_SRC_PATH"                            \
    --download-suitesparse="$suitesparse_SRC_PATH"                  \
    --download-triangle="$triangle_SRC_PATH"                        \
    --download-zoltan="$zoltan_SRC_PATH"                            \
    --with-fortran-interfaces=1                                                2>&1 | tee "$LOG_DIR/petsc-$PETSC.conf.log"
  bsub -I -q q_sw_expr -n 1 ./conftest-$PETSC_ARCH                             2>&1 | tee "$LOG_DIR/petsc-$PETSC.conftest.log"
  ./reconfigure-arch-linux2-c-opt.py                                           2>&1 | tee "$LOG_DIR/petsc-$PETSC.reconf.log"
  make test                                                                    2>&1 | tee "$LOG_DIR/petsc-$PETSC.make_test.log"
  make all                                                                     2>&1 | tee "$LOG_DIR/petsc-$PETSC.make_all.log"
  make install                                                                 2>&1 | tee "$LOG_DIR/petsc-$PETSC.inst.log"

  unset PETSC_ARCH
  unset PETSC_DIR
fi
cat "$MOD_IN_DIR/petsc.in" | mo > "$MOD_GL_DIR/petsc-$PETSC"
