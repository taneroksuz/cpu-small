#!/bin/bash
set -e

RISCV_PATH=/opt/rv32imc

if [ -d "$RISCV_PATH" ]
then
  sudo rm -rf $RISCV_PATH
fi
sudo mkdir $RISCV_PATH
sudo chown -R $USER $RISCV_PATH/

if [ -d "riscv-gnu-toolchain" ]; then
  rm -rf riscv-gnu-toolchain
fi

sudo apt-get install autoconf automake autotools-dev curl python3 \
                     libmpc-dev libmpfr-dev libgmp-dev gawk build-essential \
                     bison flex texinfo gperf libtool patchutils bc zlib1g-dev \
                     libexpat-dev

git clone --jobs $(nproc) https://github.com/riscv/riscv-gnu-toolchain

cd riscv-gnu-toolchain

mkdir build
cd build

../configure --prefix=$RISCV_PATH --with-arch=rv32imc --with-abi=ilp32

make -j$(nproc)
