#!/bin/bash

# SCRIPT_DIR: Current Script's Absolute Directory PATH
# SOURCE_DIR: Source code PATH
# INSTALL_DIR: Softwares are installed in this PATH
# MOD_IN_DIR: The modulefile template files PATH
# MOD_GL_DIR: The global modulefiles PATH installed for current user
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

mkdir -p "$SCRIPT_DIR/../source/"
mkdir -p "$SCRIPT_DIR/../install/"
mkdir -p "$SCRIPT_DIR/../log/"

SOURCE_DIR="$( cd "$SCRIPT_DIR/../source/" && pwd )"
INSTALL_DIR="$( cd "$SCRIPT_DIR/../install/" && pwd )"
LOG_DIR="$(cd "$SCRIPT_DIR/../log/" && pwd )"
MOD_IN_DIR="$( cd "$SCRIPT_DIR/modulefiles/" && pwd )"
MOD_GL_DIR="$HOME/privatemodules/"

PYTHON_VERSION="$(python --version 2>&1)"
PYTHON_MAJOR_MINOR="$(echo "$PYTHON_VERSION" | awk '{ gsub(/\.[0-9]+$/,"",$2); print $2 }')"

# Load Software Versions
source "$SCRIPT_DIR/VERSIONS"
# Load Mustache Template Engine
source "$SCRIPT_DIR/mo"

# Cleanup Environmental Variables
export PATH='/usr/bin/:/usr/sbin/:/bin/:/sbin/'
unset CPATH C_INCLUDE_PATH CPLUS_INCLUDE_PATH INCLUDE
unset LD_LIBRARY_PATH LIBRARY_PATH
unset PKG_CONFIG_PATH

# TCL
BASE_DIR="$INSTALL_DIR/tcl-$TCL"
if [ ! -d "$BASE_DIR" ]; then
  echo "------------------------------Build TCL-$TCL------------------------------"

  cd "$SOURCE_DIR/tcl-$TCL/unix/"
  ./configure --prefix="$BASE_DIR"                                             2>&1 | tee "$LOG_DIR/tcl-$TCL.conf.log"
  make -j$(nproc) install                                                      2>&1 | tee "$LOG_DIR/tcl-$TCL.build.log"
fi

# Setup TCL environment
TCL_MAJOR_MINOR=${TCL%.*}
ln -sf "$BASE_DIR/bin/tclsh$TCL_MAJOR_MINOR" "$BASE_DIR/bin/tclsh" 2>&1

export PATH="$BASE_DIR/bin/${PATH:+:$PATH}"
export C_INCLUDE_PATH="$BASE_DIR/include/${C_INCLUDE_PATH:+:$C_INCLUDE_PATH}"
export CPLUS_INCLUDE_PATH="$BASE_DIR/include/${CPLUS_INCLUDE_PATH:+:$CPLUS_INCLUDE_PATH}"
export LD_LIBRARY_PATH="$BASE_DIR/lib/${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export MANPATH="$BASE_DIR/man/${MANPATH:+:$MANPATH}"

# Modules
BASE_DIR="$INSTALL_DIR/modules-$MODULES/"
if [ ! -d "$BASE_DIR" ]; then
  echo "------------------------------Build Modules-$MODULES------------------------------"
  cd "$SOURCE_DIR/modules-$MODULES"
  ./configure --prefix="$BASE_DIR" --with-tcl="$INSTALL_DIR/tcl-$TCL/lib/"     2>&1 | tee "$LOG_DIR/modules-$MODULES.conf.log"
  make -j$(nproc) install                                                      2>&1 | tee "$LOG_DIR/modules-$MODULES.build.log"
fi

# Setup Modules Environment
. "$INSTALL_DIR/modules-$MODULES/init/bash"
module load use.own

