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

# LZMA
BASE_DIR="$INSTALL_DIR/lzma-$LZMA"
if [ ! -d "$BASE_DIR" ]; then
  echo "------------------------------Build lzma-$LZMA------------------------------"

  cd "$SOURCE_DIR/"
  _FILE="lzma-$LZMA.tar.gz"
  __DIR="${_FILE%.tar.gz}"
  rm -rf "$__DIR" && mkdir -p "$__DIR" && tar xzf "$_FILE" -C "$__DIR" --strip-components=1

  cd "$SOURCE_DIR/lzma-$LZMA/"
  ./configure                               \
    --prefix="$BASE_DIR"                    \
    --target=sunway_64-linux-gnu            \
    --host=alpha                                                               2>&1 | tee "$LOG_DIR/lzma-$LZMA.conf.log"

  # Fix sunway compiler doesn't have -Wextra issue
  mv Makefile Makefile.orig
  cat Makefile.orig | sed 's/-Wextra//g' > Makefile

  make -j$(nproc)                                                              2>&1 | tee "$LOG_DIR/lzma-$LZMA.build.log"
  make install                                                                 2>&1 | tee "$LOG_DIR/lzma-$LZMA.inst.log"

  unset __DIR
  unset _FILE
fi
