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

# UDUnits
BASE_DIR="$INSTALL_DIR/udunits-$UDUNITS"
if [ ! -d "$BASE_DIR" ]; then
  echo "------------------------------Build udunits-$UDUNITS------------------------------"

  cd "$SOURCE_DIR/"
  _FILE="udunits-$UDUNITS.tar.gz"
  __DIR="${_FILE%.tar.gz}"
  rm -rf "$__DIR" && mkdir -p "$__DIR" && tar xzf "$_FILE" -C "$__DIR" --strip-components=1

  cd "$SOURCE_DIR/udunits-$UDUNITS/"
  ./configure                               \
    --prefix="$BASE_DIR"                    \
    --target=sunway_64-linux-gnu            \
    --host=alpha                            \
    --enable-shared=no --enable-static=yes  \
                                                                               2>&1 | tee "$LOG_DIR/udunits-$UDUNITS.conf.log"
  make -j$(nproc)                                                              2>&1 | tee "$LOG_DIR/udunits-$UDUNITS.build.log"
  make install                                                                 2>&1 | tee "$LOG_DIR/udunits-$UDUNITS.inst.log"

  unset __DIR
  unset _FILE
fi
