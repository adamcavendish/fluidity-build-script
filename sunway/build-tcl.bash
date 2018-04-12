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

# TCL
BASE_DIR="$INSTALL_DIR/tcl-$TCL/"
if [ ! -d "$BASE_DIR" ]; then
  echo "------------------------------Build TCL-$TCL for Sunway------------------------------"

  cd "$SOURCE_DIR/"
  _FILE="tcl-$TCL.tar.gz"
  __DIR="${_FILE%.tar.gz}"
  rm -rf "$__DIR" && mkdir -p "$__DIR" && tar xzf "$_FILE" -C "$__DIR" --strip-components=1

  cd "$SOURCE_DIR/tcl-$TCL/unix/"
  ./configure                    \
    --prefix="$BASE_DIR"         \
    --target=sunway_64-linux-gnu \
    --host=alpha                                                               2>&1 | tee "$LOG_DIR/tcl-$TCL.conf.log"
  make                                                                         2>&1 | tee "$LOG_DIR/tcl-$TCL.build.log"
  make install                                                                 2>&1 | tee "$LOG_DIR/tcl-$TCL.inst.log"

  unset __DIR
  unset _FILE
fi

# Setup TCL environment
TCL_MAJOR_MINOR=${TCL%.*}
ln -sf "$BASE_DIR/bin/tclsh$TCL_MAJOR_MINOR" "$BASE_DIR/bin/tclsh" 2>&1
