#!/bin/bash

# TCL
BASE_DIR="$INSTALL_DIR/tcl-$TCL-x86_64"
if [ ! -d "$BASE_DIR" ]; then
  echo "------------------------------Build TCL-$TCL for HOST------------------------------"

  cd "$SOURCE_DIR/tcl-$TCL/unix/"
  ./configure                    \
    --prefix="$BASE_DIR"                                                       2>&1 | tee "$LOG_DIR/tcl-$TCL-host.conf.log"
  make -j$(nproc) install                                                      2>&1 | tee "$LOG_DIR/tcl-$TCL-host.build.log"
fi

# Setup TCL environment
TCL_MAJOR_MINOR=${TCL%.*}
ln -sf "$BASE_DIR/bin/tclsh$TCL_MAJOR_MINOR" "$BASE_DIR/bin/tclsh" 2>&1

export PATH="$BASE_DIR/bin/${PATH:+:$PATH}"
export C_INCLUDE_PATH="$BASE_DIR/include/${C_INCLUDE_PATH:+:$C_INCLUDE_PATH}"
export CPLUS_INCLUDE_PATH="$BASE_DIR/include/${CPLUS_INCLUDE_PATH:+:$CPLUS_INCLUDE_PATH}"
export LD_LIBRARY_PATH="$BASE_DIR/lib/${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export MANPATH="$BASE_DIR/man/${MANPATH:+:$MANPATH}"
