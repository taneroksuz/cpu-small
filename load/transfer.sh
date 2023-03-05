#!/bin/bash
set -e

start=`date +%s`

stty -F $SERIAL 115200 cs8 -cstopb -parenb -crtscts

cat $BASEDIR/build/$PROGRAM/elf/$PROGRAM.bin > $SERIAL

end=`date +%s`
echo Execution time was `expr $end - $start` seconds.