# Lzip
BASE_DIR="$INSTALL_DIR/lzip-$LZIP"
if [ ! -d "$BASE_DIR" ]; then
  echo "------------------------------Build lzip-$LZIP------------------------------"
  cd "$SOURCE_DIR/lzip-$LZIP"
  ./configure --prefix="$BASE_DIR"                                             2>&1 | tee "$LOG_DIR/lzip-$LZIP.conf.log"
  make -j$(nproc) install                                                      2>&1 | tee "$LOG_DIR/lzip-$LZIP.build.log"
fi
cat "$MOD_IN_DIR/lzip.in" | mo > "$MOD_GL_DIR/lzip-$LZIP"

# GSRC: GNU Source Release Collection
#     for gcc, gmp, mpfr, mpc, etc.
BASE_DIR="$INSTALL_DIR/gnu/"
if [ ! -d "$BASE_DIR" ]; then
  echo "------------------------------Build gsrc-$GCC------------------------------"
  module load "lzip-$LZIP"

  # Before building GCC. ENV must be ensured clean.
  unset CPATH C_INCLUDE_PATH CPLUS_INCLUDE_PATH INCLUDE
  unset LD_LIBRARY_PATH LIBRARY_PATH
  unset PKG_CONFIG_PATH

  cd "$SOURCE_DIR/gsrc"
  ./bootstrap                                                                  2>&1 | tee "$LOG_DIR/gsrc-$GCC.bootstrap.log"
  ./configure --prefix="$BASE_DIR"                                             2>&1 | tee "$LOG_DIR/gsrc-$GCC.conf.log"
  . ./setup.sh

  make -C pkg/other/zlib uninstall-pkg                                         2>&1 | tee "$LOG_DIR/gsrc-$GCC-zlib.uinst.log"
  make -C pkg/other/zlib install -j$(nproc)                                    2>&1 | tee "$LOG_DIR/gsrc-$GCC-zlib.build.log"

  make -C pkg/gnu/gmp    uninstall-pkg                                         2>&1 | tee "$LOG_DIR/gsrc-$GCC-gmp.uinst.log"
  make -C pkg/gnu/gmp    install -j$(nproc)                                    2>&1 | tee "$LOG_DIR/gsrc-$GCC-gmp.build.log"

  make -C pkg/gnu/mpfr   uninstall-pkg                                         2>&1 | tee "$LOG_DIR/gsrc-$GCC-mpfr.uinst.log"
  make -C pkg/gnu/mpfr   install -j$(nproc)                                    2>&1 | tee "$LOG_DIR/gsrc-$GCC-mpfr.build.log"

  make -C pkg/gnu/mpc    uninstall-pkg                                         2>&1 | tee "$LOG_DIR/gsrc-$GCC-mpc.uinst.log"
  make -C pkg/gnu/mpc    install -j$(nproc)                                    2>&1 | tee "$LOG_DIR/gsrc-$GCC-mpc.build.log"

  make -C pkg/other/isl  uninstall-pkg                                         2>&1 | tee "$LOG_DIR/gsrc-$GCC-isl.uinst.log"
  make -C pkg/other/isl  install -j$(nproc)                                    2>&1 | tee "$LOG_DIR/gsrc-$GCC-isl.build.log"

  cat "$SCRIPT_DIR/gcc/Makefile.in" | mo > "$SOURCE_DIR/gsrc/pkg/gnu/gcc/Makefile"
  cat "$SCRIPT_DIR/gcc/config.mk.in" | mo > "$SOURCE_DIR/gsrc/pkg/gnu/gcc/config.mk"
  make -C pkg/gnu/gcc    uninstall-pkg                                         2>&1 | tee "$LOG_DIR/gsrc-$GCC-gcc.uinst.log"
  make -C pkg/gnu/gcc    install -j$(nproc)                                    2>&1 | tee "$LOG_DIR/gsrc-$GCC-gcc.build.log"

  make -C pkg/gnu/binutils uninstall-pkg                                       2>&1 | tee "$LOG_DIR/gsrc-$GCC-binutils.uinst.log"
  make -C pkg/gnu/binutils install -j$(nproc)                                  2>&1 | tee "$LOG_DIR/gsrc-$GCC-binutils.build.log"

  module unload "lzip-$LZIP"
