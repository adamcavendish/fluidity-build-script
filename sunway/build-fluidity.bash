#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/setup.bash"

# Add Sunway compiler tools PATH
export PATH="/usr/sw-mpp/bin/:$PATH"

export CC='/usr/sw-mpp/bin/mpicc'
export CXX='/usr/sw-mpp/bin/mpiCC'
export F77='/usr/sw-mpp/bin/mpif90'
export FC='/usr/sw-mpp/bin/mpif90'
export MPICC='/usr/sw-mpp/bin/mpicc'
export MPICXX='/usr/sw-mpp/bin/mpiCC'
export MPIF77='/usr/sw-mpp/bin/mpif90'
export MPIF90='/usr/sw-mpp/bin/mpif90'
export AR='/usr/sw-mpp/bin/sw5ar'
export RANLIB='/usr/sw-mpp/bin/sw5ranlib'

export C_INCLUDE_PATH="$INSTALL_DIR/udunits-$UDUNITS/include/${C_INCLUDE_PATH:+:$C_INCLUDE_PATH}"
export CPLUS_INCLUDE_PATH="$INSTALL_DIR/udunits-$UDUNITS/include/${CPLUS_INCLUDE_PATH:+:$CPLUS_INCLUDE_PATH}"
export LD_LIBRARY_PATH="$INSTALL_DIR/udunits-$GMP/lib/${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

export PETSC_DIR="$INSTALL_DIR/petsc-$PETSC/"

# Fluidity
BASE_DIR="$INSTALL_DIR/fluidity-$FLUIDITY/"
if [ ! -d "$BASE_DIR" ]; then
  echo "------------------------------Build fluidity-$FLUIDITY------------------------------"

  cd "$SOURCE_DIR/"
  _FILE="fluidity-$FLUIDITY.tar.gz"
  __DIR="${_FILE%.tar.gz}"
  rm -rf "$__DIR" && mkdir -p "$__DIR" && tar xzf "$_FILE" -C "$__DIR" --strip-components=1

  cd "$SOURCE_DIR/fluidity-$FLUIDITY/"

  # Remove fortran compiler .mod flags checking
  sed -i '{
/# How to specify where .mod files are placed./i \
# Specify where .mod files are placed on Sunway\
MOD_FLAG="-J"
;
/# How to specify where .mod files are placed./,/fi/d
;
}' configure

  # Manually set compiler to gfortran
  sed -i 's/fcompiler=`basename $F77`/fcompiler="gfortran"/g' configure

  # Manually set MPI to yes
  sed -i '/if test "$mpi" = "yes" ; then/i mpi="yes"' configure

  # Manually set the flag to compile .F, .F90 files to none
  sed -i '/if test "x$ac_cv_fc_srcext_f90" = xunknown; then/i ac_cv_fc_srcext_f90="none"' configure
  sed -i '/if test "x$ac_cv_fc_srcext_f" = xunknown; then/i ac_cv_fc_srcext_f="none"' configure

  # Configure libadaptivity
  cd "$SOURCE_DIR/fluidity-$FLUIDITY/libadaptivity/"
  ./configure --host=alpha --enable-shared=no --enable-vtk=no --with-blas=-lxMath_manycore --with-lapack=-lxMath_manycore FORTRAN_REAL_8='-r8'
  cd "$SOURCE_DIR/fluidity-$FLUIDITY/"

  # Configure libjudy
  cd "$SOURCE_DIR/fluidity-$FLUIDITY/libjudy/"
  ./configure --prefix="$SOURCE_DIR/fluidity-$FLUIDITY" --host=alpha --enable-shared=no
  cd "$SOURCE_DIR/fluidity-$FLUIDITY/"

  # Configure libspud
  cd "$SOURCE_DIR/fluidity-$FLUIDITY/libspud/"
  ./configure --prefix="$SOURCE_DIR/fluidity-$FLUIDITY" --host=alpha --enable-shared=no
  cd "$SOURCE_DIR/fluidity-$FLUIDITY/"

  # Configure spatialindex
  cd "$SOURCE_DIR/fluidity-$FLUIDITY/spatialindex-1.8.0/"
  ./configure --prefix="$SOURCE_DIR/fluidity-$FLUIDITY" --host=alpha --enable-shared=no --without-pic --disable-maintainer-mode CPPFLAGS=-D_GNU_SOURCE
  cd "$SOURCE_DIR/fluidity-$FLUIDITY/"

  ./configure                                           \
    --prefix="$BASE_DIR"                                \
    --host=alpha                                        \
    --enable-shared=no                                  \
    --enable-python=no                                  \
    --enable-vtk=no                                     \
    # --enable-2d-adaptivity=no                           \
    # --enable-mba3d=no                                   \
    --enable-sam=yes                                    \
    --with-arpack-lib="$INSTALL_DIR/arpack-$ARPACK/"    \
    --with-blas=-lxMath_manycore                        \
    --with-lapack=-lxMath_manycore                      \
    FORTRAN_REAL_8='-r8'                                \
                                                                               2>&1 | tee "$LOG_DIR/fluidity-$FLUIDITY.conf.log"

  make -j$(nproc) all                                                          2>&1 | tee "$LOG_DIR/fluidity-$FLUIDITY.build.log"
fi

