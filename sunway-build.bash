#!/bin/bash

# SCRIPT_DIR: Current Script's Absolute Directory PATH
# SOURCE_DIR: Source code PATH
# INSTALL_DIR: Softwares are installed in this PATH
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

mkdir -p "$SCRIPT_DIR/../source/"
mkdir -p "$SCRIPT_DIR/../install/"
mkdir -p "$SCRIPT_DIR/../log/"

SOURCE_DIR="$( cd "$SCRIPT_DIR/../source/" && pwd )"
INSTALL_DIR="$( cd "$SCRIPT_DIR/../install/" && pwd )"
LOG_DIR="$(cd "$SCRIPT_DIR/../log/" && pwd )"
MOD_IN_DIR="$( cd "$SCRIPT_DIR/modulefiles/" && pwd )"
MOD_GL_DIR="$INSTALL_DIR/modulefiles/"

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

# Add Sunway compiler tools PATH
export PATH="/usr/sw-mpp/bin/:$PATH"

# Build TCL and Modules for HOST machine
source "$SCRIPT_DIR/sunway/build-tcl.host.bash"
source "$SCRIPT_DIR/sunway/build-modules.host.bash"

# Hack the compilers
source "$SCRIPT_DIR/sunway/compiler-hack.bash"

# Build TCL and Modules for Sunway
source "$SCRIPT_DIR/sunway/build-tcl.bash"
source "$SCRIPT_DIR/sunway/build-modules.bash"

# Build PETSc
source "$SCRIPT_DIR/sunway/build-petsc.bash"

exit 0

# UDUnits
BASE_DIR="$INSTALL_DIR/udunits-$UDUNITS/"
if [ ! -d "$BASE_DIR" ]; then
  echo "------------------------------Build udunits-$UDUNITS------------------------------"

  cd "$SOURCE_DIR/udunits-$UDUNITS/"

  CPPFLAGS=-Df2cFortran ./configure --prefix="$BASE_DIR"                       2>&1 | tee "$LOG_DIR/udunits-$UDUNITS.conf.log"
  make -j$(nproc) install                                                      2>&1 | tee "$LOG_DIR/udunits-$UDUNITS.build.log"
fi
cat "$MOD_IN_DIR/udunits.in" | mo > "$MOD_GL_DIR/udunits-$UDUNITS"

# VTK
BASE_DIR="$INSTALL_DIR/vtk-$VTK/"
if [ ! -d "$BASE_DIR" ]; then
  echo "------------------------------Build vtk-$VTK------------------------------"

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
fi
cat "$MOD_IN_DIR/vtk.in" | mo > "$MOD_GL_DIR/vtk-$VTK"

# GMSH
BASE_DIR="$INSTALL_DIR/gmsh-$GMSH/"
if [ ! -d "$BASE_DIR" ]; then
  echo "------------------------------Build gmsh-$GMSH------------------------------"

  mkdir -p "$SOURCE_DIR/gmsh-$GMSH-build/"
  cd "$SOURCE_DIR/gmsh-$GMSH-build/"

  cmake                                \
    -DCMAKE_INSTALL_PREFIX="$BASE_DIR" \
    "$SOURCE_DIR/gmsh-$GMSH/"                                                  2>&1 | tee "$LOG_DIR/gmsh-$GMSH.conf.log"
  make -j$(nproc) install                                                      2>&1 | tee "$LOG_DIR/gmsh-$GMSH.conf.log"
fi
cat "$MOD_IN_DIR/gmsh.in" | mo > "$MOD_GL_DIR/gmsh-$GMSH"

# Fluidity
BASE_DIR="$INSTALL_DIR/fluidity-$FLUIDITY/"
if [ ! -d "$BASE_DIR" ]; then
  echo "------------------------------Build fluidity-$FLUIDITY------------------------------"

  cd "$SOURCE_DIR/fluidity-$FLUIDITY/"

  ./configure                                           \
    --prefix="$BASE_DIR"                                \
    --enable-2d-adaptivity                              \
    --enable-mba3d                                      \
    --with-blas="$INSTALL_DIR/blas-$BLAS/lib/libblas.a" \
    --with-lapack="$INSTALL_DIR/lapack-$LAPACK/lib/liblapack.a"                2>&1 | tee "$LOG_DIR/fluidity-$FLUIDITY.conf.log"
  make -j$(nproc) all                                                          2>&1 | tee "$LOG_DIR/fluidity-$FLUIDITY.build.log"
fi
cat "$MOD_IN_DIR/fluidity.in" | mo > "$MOD_GL_DIR/fluidity-$FLUIDITY"

# Spud
BASE_DIR="$INSTALL_DIR/spud-$SPUD/"
if [ ! -d "$BASE_DIR" ]; then
  echo "------------------------------Build spud-$SPUD------------------------------"

  cd "$SOURCE_DIR/spud-$SPUD/"

  ./configure --prefix="$BASE_DIR"                                             2>&1 | tee "$LOG_DIR/spud-$SPUD.conf.log"
  make -j$(nproc) install                                                      2>&1 | tee "$LOG_DIR/spud-$SPUD.build.log"
fi
cat "$MOD_IN_DIR/spud.in" | mo > "$MOD_GL_DIR/spud-$SPUD"
