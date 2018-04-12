#!/bin/bash

# Hack the CC, CXX, FC
CC='/usr/sw-mpp/bin/sw5cc'
CXX='/usr/sw-mpp/bin/sw5CC'
FC='/usr/sw-mpp/bin/sw5f90'

mkdir -p "$INSTALL_DIR/cc_hack/"
for COMPILER in CC CXX FC; do
  for MODE in host slave hybrid; do

cat > "$INSTALL_DIR/cc_hack/$COMPILER_$MODE" <<EOHD
  ${!COMPILER} -$MODE "\$@"
EOHD

  done
done

export CC="$INSTALL_DIR/cc_hack/CC_HOST"
export CXX="$INSTALL_DIR/cc_hack/CXX_HOST"
export FC="$INSTALL_DIR/cc_hack/FC_HOST"
export AR='/usr/sw-mpp/bin/sw5ar'
export RANLIB='/usr/sw-mpp/bin/sw5ranlib'
