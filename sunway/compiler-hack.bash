#!/bin/bash

# Hack the CC, CXX, FC
CC='/usr/sw-mpp/bin/sw5cc'
CXX='/usr/sw-mpp/bin/sw5CC'
FC='/usr/sw-mpp/bin/sw5f90'

mkdir -p "$INSTALL_DIR/cc_hack/"
for COMPILER in CC CXX FC; do
  for MODE in host slave hybrid; do

    _FILE="$INSTALL_DIR/cc_hack/$COMPILER"_"$MODE"
    cat > "$_FILE" <<EOHD
${!COMPILER} -$MODE "\$@"
EOHD
    chmod +x "$_FILE"
    unset _FILE

  done
done

# export CC="$INSTALL_DIR/cc_hack/CC_host"
# export CXX="$INSTALL_DIR/cc_hack/CXX_host"
# export FC="$INSTALL_DIR/cc_hack/FC_host"
export CC='/usr/sw-mpp/bin/mpicc'
export CXX='/usr/sw-mpp/bin/mpiCC'
export FC='/usr/sw-mpp/bin/mpif90'
export AR='/usr/sw-mpp/bin/sw5ar'
export RANLIB='/usr/sw-mpp/bin/sw5ranlib'