fi
cat "$MOD_IN_DIR/gcc.in" | mo > "$MOD_GL_DIR/gcc-$GCC"

# OpenMPI
BASE_DIR="$INSTALL_DIR/openmpi-$OPENMPI/"
if [ ! -d "$BASE_DIR" ]; then
  echo "------------------------------Build openmpi-$OPENMPI------------------------------"
  module load "gcc-$GCC"

  cd "$SOURCE_DIR/openmpi-$OPENMPI/"
  ./configure             \
    --prefix="$BASE_DIR"  \
    --enable-mpi-fortran  \
    --enable-mpi-cxx      \
    --enable-mpi-cxx-seek                                                      2>&1 | tee "$LOG_DIR/openmpi-$OPENMPI.conf.log"
  make -j$(nproc) install                                                      2>&1 | tee "$LOG_DIR/openmpi-$OPENMPI.build.log"

  module unload "gcc-$GCC"
fi
cat "$MOD_IN_DIR/openmpi.in" | mo > "$MOD_GL_DIR/openmpi-$OPENMPI"

# CMake
BASE_DIR="$INSTALL_DIR/cmake-$CMAKE/"
if [ ! -d "$BASE_DIR" ]; then
  echo "------------------------------Build CMake-$CMAKE------------------------------"
  module load "gcc-$GCC"

  cd "$SOURCE_DIR/cmake-$CMAKE/"
  ./bootstrap --prefix="$BASE_DIR"                                             2>&1 | tee "$LOG_DIR/cmake-$CMAKE.conf.log"
  make -j$(nproc)                                                              2>&1 | tee "$LOG_DIR/cmake-$CMAKE.build.log"
  make install                                                                 2>&1 | tee "$LOG_DIR/cmake-$CMAKE.inst.log"

  module unload "gcc-$GCC"
fi
cat "$MOD_IN_DIR/cmake.in" | mo > "$MOD_GL_DIR/cmake-$CMAKE"

# HDF5
BASE_DIR="$INSTALL_DIR/hdf5-$HDF5/"
if [ ! -d "$BASE_DIR" ]; then
  echo "------------------------------Build hdf5-$HDF5------------------------------"
  module load "gcc-$GCC"
  module load "openmpi-$OPENMPI"
  module load "cmake-$CMAKE"

  cd "$SOURCE_DIR/hdf5-$HDF5/"
  CC=mpicc ./configure --prefix="$BASE_DIR" --enable-parallel                  2>&1 | tee "$LOG_DIR/hdf5-$HDF5.conf.log"
  make -j$(nproc) install                                                      2>&1 | tee "$LOG_DIR/hdf5-$HDF5.build.log"

  module unload "cmake-$CMAKE"
  module unload "openmpi-$OPENMPI"
  module unload "gcc-$GCC"
fi
cat "$MOD_IN_DIR/hdf5.in" | mo > "$MOD_GL_DIR/hdf5-$HDF5"

# BLAS
BASE_DIR="$INSTALL_DIR/blas-$BLAS/"
if [ ! -d "$BASE_DIR" ]; then
  echo "------------------------------Build blas-$BLAS------------------------------"
  module load "gcc-$GCC"
  module load "cmake-$CMAKE"

  cd "$SOURCE_DIR/blas-$BLAS/"
  make -j$(nproc)                                                              2>&1 | tee "$LOG_DIR/blas-$BLAS.build.log"

  mkdir -p "$BASE_DIR/lib/"
  cp "$SOURCE_DIR/blas-$BLAS/blas_LINUX.a" "$BASE_DIR/lib/libblas.a"

  module unload "cmake-$CMAKE"
  module unload "gcc-$GCC"
fi
cat "$MOD_IN_DIR/blas.in" | mo > "$MOD_GL_DIR/blas-$BLAS"

