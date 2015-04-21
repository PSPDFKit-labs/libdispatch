#!/usr/bin/env bash

set -e
set -x

function usage() {
    echo "Usage: $0 -p <PLATFORM> -c <TOOLCHAIN> -h <HOST> -n <NDK-PATH> -b <BUILD-DIR>"
    exit 1
}

function check_repo() {
    local directory=$1
    local repo_address=$2

    echo "check_repo: $directory $repo_address"

    if [ -d $directory ]; then
        pushd $directory
        git clean -fdx
        git pull
        popd
    else 
        local base_directory=${directory%/*}
        pushd $base_directory
        git clone $repo_address
        popd
    fi
}

while getopts ":p:c:h:n:b:" opt; do
    case $opt in
        p)
            PLATFORM=${OPTARG}
            ;;
        c)
            TOOLCHAIN=${OPTARG}
            ;;
        h)
            HOST=${OPTARG}
            ;;
        n)
            NDK_PATH=${OPTARG}
            ;;
        b)
            BUILD_DIR=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done

if [ -z $PLATFORM ] || [ -z $TOOLCHAIN ] || [ -z $HOST ] || [ -z $NDK_PATH ] || [ -z $BUILD_DIR ]; then
    usage
fi

if [ ! -d $NDK_PATH ]; then
    echo "$NDK_PATH doesn't look like a directory"
    exit 1
fi

# make standalone toolchain
TOOLCHAIN_PATH="`pwd`/$BUILD_DIR/toolchain"
if [ ! -d $TOOLCHAIN_PATH ]; then
    $NDK_PATH/build/tools/make-standalone-toolchain.sh --platform=$PLATFORM --install-dir=$TOOLCHAIN_PATH --toolchain=$TOOLCHAIN
fi
export PATH=$TOOLCHAIN_PATH/bin:$PATH

# make git directory
GIT_PATH=$BUILD_DIR/git
if [ ! -d $GIT_PATH ]; then
    mkdir -p $GIT_PATH
fi

# checkout blocks runtime
BLOCKSRUNTIME_PATH=$GIT_PATH/blocksruntime
check_repo $BLOCKSRUNTIME_PATH "git@github.com:mackyle/blocksruntime.git"

# build blocks runtime
pushd $BLOCKSRUNTIME_PATH
    CC=$HOST-clang AR=$HOST-ar RANLIB=$HOST-ranlib ./buildlib
    sudo prefix=$TOOLCHAIN_PATH ./installlib
    sudo cp BlocksRuntime/Block_private.h $TOOLCHAIN_PATH/include
popd

# checkout libkqueue
KQUEUE_PATH=$GIT_PATH/libkqueue
check_repo $KQUEUE_PATH "git@github.com:PSPDFKit-labs/libkqueue.git"

# build libkqueue
pushd $KQUEUE_PATH
    autoreconf -i
    ./configure --host=$HOST --prefix=$TOOLCHAIN_PATH --disable-shared --enable-static
    make
    make install
popd

# checkout libpthread_workqueue
WORKTHREAD_PATH=$GIT_PATH/libpthread_workqueue
check_repo $WORKTHREAD_PATH "git@github.com:PSPDFKit-labs/libpthread_workqueue.git"

# build libpthread_workqueue
pushd $WORKTHREAD_PATH
    autoreconf -i
    ./configure --host=$HOST --prefix=$TOOLCHAIN_PATH --disable-shared --enable-static
    make
    make install
popd

# checkout libdispatch
LIBDISPATCH_PATH=$GIT_PATH/libdispatch
check_repo $LIBDISPATCH_PATH "git@github.com:PSPDFKit-labs/libdispatch.git"

# build libdispatch
pushd $LIBDISPATCH_PATH
    ./autogen.sh
    KQUEUE_CFLAGS="-I$TOOLCHAIN_PATH/include/kqueue -I$TOOLCHAIN_PATH/include" KQUEUE_LIBS="-L$TOOLCHAIN_PATH/lib -lkqueue" ./configure --host=$HOST --prefix=$TOOLCHAIN_PATH --with-blocks-runtime=$TOOLCHAIN_PATH/lib --enable-libdispatch-init-constructor --disable-apple-tsd-optimizations --disable-shared --enable-static
    make
    make install
popd

$HOST-strip $TOOLCHAIN_PATH/lib/libdispatch.a

