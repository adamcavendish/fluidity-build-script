#!/bin/bash

# Build TCL and Modules for HOST machine
bash "$SCRIPT_DIR/sunway/build-tcl-host.bash"
bash "$SCRIPT_DIR/sunway/build-modules-host.bash"

# Hack the compilers
# bash "$SCRIPT_DIR/sunway/compiler-hack.bash"

# Build TCL and Modules for Sunway
bash "$SCRIPT_DIR/sunway/build-tcl.bash"
bash "$SCRIPT_DIR/sunway/build-modules.bash"

# Setup Modules Environment
# source "$INSTALL_DIR/modules-$MODULES-host/init/bash"
# module use "$MOD_GL_DIR"

# Build PETSc
bash "$SCRIPT_DIR/sunway/build-petsc.bash"

# Build UDUnits
bash "$SCRIPT_DIR/sunway/build-udunits.bash"

# Build VTK
# bash "$SCRIPT_DIR/sunway/build-vtk.bash"

# Build GMSH
# bash "$SCRIPT_DIR/sunway/build-gmsh.bash"

exit 0

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
