#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/setup.bash"

# Autoconf
BASE_DIR="$INSTALL_DIR/autoconf-$AUTOCONF-host/"
if [ ! -d "$BASE_DIR" ]; then
  echo "------------------------------Build autoconf-$AUTOCONF for HOST------------------------------"

  cd "$SOURCE_DIR/"
  _FILE="autoconf-$AUTOCONF.tar.gz"
  __DIR="${_FILE%.tar.gz}-host"
  rm -rf "$__DIR" && mkdir -p "$__DIR" && tar xzf "$_FILE" -C "$__DIR" --strip-components=1

  cd "$SOURCE_DIR/autoconf-$AUTOCONF-host/"
  ./configure             \
    --prefix="$BASE_DIR"                                                       2>&1 | tee "$LOG_DIR/autoconf-$AUTOCONF-host.conf.log"
  make                                                                         2>&1 | tee "$LOG_DIR/autoconf-$AUTOCONF-host.build.log"
  make install                                                                 2>&1 | tee "$LOG_DIR/autoconf-$AUTOCONF-host.inst.log"

  unset __DIR
  unset _FILE
fi
