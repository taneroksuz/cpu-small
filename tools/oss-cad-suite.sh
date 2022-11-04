#!/bin/bash

INST_PATH=/opt/oss-cad-suite

if [ -d "$INST_PATH" ]
then
  sudo rm -rf $INST_PATH
fi
sudo mkdir $INST_PATH
sudo chown -R $USER $INST_PATH/

if [ -f "oss-cad-suite-linux-x64-20221104.tgz" ]; then
  rm oss-cad-suite-linux-x64-20221104.tgz
fi

wget https://github.com/YosysHQ/oss-cad-suite-build/releases/download/2022-11-04/oss-cad-suite-linux-x64-20221104.tgz

tar xfz oss-cad-suite-linux-x64-20221104.tgz -C /opt/
