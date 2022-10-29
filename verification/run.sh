#!/bin/bash
set -e

while [[ $# -gt 0 ]]; do
  case $1 in
    --basedir) 
      DIR="$2"
      shift
      shift
      ;;
    *)
      echo "Unknown commandline arguments: $1 -> $2"
      exit 1
  esac
done

if [ ! -d "${DIR}/verification/work" ]; then
  mkdir ${DIR}/verification/work
fi

rm -rf ${DIR}/verification/work/*

cd ${DIR}/verification/work

git clone https://github.com/YosysHQ/riscv-formal.git
mkdir riscv-formal/cores/riscv-z0
cp ${DIR}/verification/checks.cfg riscv-formal/cores/riscv-z0/
cp ${DIR}/verification/wrapper.sv riscv-formal/cores/riscv-z0/
cp ${DIR}/verification/disasm.py riscv-formal/cores/riscv-z0/

cp ${DIR}/verilog/tb/configure.sv riscv-formal/cores/riscv-z0/
cp ${DIR}/verilog/constants.sv riscv-formal/cores/riscv-z0/
cp ${DIR}/verilog/functions.sv riscv-formal/cores/riscv-z0/
cp ${DIR}/verilog/wires.sv riscv-formal/cores/riscv-z0/
cp ${DIR}/verilog/alu.sv riscv-formal/cores/riscv-z0/
cp ${DIR}/verilog/agu.sv riscv-formal/cores/riscv-z0/
cp ${DIR}/verilog/bcu.sv riscv-formal/cores/riscv-z0/
cp ${DIR}/verilog/lsu.sv riscv-formal/cores/riscv-z0/
cp ${DIR}/verilog/csr_alu.sv riscv-formal/cores/riscv-z0/
cp ${DIR}/verilog/div.sv riscv-formal/cores/riscv-z0/
cp ${DIR}/verilog/mul.sv riscv-formal/cores/riscv-z0/
cp ${DIR}/verilog/predecoder.sv riscv-formal/cores/riscv-z0/
cp ${DIR}/verilog/postdecoder.sv riscv-formal/cores/riscv-z0/
cp ${DIR}/verilog/register.sv riscv-formal/cores/riscv-z0/
cp ${DIR}/verilog/csr.sv riscv-formal/cores/riscv-z0/
cp ${DIR}/verilog/compress.sv riscv-formal/cores/riscv-z0/
cp ${DIR}/verilog/fetchbuffer.sv riscv-formal/cores/riscv-z0/
cp ${DIR}/verilog/forwarding.sv riscv-formal/cores/riscv-z0/
cp ${DIR}/verilog/fetch_stage.sv riscv-formal/cores/riscv-z0/
cp ${DIR}/verilog/execute_stage.sv riscv-formal/cores/riscv-z0/
cp ${DIR}/verilog/arbiter.sv riscv-formal/cores/riscv-z0/
cp ${DIR}/verilog/cpu.sv riscv-formal/cores/riscv-z0/

start=`date +%s`

cd riscv-formal/cores/riscv-z0
rm -rf checks
python3 ../../checks/genchecks.py
make -C checks/ 

end=`date +%s`
echo Execution time was `expr $end - $start` seconds.
