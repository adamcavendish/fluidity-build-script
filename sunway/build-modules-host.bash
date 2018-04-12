#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/setup.bash"

# Modules
BASE_DIR="$INSTALL_DIR/modules-$MODULES-host/"
if [ ! -d "$BASE_DIR" ]; then
  echo "------------------------------Build Modules-$MODULES for HOST------------------------------"

  cd "$SOURCE_DIR/"
  _FILE="modules-$MODULES.tar.gz"
  __DIR="${_FILE%.tar.gz}-host"
  rm -rf "$__DIR" && mkdir -p "$__DIR" && tar xzf "$_FILE" -C "$__DIR" --strip-components=1

  cd "$SOURCE_DIR/modules-$MODULES-host/"
  ./configure                                      \
    --prefix="$BASE_DIR"                           \
    --with-tcl="$INSTALL_DIR/tcl-$TCL-host/lib/"                               2>&1 | tee "$LOG_DIR/modules-$MODULES-host.conf.log"
  make -j$(nproc) install                                                      2>&1 | tee "$LOG_DIR/modules-$MODULES-host.build.log"

  unset __DIR
  unset _FILE
fi