# LAPACK
BASE_DIR="$INSTALL_DIR/lapack-$LAPACK/"
if [ ! -d "$BASE_DIR" ]; then
  echo "------------------------------Build lapack-$LAPACK------------------------------"
  module load "gcc-$GCC"
  module load "cmake-$CMAKE"
  module load "blas-$BLAS"

  # LAPACK testing needs quite a lot of stack space
  ulimit -s unlimited

  cd "$SOURCE_DIR/lapack-$LAPACK/"
  cat "make.inc.example" \
    | sed "s/CC     =.*/CC     = gcc -fPIC/"          \
    | sed "s/FORTRAN =.*/FORTRAN = gfortran -fPIC/"   \
    | sed "s/LOADER   =.*/LOADER   = gfortran -fPIC/" \
    | sed "s|BLASLIB      =.*|BLASLIB      = $INSTALL_DIR/blas-$BLAS/libblas.a|" \
    > "make.inc"
  make -j$(nproc)                                                              2>&1 | tee "$LOG_DIR/lapack-$LAPACK.build.log"

  mkdir -p "$BASE_DIR/lib/"
  cp "$SOURCE_DIR/lapack-$LAPACK/liblapack.a" "$BASE_DIR/lib/liblapack.a"

  module unload "blas-$BLAS"
  module unload "cmake-$CMAKE"
  module unload "gcc-$GCC"
fi
cat "$MOD_IN_DIR/lapack.in" | mo > "$MOD_GL_DIR/lapack-$LAPACK"

# PETSc
BASE_DIR="$INSTALL_DIR/petsc-$PETSC/"
if [ ! -d "$BASE_DIR" ]; then
  echo "------------------------------Build petsc-$PETSC------------------------------"
  module load "gcc-$GCC"
  module load "openmpi-$OPENMPI"
  module load "cmake-$CMAKE"
  module load "blas-$BLAS"
  module load "lapack-$LAPACK"

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

  module unload "lapack-$LAPACK"
  module unload "blas-$BLAS"
  module unload "cmake-$CMAKE"
  module unload "openmpi-$OPENMPI"
  module unload "gcc-$GCC"
fi
cat "$MOD_IN_DIR/petsc.in" | mo > "$MOD_GL_DIR/petsc-$PETSC"

# UDUnits
BASE_DIR="$INSTALL_DIR/udunits-$UDUNITS/"
if [ ! -d "$BASE_DIR" ]; then
  echo "------------------------------Build udunits-$UDUNITS------------------------------"

  module load "gcc-$GCC"
  module load "cmake-$CMAKE"

  cd "$SOURCE_DIR/udunits-$UDUNITS/"

  CPPFLAGS=-Df2cFortran ./configure --prefix="$BASE_DIR"                       2>&1 | tee "$LOG_DIR/udunits-$UDUNITS.conf.log"
  make -j$(nproc) install                                                      2>&1 | tee "$LOG_DIR/udunits-$UDUNITS.build.log"

  module unload "cmake-$CMAKE"
  module unload "gcc-$GCC"
fi
cat "$MOD_IN_DIR/udunits.in" | mo > "$MOD_GL_DIR/udunits-$UDUNITS"

# VTK
BASE_DIR="$INSTALL_DIR/vtk-$VTK/"
if [ ! -d "$BASE_DIR" ]; then
  echo "------------------------------Build vtk-$VTK------------------------------"
  module load "gcc-$GCC"
  module load "cmake-$CMAKE"

  mkdir -p "$SOURCE_DIR/vtk-$VTK-build/"
  cd "$SOURCE_DIR/vtk-$VTK-build/"

  cmake                                 \
    -DCMAKE_INSTALL_PREFIX="$BASE_DIR"  \
    -DCMAKE_BUILD_TYPE=Release          \
    -DBUILD_EXAMPLES=OFF                \
    -DBUILD_SHARED_LIBS=ON              \
    -DBUILD_TESTING=OFF                 \
    -DVTK_WRAP_PYTHON=ON                \
    "$SOURCE_DIR/vtk-$VTK/"                                                    2>&1 | tee "$LOG_DIR/vtk-$VTK.conf.log"
  make -j$(nproc) install                                                      2>&1 | tee "$LOG_DIR/vtk-$VTK.build.log"

  module unload "cmake-$CMAKE"
  module unload "gcc-$GCC"
