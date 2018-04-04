#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

mkdir -p "$SCRIPT_DIR/../source/"
SOURCE_DIR="$( cd "$SCRIPT_DIR/../source/" && pwd )"

# Load Software Versions
source "$SCRIPT_DIR/VERSIONS"

cd "$SOURCE_DIR"

# GSRC: GNU Source Release Collection
__DIR="gsrc"
[ ! -d "$__DIR" ] && { bzr checkout --lightweight bzr://bzr.savannah.gnu.org/gsrc/trunk/ "$__DIR"; }

# Modules
_FILE="modules-$MODULES.tar.gz"
__DIR="modules-$MODULES"
[ ! -f "$_FILE" ] && { wget -O "$_FILE" -c "https://excellmedia.dl.sourceforge.net/project/modules/Modules/modules-$MODULES/modules-$MODULES.tar.gz"; }
[ ! -d "$__DIR" ] && { mkdir "$__DIR" && tar xzf "$_FILE" -C "$__DIR" --strip-components=1; }

# TCL
_FILE="tcl-$TCL.tar.gz"
__DIR="tcl-$TCL"
[ ! -f "$_FILE" ] && { wget -O "$_FILE" -c "https://excellmedia.dl.sourceforge.net/project/tcl/Tcl/$TCL/tcl$TCL-src.tar.gz"; }
[ ! -d "$__DIR" ] && { mkdir "$__DIR" && tar xzf "$_FILE" -C "$__DIR" --strip-components=1; }

# CMake
_FILE="cmake-$CMAKE.tar.gz"
__DIR="cmake-$CMAKE"
CMAKE_MAJOR_MINOR=${CMAKE%.*}
[ ! -f "$_FILE" ] && { wget -O "$_FILE" -c "https://cmake.org/files/v$CMAKE_MAJOR_MINOR/cmake-$CMAKE.tar.gz"; }
[ ! -d "$__DIR" ] && { mkdir "$__DIR" && tar xzf "$_FILE" -C "$__DIR" --strip-components=1; }

# Lzip
_FILE="lzip-$LZIP.tar.gz"
__DIR="lzip-$LZIP"
[ ! -f "$_FILE" ] && { wget -O "$_FILE" -c "http://download.savannah.gnu.org/releases/lzip/lzip-$LZIP.tar.gz"; }
[ ! -d "$__DIR" ] && { mkdir "$__DIR" && tar xzf "$_FILE" -C "$__DIR" --strip-components=1; }

# BLAS
_FILE="blas-$BLAS.tar.gz"
__DIR="blas-$BLAS"
[ ! -f "$_FILE" ] && { wget -O "$_FILE" -c "http://www.netlib.org/blas/blas-$BLAS.tgz"; }
[ ! -d "$__DIR" ] && { mkdir "$__DIR" && tar xzf "$_FILE" -C "$__DIR" --strip-components=1; }

# LAPACK
_FILE="lapack-$LAPACK.tar.gz"
__DIR="lapack-$LAPACK"
[ ! -f "$_FILE" ] && { wget -O "$_FILE" -c "http://www.netlib.org/lapack/lapack-$LAPACK.tar.gz"; }
[ ! -d "$__DIR" ] && { mkdir "$__DIR" && tar xzf "$_FILE" -C "$__DIR" --strip-components=1; }

# OpenMPI
_FILE="openmpi-$OPENMPI.tar.gz"
__DIR="openmpi-$OPENMPI"
OPENMPI_MAJOR_MINOR=${OPENMPI%.*}
[ ! -f "$_FILE" ] && { wget -O "$_FILE" -c "https://www.open-mpi.org/software/ompi/v$OPENMPI_MAJOR_MINOR/downloads/openmpi-$OPENMPI.tar.gz"; }
[ ! -d "$__DIR" ] && { mkdir "$__DIR" && tar xzf "$_FILE" -C "$__DIR" --strip-components=1; }

# HDF5
_FILE="hdf5-$HDF5.tar.gz"
__DIR="hdf5-$HDF5"
[ ! -f "$_FILE" ] && { wget -O "$_FILE" -c "https://support.hdfgroup.org/ftp/HDF5/current/src/hdf5-$HDF5.tar.gz"; }
[ ! -d "$__DIR" ] && { mkdir "$__DIR" && tar xzf "$_FILE" -C "$__DIR" --strip-components=1; }

# PETSc
# _FILE="petsc-$PETSC.tar.gz"
# __DIR="petsc-$PETSC"
# [ ! -f "$_FILE" ] && { wget -O "$_FILE" -c "http://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-$PETSC.tar.gz"; }
# [ ! -d "$__DIR" ] && { mkdir "$__DIR" && tar xzf "$_FILE" -C "$__DIR" --strip-components=1; }
# @FIXME PETSc's official TAR ball is missing maint directory
__DIR="petsc-$PETSC"
[ ! -d "$__DIR" ] && { git clone --depth 1 -b "v$PETSC" https://bitbucket.org/petsc/petsc "petsc-$PETSC"; }

# Zoltan
_FILE="zoltan-$ZOLTAN.tar.gz"
__DIR="zoltan-$ZOLTAN"
[ ! -f "$_FILE" ] && { wget -O "$_FILE" -c "http://www.cs.sandia.gov/~kddevin/Zoltan_Distributions/zoltan_distrib_v$ZOLTAN.tar.gz"; }
[ ! -d "$__DIR" ] && { mkdir "$__DIR" && tar xzf "$_FILE" -C "$__DIR" --strip-components=1; }

# UDUnits
_FILE="udunits-$UDUNITS.tar.gz"
__DIR="udunits-$UDUNITS"
[ ! -f "$_FILE" ] && { wget -O "$_FILE" -c "ftp://ftp.unidata.ucar.edu/pub/udunits/udunits-$UDUNITS.tar.gz"; }
[ ! -d "$__DIR" ] && { mkdir "$__DIR" && tar xzf "$_FILE" -C "$__DIR" --strip-components=1; }

# VTK
_FILE="vtk-$VTK.tar.gz"
__DIR="vtk-$VTK"
VTK_MAJOR_MINOR="${VTK%.*}"
[ ! -f "$_FILE" ] && { wget -O "$_FILE" -c "https://www.vtk.org/files/release/$VTK_MAJOR_MINOR/VTK-$VTK.tar.gz"; }
[ ! -d "$__DIR" ] && { mkdir "$__DIR" && tar xzf "$_FILE" -C "$__DIR" --strip-components=1; }

# GMSH
_FILE="gmsh-$GMSH.tar.gz"
__DIR="gmsh-$GMSH"
[ ! -f "$_FILE" ] && { wget -O "$_FILE" -c "http://gmsh.info/src/gmsh-$GMSH-source.tgz"; }
[ ! -d "$__DIR" ] && { mkdir "$__DIR" && tar xzf "$_FILE" -C "$__DIR" --strip-components=1; }

# Fluidity
_FILE="fluidity-$FLUIDITY.tar.gz"
__DIR="fluidity-$FLUIDITY"
[ ! -f "$_FILE" ] && { wget -O "$_FILE" -c "https://github.com/FluidityProject/fluidity/archive/$FLUIDITY.tar.gz"; }
[ ! -d "$__DIR" ] && { mkdir "$__DIR" && tar xzf "$_FILE" -C "$__DIR" --strip-components=1; }

# Spud
_FILE="spud-$SPUD.tar.gz"
__DIR="spud-$SPUD"
[ ! -f "$_FILE" ] && { wget -O "$_FILE" -c "https://github.com/FluidityProject/spud/archive/$SPUD.tar.gz"; }
[ ! -d "$__DIR" ] && { mkdir "$__DIR" && tar xzf "$_FILE" -C "$__DIR" --strip-components=1; }

exit 0
