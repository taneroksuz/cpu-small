#!/bin/bash

RISCV_PATH=/opt/riscv
FLAG="rv32i-ilp32--;rv32im-ilp32--;rv32imc-ilp32--;rv64imfd-lp64d--;rv64imfdc-lp64d--"

if [ -d "$RISCV_PATH" ]
then
  sudo rm -rf $RISCV_PATH
fi
sudo mkdir $RISCV_PATH
sudo chown -R $USER $RISCV_PATH/

sudo apt-get install git autoconf automake autotools-dev curl libmpc-dev \
  libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool \
  patchutils bc zlib1g-dev libexpat-dev texinfo python

if [ -d "riscv-gnu-toolchain" ]; then
  rm -rf riscv-gnu-toolchain/
fi

git clone --recursive https://github.com/riscv/riscv-gnu-toolchain

cd riscv-gnu-toolchain

mkdir build
cd build

../configure --prefix=$RISCV_PATH --with-multilib-generator=$FLAG
make -j$(nproc)

git clone --recursive https://github.com/riscv/riscv-isa-sim.git

cd riscv-spike

mkdir build
cd build

../configure --prefix=$RISCV_PATH

make -j$(nproc)

make install

git clone --recursive https://github.com/sifive/elf2hex.git

cd elf2hex

autoreconf -i

mkdir build
cd build

../configure --prefix=$RISCV_PATH

make -j$(nproc)

make install
