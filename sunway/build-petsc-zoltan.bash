#!/bin/bash

# PETSc and Zoltan
BASE_DIR="$INSTALL_DIR/petsc-$PETSC/"
if [ ! -d "$BASE_DIR" ]; then
  # PETSc
  echo "------------------------------Build petsc-$PETSC------------------------------"

  # Check PETSc External Packages Dir
  if [ ! -d "$SOURCE_DIR/petsc-external-$PETSC/" ]; then
    echo "PETSc External Packages Directory Does Not Exist!"
    exit 1
  fi

  cd "$SOURCE_DIR/petsc-$PETSC/"

  export PETSC_DIR="$SOURCE_DIR/petsc-$PETSC/"
  export PETSC_ARCH="linux-gnu-c-opt"

  rm -rf "$SOURCE_DIR/petsc-$PETSC/$PETSC_ARCH/"
  ./configure                                                       \
    --prefix="$BASE_DIR"                                            \
    --with-cc='mpicc'                                               \
    --with-cxx='mpiCC'                                              \
    --with-fc='mpif90'                                              \
    --known-mpi-shared-libraries=0                                  \
    --with-single-library=1                                         \
    --with-packages-dir="$SOURCE_DIR/petsc-external-$PETSC"         \
    --PETSC_ARCH="$PETSC_ARCH"                                      \
    --download-hypre=1                                              \
    --download-metis=1                                              \
    --download-parmetis=1                                           \
    --download-ml=1                                                 \
    --download-mumps=1                                              \
    --download-sowing=1                                             \
    --download-triangle=1                                           \
    --download-ptscotch=1                                           \
    --download-suitesparse=1                                        \
    --download-ctetgen=1                                            \
    --download-chaco=1                                              \
    --download-scalapack=1                                          \
    --download-blacs=1                                              \
    --with-blas-lib="$INSTALL_DIR/blas-$BLAS/lib/libblas.a"         \
    --with-lapack-lib="$INSTALL_DIR/lapack-$LAPACK/lib/liblapack.a" \
    --with-mpi-dir="$INSTALL_DIR/openmpi-$OPENMPI/"                 \
    --with-hdf5=1                                                   \
    --with-hdf5-dir="$INSTALL_DIR/hdf5-$HDF5/"                      \
    --with-shared-libraries=0                                       \
    --with-debugging=0                                              \
    --with-fortran-interfaces=1                                                2>&1 | tee "$LOG_DIR/petsc-$PETSC.conf.log"
  make all                                                                     2>&1 | tee "$LOG_DIR/petsc-$PETSC.build.log"
  make install                                                                 2>&1 | tee "$LOG_DIR/petsc-$PETSC.inst.log"

  unset PETSC_ARCH
  unset PETSC_DIR

  # Zoltan
  # -- Zoltan should be installed in PETSC_HOME --
  echo "------------------------------Build zoltan-$ZOLTAN------------------------------"
  mkdir -p "$SOURCE_DIR/zoltan-$ZOLTAN-build/"
  cd "$SOURCE_DIR/zoltan-$ZOLTAN-build/"

  "$SOURCE_DIR/zoltan-$ZOLTAN/configure" \
    --prefix="$BASE_DIR"                 \
    --with-mpi-compilers                 \
    --enable-mpi                         \
    --with-parmetis                      \
    --with-parmetis-incdir="$INSTALL_DIR/petsc-$PETSC/include/" \
    --with-parmetis-libdir="$INSTALL_DIR/petsc-$PETSC/lib/"     \
    --with-scotch                        \
    --with-scotch-incdir="$INSTALL_DIR/petsc-$PETSC/include/" \
    --with-scotch-libdir="$INSTALL_DIR/petsc-$PETSC/lib/"     \
    --enable-f90interface                \
    --disable-examples                   \
    --enable-zoltan-cppdriver                                                  2>&1 | tee "$LOG_DIR/zoltan-$ZOLTAN.conf.log"
  make -j$(nproc) install                                                      2>&1 | tee "$LOG_DIR/zoltan-$ZOLTAN.build.log"
fi
cat "$MOD_IN_DIR/petsc.in" | mo > "$MOD_GL_DIR/petsc-$PETSC"
