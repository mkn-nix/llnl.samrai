#!/usr/bin/env bash
set -e
THREADS=${THREADS:="2"}
CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DIR="samrai"
GIT_URL="https://github.com/llnl/$DIR"
VERSION="develop"
FFF=("include" "lib" "$DIR" "share")
[ ! -z "$MKN_CLEAN" ] && (( $MKN_CLEAN == 1 )) && for f in ${FFF[@]}; do rm -rf $CWD/$f; done
[ ! -d "$CWD/$DIR" ] && git clone --depth 1 $GIT_URL -b $VERSION $DIR --recursive
cd $CWD/$DIR
rm -rf build && mkdir build

CMAKE_CONFIG=""

## SUPER RELEASE
CMAKE_CXX_FLAGS="-DNDEBUG -g0 -O3 -march=native -mtune=native"
CMAKE_BUILD_TYPE="Release"

# ## OPTIMZ AND DEBUG
# CMAKE_CXX_FLAGS="-g3 -O3 -march=native -mtune=native -fno-omit-frame-pointer"
# CMAKE_BUILD_TYPE="RelWithDebInfo"

# ## PURE DEBUG
# CMAKE_CXX_FLAGS="-g3 -O0 -fno-omit-frame-pointer"
# CMAKE_BUILD_TYPE="Debug"

CMAKE_CONFIG+=" -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}"

time (
  date
  (
    cd build
    cmake .. \
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
