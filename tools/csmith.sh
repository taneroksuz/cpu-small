#!/bin/bash
set -e

INSTALL_PATH=/opt/csmith

if [ -d "$INSTALL_PATH" ]
then
  sudo rm -rf $INSTALL_PATH
fi
sudo mkdir $INSTALL_PATH
sudo chown -R $USER $INSTALL_PATH/

sudo apt-get -y install build-essential m4

if [ -d "csmith-2.3.0" ]; then
  rm -rf csmith-2.3.0
fi
if [ -f "csmith-2.3.0.tar.gz" ]; then
  rm  csmith-2.3.0.tar.gz
fi

wget https://embed.cs.utah.edu/csmith/csmith-2.3.0.tar.gz
tar xf csmith-2.3.0.tar.gz

cd csmith-2.3.0

./configure --prefix=$INSTALL_PATH

make -j$(nproc)
make install
