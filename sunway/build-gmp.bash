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

# GMP
BASE_DIR="$INSTALL_DIR/gmp-$GMP"
if [ ! -d "$BASE_DIR" ]; then
  echo "------------------------------Build gmp-$GMP------------------------------"

  cd "$SOURCE_DIR/"
  _FILE="gmp-$GMP.tar"
  __DIR="${_FILE%.tar}"
  rm -rf "$__DIR" && mkdir -p "$__DIR" && tar xf "$_FILE" -C "$__DIR" --strip-components=1

  cd "$SOURCE_DIR/gmp-$GMP/"
  ./configure                               \
    --prefix="$BASE_DIR"                    \
    --host=alpha                            \
    --enable-assembly=no                                                       2>&1 | tee "$LOG_DIR/gmp-$GMP.conf.log"

  # Fix sunway compiler doesn't have -Wextra issue
  # for _MAKEFILE in $(find . -iname 'Makefile'); do
  #   sed -i 's/-Wextra//g' "$_MAKEFILE"
  # done

  make -j$(nproc)                                                              2>&1 | tee "$LOG_DIR/gmp-$GMP.build.log"
  make install                                                                 2>&1 | tee "$LOG_DIR/lzma-$LZMA.inst.log"

  unset __DIR
  unset _FILE
fi
