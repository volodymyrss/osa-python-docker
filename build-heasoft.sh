#!/bin/bash

set -x
set -e

export actions=$@

export COMMIT_TIME=$(date --utc +%Y%m%d-%H%M%S)
export BUILD_TARBALL_COMMIT_TIME=$(date --utc +%Y%m%d-%H%M%S)
export OSA_BUILD_TARBALL_VERSION_LONG=$COMMIT_TIME
export OSA_BUILD_TARBALL_VERSION=${CI_COMMIT_TAG:-$OSA_BUILD_TARBALL_VERSION_LONG}


export heasoft_version=${heasoft_version:-6.27.2}
export install_prefix=/opt/heasoft/
export dist_prefix=/dist/heasoft/

export mirror_url="https://www.isdc.unige.ch/~ferrigno/Downloads/heasoft-${heasoft_version}src_no_xspec_modeldata.tar.gz"
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

echo "Downloading $url..."
wget -q -c $mirror_url -O $gzFile_fullpath || wget -q -c $url -O $gzFile_fullpath

if [ ! -f $gzFile_fullpath ]; then
    echo "Download failed."
    exit -1
fi


cd $build_dir

tar zxf $gzFile_fullpath
rm -fv $gzFile_fullpath

cd heasoft-${heasoft_version}/BUILD_DIR

    
scl enable devtoolset-7 bash

export CC=gcc
export CXX=g++
export F90=gfortran
export FC=gfortran


export CXXFLAGS="-fPIC -pthread -ldl"
export CFLAGS="-fPIC -pthread"
export LDFLAGS="-fPIC"

echo "Configuring... (message saved in log_configure)"
date
./configure --prefix=${install_prefix}  2>&1 | tee ${HOME}/configure.log #> /dev/null 2>&1
date


## centos5 does not compile otherwise, weird
export PATH=/heasoft/x86_64-unknown-linux-gnu-libc2.5/bin:$PATH

##
echo "Executing make..."
date
make 2>&1 | tee ${HOME}/build.log #> /dev/null 2>&1
date

echo "Executing make install..."
date
make install 2>&1 | tee ${HOME}/install.log #> /dev/null 2>&1
date

echo "Copy Xspec files for local models"
cd $build_dir/heasoft-${heasoft_version}

cp -p Xspec/BUILD_DIR/hmakerc ${install_prefix}/bin/ 
cp -p Xspec/BUILD_DIR/Makefile-std ${install_prefix}/bin/
rm -rf Xspec/src/spectral 

cd $build_dir

echo "Cleaning up.."
rm -rf $build_dir/heasoft-${heasoft_version}/ 
rm -fv *gz

find $install_prefix/heasoft -size +5M | grep ref | xargs rm -fv

cd ${HOME}
rm -rf $build_dir
