#!/bin/bash

# SCRIPT_DIR: Current Script's Absolute Directory PATH
# SOURCE_DIR: Source code PATH
# INSTALL_DIR: Softwares are installed in this PATH
# MOD_IN_DIR: The modulefile template files PATH
# MOD_GL_DIR: The global modulefiles PATH installed for current user
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

mkdir -p "$SCRIPT_DIR/../../source/"
mkdir -p "$SCRIPT_DIR/../../install/"
mkdir -p "$SCRIPT_DIR/../../log/"

SOURCE_DIR="$( cd "$SCRIPT_DIR/../../source/" && pwd )"
INSTALL_DIR="$( cd "$SCRIPT_DIR/../../install/" && pwd )"
LOG_DIR="$(cd "$SCRIPT_DIR/../../log/" && pwd )"
MOD_IN_DIR="$( cd "$SCRIPT_DIR/modulefiles/" && pwd )"
MOD_GL_DIR="$INSTALL_DIR/modulefiles/"

PYTHON_VERSION="$(python --version 2>&1)"
PYTHON_MAJOR_MINOR="$(echo "$PYTHON_VERSION" | awk '{ gsub(/\.[0-9]+$/,"",$2); print $2 }')"

# Load Software Versions
source "$SCRIPT_DIR/VERSIONS"
# Load Mustache Template Engine
source "$SCRIPT_DIR/mo"

# Cleanup Environmental Variables
export PATH='/usr/bin/:/usr/sbin/:/bin/:/sbin/'
unset CPATH C_INCLUDE_PATH CPLUS_INCLUDE_PATH INCLUDE
unset LD_LIBRARY_PATH LIBRARY_PATH
unset PKG_CONFIG_PATH
