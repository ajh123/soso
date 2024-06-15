#!/bin/bash

# This script compiles and installs an i386-elf cross compiler. - WIP

set -e

# Variables
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
TARGET=i386-elf
PREFIX="$SCRIPT_DIR/toolchain/install"
PATH="$PREFIX/bin:$PATH"
PARALLEL_JOBS=$(nproc)
PATCH_FILE=./soso-binutils.patch  # Path to the patch file

# Source versions
BINUTILS_VERSION=2.40
GCC_VERSION=13.1.0

# Download URLs
BINUTILS_URL=https://ftp.gnu.org/gnu/binutils/binutils-$BINUTILS_VERSION.tar.gz
GCC_URL=https://ftp.gnu.org/gnu/gcc/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.gz

# Create directories
mkdir -p $PREFIX
mkdir -p /tmp/src

# Download and extract binutils
cd /tmp/src
if [ ! -f binutils-$BINUTILS_VERSION.tar.gz ]; then
  wget $BINUTILS_URL
fi
tar -xzf binutils-$BINUTILS_VERSION.tar.gz

# Apply the patch to binutils
cd binutils-$BINUTILS_VERSION
if [ -f "$PATCH_FILE" ]; then
  patch -p1 < "$PATCH_FILE"
else
  echo "Patch file not found: $PATCH_FILE"
  exit 1
fi

# Build and install binutils
mkdir build-binutils
cd build-binutils
../configure --target=$TARGET --prefix=$PREFIX --with-sysroot --disable-nls --disable-werror
make -j$PARALLEL_JOBS
make install

# Download and extract gcc
cd /tmp/src
if [ ! -f gcc-$GCC_VERSION.tar.gz ]; then
  wget $GCC_URL
fi
tar -xzf gcc-$GCC_VERSION.tar.gz

# Build and install gcc
cd gcc-$GCC_VERSION
mkdir build-gcc
cd build-gcc
../configure --target=$TARGET --prefix=$PREFIX --disable-nls --enable-languages=c,c++ --without-headers
make -j$PARALLEL_JOBS all-gcc
make -j$PARALLEL_JOBS all-target-libgcc
make install-gcc
make install-target-libgcc

echo "i686-elf cross compiler installation completed."
