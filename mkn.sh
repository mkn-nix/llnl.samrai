#!/usr/bin/env bash
set -e
CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DIR="samrai"
GIT_URL="https://github.com/llnl/$DIR"
VERSION="master"
FFF=("include" "lib" "$DIR" "share")
[ ! -z "$MKN_CLEAN" ] && (( $MKN_CLEAN == 1 )) && for f in ${FFF[@]}; do rm -rf $CWD/$f; done
[ ! -d "$CWD/$DIR" ] && git clone --depth 1 $GIT_URL -b $VERSION $DIR --recursive
cd $CWD/$DIR
rm -rf build && mkdir build && cd build
read -r -d '' CMAKE <<- EOM || echo "running cmake"
cmake -DCMAKE_INSTALL_PREFIX=$CWD
      -DCMAKE_BUILD_TYPE=Debug ..
EOM
$CMAKE &&  make -j && make install
