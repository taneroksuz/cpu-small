#!/bin/bash

sudo apt-get install build-essential clang bison flex \
              libreadline-dev gawk tcl-dev libffi-dev git haskell-stack \
              graphviz xdot pkg-config python3 libboost-system-dev \
              libboost-python-dev libboost-filesystem-dev zlib1g-dev

stack upgrade

if [ -d "sv2v" ]; then
  rm -rf sv2v
fi

git clone https://github.com/zachjs/sv2v.git

cd sv2v

make -j$(nproc)

sudo cp bin/sv2v /usr/local/bin/
sudo chmod +x /usr/local/bin/sv2v