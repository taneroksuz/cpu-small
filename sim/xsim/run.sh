#!/bin/bash
set -e

RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[1;33m"
NC="\033[0m"

rm -f $BASEDIR/sim/xsim/input/*.bin
rm -f $BASEDIR/sim/xsim/input/*.dat
rm -f $BASEDIR/sim/xsim/input/*.host

rm -f $BASEDIR/sim/xsim/input/*.reg
rm -f $BASEDIR/sim/xsim/input/*.csr
rm -f $BASEDIR/sim/xsim/input/*.mem
rm -f $BASEDIR/sim/xsim/input/*.vcd
rm -f $BASEDIR/sim/xsim/input/*.wdb

rm -rf $BASEDIR/sim/xsim/output/*

if [ ! -d "$BASEDIR/sim/xsim/work" ]; then
  mkdir $BASEDIR/sim/xsim/work
fi

rm -rf $BASEDIR/sim/xsim/work/*

cd $BASEDIR/sim/xsim/work

start=`date +%s`

$XVLOG --sv $BASEDIR/verilog/conf/configure.sv \
            $BASEDIR/verilog/rtl/constants.sv \
            $BASEDIR/verilog/rtl/functions.sv \
            $BASEDIR/verilog/rtl/wires.sv \
            $BASEDIR/verilog/rtl/alu.sv \
            $BASEDIR/verilog/rtl/agu.sv \
            $BASEDIR/verilog/rtl/bcu.sv \
            $BASEDIR/verilog/rtl/lsu.sv \
            $BASEDIR/verilog/rtl/csr_alu.sv \
            $BASEDIR/verilog/rtl/div.sv \
            $BASEDIR/verilog/rtl/mul.sv \
            $BASEDIR/verilog/rtl/predecoder.sv \
            $BASEDIR/verilog/rtl/postdecoder.sv \
            $BASEDIR/verilog/rtl/register.sv \
            $BASEDIR/verilog/rtl/csr.sv \
            $BASEDIR/verilog/rtl/compress.sv \
            $BASEDIR/verilog/rtl/buffer.sv \
            $BASEDIR/verilog/rtl/forwarding.sv \
            $BASEDIR/verilog/rtl/fetch_stage.sv \
            $BASEDIR/verilog/rtl/execute_stage.sv \
            $BASEDIR/verilog/rtl/arbiter.sv \
            $BASEDIR/verilog/rtl/ccd.sv \
            $BASEDIR/verilog/rtl/clint.sv \
            $BASEDIR/verilog/rtl/tim.sv \
            $BASEDIR/verilog/rtl/pmp.sv \
            $BASEDIR/verilog/rtl/cpu.sv \
            $BASEDIR/verilog/rtl/rom.sv \
            $BASEDIR/verilog/rtl/sram.sv \
            $BASEDIR/verilog/rtl/spi.sv \
            $BASEDIR/verilog/rtl/uart_rx.sv \
            $BASEDIR/verilog/rtl/uart_tx.sv \
            $BASEDIR/verilog/rtl/soc.sv \
            $BASEDIR/verilog/tb/testbench.sv

$XELAB -top testbench -snapshot testbench_snapshot

for FILE in $BASEDIR/sim/xsim/input/*; do
  ${RISCV}/bin/riscv32-unknown-elf-nm -A $FILE | grep -sw 'tohost' | sed -e 's/.*:\(.*\) D.*/\1/' > ${FILE%.*}.host
  ${RISCV}/bin/riscv32-unknown-elf-objcopy -O binary $FILE ${FILE%.*}.bin
  $PYTHON $BASEDIR/py/bin2dat.py --input $FILE --address 0x0 --offset 0x100000
  cp ${FILE%.*}.dat sram.dat
  cp ${FILE%.*}.host host.dat
  if [ "$DUMP" = "1" ]
  then
    $XSIM testbench_snapshot -testplusarg "MAXTIME=$MAXTIME" -testplusarg "REGFILE=${FILE%.*}.reg" -testplusarg "CSRFILE=${FILE%.*}.csr" -testplusarg "MEMFILE=${FILE%.*}.mem" -testplusarg "FILENAME=${FILE%.*}.vcd" -tclbatch $BASEDIR/sim/xsim/run.tcl --wdb ${FILE%.*}.wdb
    cp ${FILE%.*}.reg $BASEDIR/sim/xsim/output/.
    cp ${FILE%.*}.csr $BASEDIR/sim/xsim/output/.
    cp ${FILE%.*}.mem $BASEDIR/sim/xsim/output/.
    cp ${FILE%.*}.vcd $BASEDIR/sim/xsim/output/.
    cp ${FILE%.*}.wdb $BASEDIR/sim/xsim/output/.
  else
    $XSIM testbench_snapshot -R -testplusarg "MAXTIME=$MAXTIME"
  fi
done

end=`date +%s`
echo Execution time was `expr $end - $start` seconds.