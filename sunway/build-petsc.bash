#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/setup.bash"

# Add Sunway compiler tools PATH
export PATH="/usr/sw-mpp/bin/:$PATH"

export CC='/usr/sw-mpp/bin/mpicc'
export CXX='/usr/sw-mpp/bin/mpiCC'
export FC='/usr/sw-mpp/bin/mpif90'
export AR='/usr/sw-mpp/bin/sw5ar'
export RANLIB='/usr/sw-mpp/bin/sw5ranlib'

# PETSc
BASE_DIR="$INSTALL_DIR/petsc-$PETSC/"
if [ ! -d "$BASE_DIR" ]; then
  # PETSc
  echo "------------------------------Build petsc-$PETSC------------------------------"

  cd "$SOURCE_DIR/"
  _FILE="petsc-$PETSC.tar.gz"
  __DIR="${_FILE%.tar.gz}"
  rm -rf "$__DIR" && mkdir -p "$__DIR" && tar xzf "$_FILE" -C "$__DIR" --strip-components=1

  # Check PETSc External Packages Dir
  _FILE="$SOURCE_DIR/petsc-external-$PETSC.tar.gz"
  __DIR="${_FILE%.tar.gz}"

  if [ ! -f "$_FILE" ]; then
    echo "PETSc External Packages Tarball Does Not Exist!"
    exit 1
  fi

  rm -rf "$__DIR" && mkdir -p "$__DIR" && tar xzf "$_FILE" -C "$__DIR" --strip-components=1

  unset __DIR
  unset _FILE

  # Get PETSc dependencies path
  # DEPS=( chaco ctetgen hypre metis ml mumps parmetis ptscotch scalapack sowing suitesparse triangle zoltan )
  # for DEP in ${DEPS[@]}; do
  #   _VARNAME="$DEP"_SRC_PATH
  #   declare "$_VARNAME"=$(ls "$SOURCE_DIR/petsc-external-$PETSC/$DEP"* | head -n 1 2>/dev/null)
  #   [ -z "${!_VARNAME}" ] && { echo "$DEP is not correctly downloaded at 'petsc-external-$PETSC' dir"; exit 1; }
  #   unset _VARNAME
  # done

  cd "$SOURCE_DIR/petsc-$PETSC/"

  export PETSC_DIR="$SOURCE_DIR/petsc-$PETSC/"
  export PETSC_ARCH="sunway-opt"

  rm -rf "$SOURCE_DIR/petsc-$PETSC/$PETSC_ARCH/"
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
    --with-fortran-interfaces=1                                     \
    --with-packages-dir="$SOURCE_DIR/petsc-external-$PETSC"         \
    FFLAGS=-OPT:IEEE-arith=1                                        \
    CFLAGS=-OPT:IEEE-arith=1                                                   2>&1 | tee "$LOG_DIR/petsc-$PETSC.conf.log"
  bsub -I -q q_sw_expr -n 1 ./conftest-$PETSC_ARCH                             2>&1 | tee "$LOG_DIR/petsc-$PETSC.conftest.log"
  python "reconfigure-$PETSC_ARCH.py"                                          2>&1 | tee "$LOG_DIR/petsc-$PETSC.reconf.log"
  make test                                                                    2>&1 | tee "$LOG_DIR/petsc-$PETSC.make_test.log"
  make all                                                                     2>&1 | tee "$LOG_DIR/petsc-$PETSC.make_all.log"
  make install                                                                 2>&1 | tee "$LOG_DIR/petsc-$PETSC.inst.log"

  # Test example
  # make -C "$PETSC_DIR/src/ts/examples/tutorials/" ex2
  # bsub -I -b -q q_sw_expr -share_size 4096 -host_stack 2048 -n 4 -cgsp 64 "$PETSC_DIR/src/ts/examples/tutorials/ex2" -ts_max_steps

  unset PETSC_ARCH
  unset PETSC_DIR
fi
cat "$MOD_IN_DIR/petsc.in" | mo > "$MOD_GL_DIR/petsc-$PETSC"
