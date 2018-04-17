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
    -DBUILD_SHARED_LIBS=OFF             \
    -DBUILD_TESTING=OFF                 \
    -DVTK_WRAP_PYTHON=OFF               \
    "$SOURCE_DIR/vtk-$VTK/"                                                    2>&1 | tee "$LOG_DIR/vtk-$VTK.conf.log"

  # Fix sunway compiler doesn't have -Wextra issue
  for _MAKEFILE in $(find . -iname 'flags.make' -o -iname 'lint.txt' -o -iname '*.settings'); do
    sed -i 's/-Wextra//g' "$_MAKEFILE"
  done

  make -j$(nproc) install                                                      2>&1 | tee "$LOG_DIR/vtk-$VTK.build.log"

fi
cat "$MOD_IN_DIR/vtk.in" | mo > "$MOD_GL_DIR/vtk-$VTK"
