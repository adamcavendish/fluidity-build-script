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

export C_INCLUDE_PATH="$INSTALL_PATH/gmp-$GMP/include/${C_INCLUDE_PATH:+:$C_INCLUDE_PATH}"
export CPLUS_INCLUDE_PATH="$INSTALL_PATH/gmp-$GMP/include/${CPLUS_INCLUDE_PATH:+:$CPLUS_INCLUDE_PATH}"
export LD_LIBRARY_PATH="$INSTALL_PATH/gmp-$GMP/lib/${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

# GMSH
BASE_DIR="$INSTALL_DIR/gmsh-$GMSH/"
if [ ! -d "$BASE_DIR" ]; then
  echo "------------------------------Build gmsh-$GMSH------------------------------"

  cd "$SOURCE_DIR/"
  _FILE="gmsh-$GMSH.tar.gz"
  __DIR="${_FILE%.tar.gz}"
  rm -rf "$__DIR" && mkdir -p "$__DIR" && tar xzf "$_FILE" -C "$__DIR" --strip-components=1

  rm -rf "$SOURCE_DIR/gmsh-$GMSH-build/"
  mkdir -p "$SOURCE_DIR/gmsh-$GMSH-build/"
  cd "$SOURCE_DIR/gmsh-$GMSH-build/"

  cmake                                \
    -DCMAKE_INSTALL_PREFIX="$BASE_DIR" \
    -DCMAKE_BUILD_TYPE=Release         \
    -DBUILD_SHARED_LIBS=OFF            \
    "$SOURCE_DIR/gmsh-$GMSH/"                                                  2>&1 | tee "$LOG_DIR/gmsh-$GMSH.conf.log"
  make -j$(nproc)                                                              2>&1 | tee "$LOG_DIR/gmsh-$GMSH.build.log"
  make install                                                                 2>&1 | tee "$LOG_DIR/gmsh-$GMSH.inst.log"

  unset __DIR
  unset _FILE
fi
cat "$MOD_IN_DIR/gmsh.in" | mo > "$MOD_GL_DIR/gmsh-$GMSH"
