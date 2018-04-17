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

# XML2
BASE_DIR="$INSTALL_DIR/libxml2-$XML2"
if [ ! -d "$BASE_DIR" ]; then
  echo "------------------------------Build XML2-$XML2------------------------------"

  cd "$SOURCE_DIR/"
  _FILE="libxml2-$XML2.tar.gz"
  __DIR="${_FILE%.tar.gz}"
  rm -rf "$__DIR" && mkdir -p "$__DIR" && tar xzf "$_FILE" -C "$__DIR" --strip-components=1

  cd "$SOURCE_DIR/libxml2-$XML2/"
  ./configure                               \
    --prefix="$BASE_DIR"                    \
    --target=sunway_64-linux-gnu            \
    --host=alpha                            \
    --with-python=no                        \
    --with-lzma="$INSTALL_DIR/lzma-$LZMA/"  \
    --enable-shared=no --enable-static=yes  \
    LZMA_LIBS=-L"$INSTALL_DIR/lzma-$LZMA/lib -llzma -static"                   2>&1 | tee "$LOG_DIR/libxml2-$XML2.conf.log"

  # Fix sunway compiler doesn't have -Wno-array-bounds, -Wextra issue
  for _MAKEFILE in $(find . -iname 'Makefile'); do
    sed -i 's/-Wno-array-bounds//g' "$_MAKEFILE"
    sed -i 's/-Wextra//g'           "$_MAKEFILE"
  done

  make -j$(nproc)                                                              2>&1 | tee "$LOG_DIR/libxml2-$XML2.build.log"
  make install                                                                 2>&1 | tee "$LOG_DIR/libxml2-$XML2.inst.log"

  unset __DIR
  unset _FILE
fi
