#!/bin/bash

# Modules
BASE_DIR="$INSTALL_DIR/modules-$MODULES-host/"
if [ ! -d "$BASE_DIR" ]; then
  echo "------------------------------Build Modules-$MODULES for HOST------------------------------"
  cd "$SOURCE_DIR/modules-$MODULES"
  ./configure                                      \
    --prefix="$BASE_DIR"                           \
    --with-tcl="$INSTALL_DIR/tcl-$TCL-host/lib/"                               2>&1 | tee "$LOG_DIR/modules-$MODULES-host.conf.log"
  make -j$(nproc) install                                                      2>&1 | tee "$LOG_DIR/modules-$MODULES-host.build.log"
fi
