#!/bin/bash
set -e

RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[1;33m"
NC="\033[0m"

if [ ! -d "$BASEDIR/sim/work" ]; then
  mkdir $BASEDIR/sim/work
fi

rm -rf $BASEDIR/sim/work/*

cd $BASEDIR/sim/work

declare -A benchmark=([bootloader]=1 [coremark]=1 [csmith]=1 [dhrystone]=1 [sram]=1 [timer]=1)
declare -A verification=([compliance]=1 [isa]=1)

start=`date +%s`

$XVLOG -sv $BASEDIR/verilog/tb/configure.sv \
            $BASEDIR/verilog/constants.sv \
            $BASEDIR/verilog/functions.sv \
            $BASEDIR/verilog/wires.sv \
            $BASEDIR/verilog/alu.sv \
            $BASEDIR/verilog/agu.sv \
            $BASEDIR/verilog/bcu.sv \
            $BASEDIR/verilog/lsu.sv \
            $BASEDIR/verilog/csr_alu.sv \
            $BASEDIR/verilog/div.sv \
            $BASEDIR/verilog/mul.sv \
            $BASEDIR/verilog/predecoder.sv \
            $BASEDIR/verilog/postdecoder.sv \
            $BASEDIR/verilog/register.sv \
            $BASEDIR/verilog/csr.sv \
            $BASEDIR/verilog/compress.sv \
            $BASEDIR/verilog/fetchbuffer.sv \
            $BASEDIR/verilog/forwarding.sv \
            $BASEDIR/verilog/fetch_stage.sv \
            $BASEDIR/verilog/execute_stage.sv \
            $BASEDIR/verilog/arbiter.sv \
            $BASEDIR/verilog/clint.sv \
            $BASEDIR/verilog/pmp.sv \
            $BASEDIR/verilog/clic.sv \
            $BASEDIR/verilog/cpu.sv \
            $BASEDIR/verilog/tb/bram.sv \
            $BASEDIR/verilog/tb/print.sv \
            $BASEDIR/verilog/tb/rom.sv \
            $BASEDIR/verilog/tb/soc.sv 2>&1 > /dev/null

$XELAB -top soc -snapshot soc_snapshot 2>&1 > /dev/null

if [[ -n "${benchmark[$PROGRAM]}" ]]
then
  cp $BASEDIR/build/$PROGRAM/dat/$PROGRAM.dat bram.dat
  cp $BASEDIR/build/$PROGRAM/elf/$PROGRAM.host host.dat
  if [ "$DUMP" = 'on' ]
  then
    $XSIM soc_snapshot --tclbatch $BASEDIR/sim/xsim_cfg.tcl --wdb $PROGRAM.wdb --testplusarg MAXTIME=$MAXTIME
  else
    $XSIM soc_snapshot -R --testplusarg MAXTIME=$MAXTIME
  fi
elif [[ -n "${verification[$PROGRAM]}" ]]
then
  for filename in $BASEDIR/build/$PROGRAM/dat/*.dat; do
    filename=${filename##*/}
    filename=${filename%.dat}
    echo -e "${BLUE}${filename}${NC}"
    cp $BASEDIR/build/$PROGRAM/dat/$filename.dat bram.dat
    cp $BASEDIR/build/$PROGRAM/elf/$filename.host host.dat
    if [ "$DUMP" = 'on' ]
    then
      $XSIM soc_snapshot --tclbatch $BASEDIR/sim/xsim_cfg.tcl --wdb $filename.wdb --testplusarg MAXTIME=$MAXTIME
    else
      $XSIM soc_snapshot -R --testplusarg MAXTIME=$MAXTIME
    fi
  done
else
  subpath=${PROGRAM%/dat*}
  filename=${PROGRAM##*/}
  filename=${filename%.dat}
  cp $BASEDIR/$subpath/dat/$filename.dat bram.dat
  cp $BASEDIR/$subpath/elf/$filename.host host.dat
  if [ "$DUMP" = 'on' ]
  then
    $XSIM soc_snapshot --tclbatch $BASEDIR/sim/xsim_cfg.tcl --wdb $filename.wdb --testplusarg MAXTIME=$MAXTIME
  else
    $XSIM soc_snapshot -R --testplusarg MAXTIME=$MAXTIME
  fi
fi
end=`date +%s`
echo Execution time was `expr $end - $start` seconds.
