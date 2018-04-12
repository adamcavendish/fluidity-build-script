#!/bin/bash

# TCL
BASE_DIR="$INSTALL_DIR/tcl-$TCL"
if [ ! -d "$BASE_DIR" ]; then
  echo "------------------------------Build TCL-$TCL for Sunway------------------------------"

  cd "$SOURCE_DIR/tcl-$TCL/unix/"
  ./configure                    \
    --prefix="$BASE_DIR"         \
    --target=sunway_64-linux-gnu \
    --host=alpha                                                               2>&1 | tee "$LOG_DIR/tcl-$TCL.conf.log"
  make -j$(nproc) install                                                      2>&1 | tee "$LOG_DIR/tcl-$TCL.build.log"
fi

# Setup TCL environment
TCL_MAJOR_MINOR=${TCL%.*}
ln -sf "$BASE_DIR/bin/tclsh$TCL_MAJOR_MINOR" "$BASE_DIR/bin/tclsh" 2>&1
