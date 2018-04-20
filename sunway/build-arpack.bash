#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/setup.bash"

# Add Sunway compiler tools PATH
export PATH="/usr/sw-mpp/bin/:$PATH"

export CC='/usr/sw-mpp/bin/mpicc'
export CXX='/usr/sw-mpp/bin/mpiCC'
export FC='/usr/sw-mpp/bin/mpif90'
export F77='/usr/sw-mpp/bin/mpif90'
export MPIF77='/usr/sw-mpp/bin/mpif90'
export AR='/usr/sw-mpp/bin/sw5ar'
export RANLIB='/usr/sw-mpp/bin/sw5ranlib'

# ARPACK
BASE_DIR="$INSTALL_DIR/arpack-ng-$ARPACK"
if [ ! -d "$BASE_DIR" ]; then
  echo "------------------------------Build ARPACK-$ARPACK------------------------------"

  cd "$SOURCE_DIR/"
  _FILE="arpack-ng-$ARPACK.bootstraped.tar.gz"
  __DIR="${_FILE%.tar.gz}"
  rm -rf "$__DIR" && mkdir -p "$__DIR" && tar xzf "$_FILE" -C "$__DIR" --strip-components=1

  cd "$SOURCE_DIR/arpack-ng-$ARPACK/"
  ./configure                               \
    --prefix="$BASE_DIR"                    \
    --host=alpha                            \
    --enable-shared=no --enable-static=yes  \
    --with-blas=-lxMath_manycore            \
    --with-lapack=-lxMath_manycore          \
                                                                               2>&1 | tee "$LOG_DIR/arpack-$ARPACK.conf.log"
  make -j$(nproc)                                                              2>&1 | tee "$LOG_DIR/arpack-$ARPACK.build.log"
  make install                                                                 2>&1 | tee "$LOG_DIR/arpack-$ARPACK.inst.log"

  unset __DIR
  unset _FILE
fi
