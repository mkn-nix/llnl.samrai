#!/usr/bin/env bash
set -ex
THREADS=${THREADS:=""}
CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DIR="samrai"
GIT_URL="https://github.com/llnl/$DIR"
VERSION="master"
FFF=("include" "lib" "$DIR" "share")
[ ! -z "$MKN_CLEAN" ] && (( $MKN_CLEAN == 1 )) && for f in ${FFF[@]}; do rm -rf $CWD/$f; done
[ ! -d "$CWD/$DIR" ] && git clone --depth 1 $GIT_URL -b $VERSION $DIR --recursive
cd $CWD/$DIR
rm -rf build && mkdir build && cd build

CMAKE_CXX_FLAGS="-DRAJA_ENABLE_CLANG_CUDA=1 -fPIC"
CMAKE_CUDA_FLAGS="${CMAKE_CXX_FLAGS} -x cuda -std=c++11 --cuda-gpu-arch=sm_61"

cmake .. -DTHREADS_PREFER_PTHREAD_FLAG=OFF \
  -DSAMRAI_ENABLE_EXAMPLES=OFF                \
  -DENABLE_EXAMPLES=OFF                       \
  -DENABLE_TESTS=OFF                          \
  -DENABLE_OPENMP=OFF -DENABLE_SAMRAI_TESTS=OFF \
  -DENABLE_CUDA=ON                              \
  -DCMAKE_CUDA_ARCHITECTURES=61               \
  -DCMAKE_INSTALL_PREFIX=$CWD \
  -DENABLE_RAJA=ON -DENABLE_UMPIRE=ON \
  -Dumpire_DIR=/home/philip.deegan/mkn/llnl/umpire/master/share/umpire/cmake \
  -DRAJA_DIR=/home/philip.deegan/mkn/llnl/raja/master/share/raja/cmake       \
  -DCMAKE_CUDA_COMPILER=clang++               \
  -DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda     \
  -DCMAKE_CUDA_COMPILER_TOOLKIT_ROOT=/usr/local/cuda \
  -DCMAKE_CUDA_COMPILER_ID_RUN=1              \
  -DCMAKE_CUDA_COMPILER_FORCED=1              \
  -DCMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS}"      \
  -DCMAKE_CUDA_FLAGS="${CMAKE_CUDA_FLAGS}"    \
  -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=true \

  #-DCMAKE_BUILD_TYPE=Release \

make VERBOSE=1 -j$THREADS && make install
#cd .. && rm -rf build

