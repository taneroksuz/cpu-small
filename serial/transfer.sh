#!/bin/bash
set -e

start=`date +%s`

stty -F $SERIAL 115200 cs8 -cstopb -parenb -crtscts

$PYTHON $BASEDIR/serial/write.py $SERIAL $BASEDIR/build/$PROGRAM/elf/$PROGRAM.bin

end=`date +%s`
echo Execution time was `expr $end - $start` seconds.
