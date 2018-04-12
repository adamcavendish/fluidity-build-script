#!/bin/bash

# Modules
BASE_DIR="$INSTALL_DIR/modules-$MODULES/"
if [ ! -d "$BASE_DIR" ]; then
  echo "------------------------------Build Modules-$MODULES for Sunway------------------------------"

  cd "$SOURCE_DIR/"
  _FILE="modules-$MODULES.tar.gz"
  __DIR="${_FILE%.tar.gz}"
  rm -rf "$__DIR" && mkdir -p "$__DIR" && tar xzf "$_FILE" -C "$__DIR" --strip-components=1

  cd "$SOURCE_DIR/modules-$MODULES"
  ./configure                                      \
    --prefix="$BASE_DIR"                           \
    --target=sunway_64-linux-gnu                   \
    --host=alpha                                   \
    --with-tcl="$INSTALL_DIR/tcl-$TCL/lib/"                                    2>&1 | tee "$LOG_DIR/modules-$MODULES.conf.log"
  make -j$(nproc) install                                                      2>&1 | tee "$LOG_DIR/modules-$MODULES.build.log"

  unset __DIR
  unset _FILE
fi
