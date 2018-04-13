#!/bin/bash

if [ -z "$INSTALL_DIR" ]; then
  echo "You must source setup scripts!"
  exit 1
fi

export PATH="$INSTALL_DIR/autoconf-$AUTOCONF-host/bin/:$PATH"
