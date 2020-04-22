#!/bin/bash

set -x
set -e

export actions=$@

export COMMIT_TIME=$(date --utc +%Y%m%d-%H%M%S)
export BUILD_TARBALL_COMMIT_TIME=$(date --utc +%Y%m%d-%H%M%S)
export OSA_BUILD_TARBALL_VERSION_LONG=$COMMIT_TIME
export OSA_BUILD_TARBALL_VERSION=${CI_COMMIT_TAG:-$OSA_BUILD_TARBALL_VERSION_LONG}


export heasoft_version=${heasoft_version:-6.20}
export install_prefix=/opt/heasoft/
export dist_prefix=/dist/heasoft/
export url="https://heasarc.gsfc.nasa.gov/FTP/software/lheasoft/lheasoft${heasoft_version}/heasoft-${heasoft_version}src_no_xspec_modeldata.tar.gz"
export gzFile=`basename $url`
export gzFile_fullpath=/heasoft-${heasoft_version}src_no_xspec_modeldata.tar.gz
#dist_prefix/$gzFile
#export gzFile_fullpath=$dist_prefix/$gzFile
export logfile=$PACKAGE_ROOT/log/heasoft-build/`date +%Y-%m-%dT%H-%M-%S`.txt

#export http_proxy=https://proxy.unige.

export build_dir=/tmp/build
mkdir -pv $build_dir
mkdir -pv $dist_prefix

function link_latest {
(
    cd $build_dir
    cd ..
    [ -s latest ] && unlink latest
    ln -sfv ${OSA_BUILD_TARBALL_VERSION_LONG} latest
    cd ..
    [ -s latest ] && unlink latest
    ln -sfv ${heasoft_version} latest
)
}


function download {
#    if [ ! -f $gzFile_fullpath ]; then
        echo "Downloading $url..."
        #curl $url > $gzFile_fullpath
        wget -q -c $url -O $gzFile_fullpath
#    fi

    if [ ! -f $gzFile_fullpath ]; then
        echo "Download failed."
        exit -1
    fi
}


function build {
    cd $build_dir

    tar zxf $gzFile_fullpath
    rm -fv $gzFile_fullpath

    cd heasoft-${heasoft_version}/BUILD_DIR

    export platform=`cat /etc/platform`
    echo "detected platform: ${platform:=CentOS_7}" # this is specific for unige CI build

    if echo "$platform" | grep CentOS_5 ; then
        export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"

        export CC=gcc44
        export CXX=g++44
        export F90=gfortran44
        export FC=gfortran44
    fi

    if echo $platform | grep Ubuntu_; then
        export CC=gcc-4.4
        export CXX=g++-4.4
        export F90=gfortran-4.4
        export FC=gfortran-4.4
    fi

    export CXXFLAGS="-fPIC"
    export CFLAGS="-fPIC"
    export LDFLAGS="-fPIC"

    echo "Configuring... (message saved in log_configure)"
    date
    ./configure --prefix=${install_prefix}  > /dev/null 2>&1
    date


## centos5 does not compile otherwise, weird

    export PATH=/heasoft/x86_64-unknown-linux-gnu-libc2.5/bin:$PATH

##
    export CXXFLAGS="-fPIC"
    export CFLAGS="-fPIC"
    export LDFLAGS="-fPIC"

    echo "Executing make..."
    date
    make > /dev/null 2>&1
    date

    echo "Executing make install..."
    date
    make install > /dev/null 2>&1
    date

    cd $HOME

    echo "Cleaning up.."
    rm -rf heasoft-${heasoft_version}/ 
    rm -fv *gz

    find $install_prefix/heasoft -size +5M | grep ref | xargs rm -fv

    rm -rf $build_dir
}

for action in $actions; do
    echo "running action $action ..."
    $action
done

