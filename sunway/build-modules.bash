#!/bin/bash

# Modules
BASE_DIR="$INSTALL_DIR/modules-$MODULES/"
if [ ! -d "$BASE_DIR" ]; then
  echo "------------------------------Build Modules-$MODULES for Sunway------------------------------"
  cd "$SOURCE_DIR/modules-$MODULES"
  ./configure                                      \
    --prefix="$BASE_DIR"                           \
    --with-tcl="$INSTALL_DIR/tcl-$TCL/lib/"                                    2>&1 | tee "$LOG_DIR/modules-$MODULES.conf.log"
  make -j$(nproc) install                                                      2>&1 | tee "$LOG_DIR/modules-$MODULES.build.log"
fi