fi
cat "$MOD_IN_DIR/vtk.in" | mo > "$MOD_GL_DIR/vtk-$VTK"

# GMSH
BASE_DIR="$INSTALL_DIR/gmsh-$GMSH/"
if [ ! -d "$BASE_DIR" ]; then
  echo "------------------------------Build gmsh-$GMSH------------------------------"
  module load "gcc-$GCC"
  module load "cmake-$CMAKE"

  mkdir -p "$SOURCE_DIR/gmsh-$GMSH-build/"
  cd "$SOURCE_DIR/gmsh-$GMSH-build/"

  cmake                                \
    -DCMAKE_INSTALL_PREFIX="$BASE_DIR" \
    "$SOURCE_DIR/gmsh-$GMSH/"                                                  2>&1 | tee "$LOG_DIR/gmsh-$GMSH.conf.log"
  make -j$(nproc) install                                                      2>&1 | tee "$LOG_DIR/gmsh-$GMSH.conf.log"

  module unload "cmake-$CMAKE"
  module unload "gcc-$GCC"
fi
cat "$MOD_IN_DIR/gmsh.in" | mo > "$MOD_GL_DIR/gmsh-$GMSH"

# Fluidity
BASE_DIR="$INSTALL_DIR/fluidity-$FLUIDITY/"
if [ ! -d "$BASE_DIR" ]; then
  echo "------------------------------Build fluidity-$FLUIDITY------------------------------"
  module load "gcc-$GCC"
  module load "openmpi-$OPENMPI"
  module load "cmake-$CMAKE"
  module load "blas-$BLAS"
  module load "lapack-$LAPACK"
  module load "udunits-$UDUNITS"
  module load "petsc-$PETSC"
  module load "gmsh-$GMSH"
  module load "vtk-$VTK"

  cd "$SOURCE_DIR/fluidity-$FLUIDITY/"

  ./configure                                           \
    --prefix="$BASE_DIR"                                \
    --enable-2d-adaptivity                              \
    --enable-mba3d                                      \
    --with-blas="$INSTALL_DIR/blas-$BLAS/lib/libblas.a" \
    --with-lapack="$INSTALL_DIR/lapack-$LAPACK/lib/liblapack.a"                2>&1 | tee "$LOG_DIR/fluidity-$FLUIDITY.conf.log"
  make -j$(nproc) all                                                          2>&1 | tee "$LOG_DIR/fluidity-$FLUIDITY.build.log"

  module unload "vtk-$VTK"
  module unload "gmsh-$GMSH"
  module unload "petsc-$PETSC"
  module unload "udunits-$UDUNITS"
  module unload "lapack-$LAPACK"
  module unload "blas-$BLAS"
  module unload "cmake-$CMAKE"
  module unload "openmpi-$OPENMPI"
  module unload "gcc-$GCC"
fi
cat "$MOD_IN_DIR/fluidity.in" | mo > "$MOD_GL_DIR/fluidity-$FLUIDITY"

# Spud
BASE_DIR="$INSTALL_DIR/spud-$SPUD/"
if [ ! -d "$BASE_DIR" ]; then
  echo "------------------------------Build spud-$SPUD------------------------------"
  module load "gcc-$GCC"
  module load "cmake-$CMAKE"

  cd "$SOURCE_DIR/spud-$SPUD/"

  ./configure --prefix="$BASE_DIR"                                             2>&1 | tee "$LOG_DIR/spud-$SPUD.conf.log"
  make -j$(nproc) install                                                      2>&1 | tee "$LOG_DIR/spud-$SPUD.build.log"

  module unload "cmake-$CMAKE"
  module unload "gcc-$GCC"
fi
cat "$MOD_IN_DIR/spud.in" | mo > "$MOD_GL_DIR/spud-$SPUD"
