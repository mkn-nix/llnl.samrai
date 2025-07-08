#!/usr/bin/env bash
set -ex
THREADS=${THREADS:-"3"}
CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" && cd $CWD
DIR="samrai"
GIT_URL="https://github.com/llnl/$DIR"
VERSION="develop"
FFF=("include" "lib" "$DIR" "share")
[ ! -z "$MKN_CLEAN" ] && (( $MKN_CLEAN == 1 )) && for f in ${FFF[@]}; do rm -rf $CWD/$f; done
[ ! -d "$CWD/$DIR" ] && git clone --depth 1 $GIT_URL -b $VERSION $DIR --recursive

CMAKE_CONFIG=""
# CMAKE_CXX_FLAGS="-g3 -O0 -fno-omit-frame-pointer"                             # PURE DEBUG
# CMAKE_CXX_FLAGS="-g3 -O3 -march=native -mtune=native -fno-omit-frame-pointer" # OPTIMZ AND DEBUG
CMAKE_CXX_FLAGS="-DNDEBUG -g0 -O3 -march=native -mtune=native"                # SUPER RELEASE
CMAKE_BUILD_TYPE="Release" # or Debug RelWithDebInfo
CMAKE_CONFIG+=" -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} "


(
  [ ! -d "$CWD/silo" ] && git clone https://github.com/LLNL/Silo --depth 5 silo
  cd silo && rm -rf build && mkdir build && cd build
  export CC=mpicc CXX=mpicxx
  cmake -DCMAKE_INSTALL_PREFIX=$CWD/tpp \
      -DCMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS}" \
      ${CMAKE_CONFIG} ..
  make VERBOSE=1 -j$THREADS && make install
)

CMAKE_CONFIG+="-DENABLE_SILO=ON -DSILO_DIR=$CWD/tpp"

time (
  date
  (
    rm -rf build && mkdir build && cd build
    cmake ../samrai \
      -DENABLE_OPENMP=OFF -DENABLE_SAMRAI_TESTS=OFF \
      -DCMAKE_INSTALL_PREFIX=$CWD  -DENABLE_DOCS=ON \
      -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=true \
      -DCMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS}" \
      ${CMAKE_CONFIG} # -DBUILD_SHARED_LIBS=ON
    make VERBOSE=1 -j$THREADS && make install
  )
  rm -rf build
  date
) 1> >(tee $CWD/.cmake.sh.out ) 2> >(tee $CWD/.cmake.sh.err >&2 )
