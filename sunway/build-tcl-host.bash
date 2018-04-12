#!/bin/bash

# TCL
BASE_DIR="$INSTALL_DIR/tcl-$TCL-host/"
if [ ! -d "$BASE_DIR" ]; then
  echo "------------------------------Build TCL-$TCL for HOST------------------------------"

  cd "$SOURCE_DIR/"
  _FILE="tcl-$TCL.tar.gz"
  __DIR="${_FILE%.tar.gz}-host"
  rm -rf "$__DIR" && mkdir -p "$__DIR" && tar xzf "$_FILE" -C "$__DIR" --strip-components=1

  cd "$SOURCE_DIR/tcl-$TCL-host/unix/"
  ./configure             \
    --prefix="$BASE_DIR"                                                       2>&1 | tee "$LOG_DIR/tcl-$TCL-host.conf.log"
  make -j$(nproc) install                                                      2>&1 | tee "$LOG_DIR/tcl-$TCL-host.build.log"

  unset __DIR
  unset _FILE
fi

# Setup TCL environment
TCL_MAJOR_MINOR=${TCL%.*}
ln -sf "$BASE_DIR/bin/tclsh$TCL_MAJOR_MINOR" "$BASE_DIR/bin/tclsh" 2>&1
