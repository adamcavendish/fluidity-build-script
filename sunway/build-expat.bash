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

# EXPAT
BASE_DIR="$INSTALL_DIR/expat-$EXPAT"
if [ ! -d "$BASE_DIR" ]; then
  echo "------------------------------Build expat-$EXPAT------------------------------"

  cd "$SOURCE_DIR/"
  _FILE="expat-$EXPAT.tar"
  __DIR="${_FILE%.tar}"
  rm -rf "$__DIR" && mkdir -p "$__DIR" && tar xf "$_FILE" -C "$__DIR" --strip-components=1

  cd "$SOURCE_DIR/expat-$EXPAT"
  ./configure                               \
    --prefix="$BASE_DIR"                    \
    --target=sunway_64-linux-gnu            \
    --host=alpha                                                               2>&1 | tee "$LOG_DIR/expat-$EXPAT.conf.log"
  make -j$(nproc)                                                              2>&1 | tee "$LOG_DIR/expat-$EXPAT.build.log"
  make install                                                                 2>&1 | tee "$LOG_DIR/expat-$EXPAT.inst.log"

  unset __DIR
  unset _FILE
fi
