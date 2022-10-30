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
mkdir riscv-formal/cores/cpu
cp ${DIR}/verification/checks.cfg riscv-formal/cores/cpu/
cp ${DIR}/verification/wrapper.sv riscv-formal/cores/cpu/
cp ${DIR}/verification/disasm.py riscv-formal/cores/cpu/

cp ${DIR}/verilog/tb/configure.sv riscv-formal/cores/cpu/
cp ${DIR}/verilog/constants.sv riscv-formal/cores/cpu/
cp ${DIR}/verilog/functions.sv riscv-formal/cores/cpu/
cp ${DIR}/verilog/wires.sv riscv-formal/cores/cpu/
cp ${DIR}/verilog/alu.sv riscv-formal/cores/cpu/
cp ${DIR}/verilog/agu.sv riscv-formal/cores/cpu/
cp ${DIR}/verilog/bcu.sv riscv-formal/cores/cpu/
cp ${DIR}/verilog/lsu.sv riscv-formal/cores/cpu/
cp ${DIR}/verilog/csr_alu.sv riscv-formal/cores/cpu/
cp ${DIR}/verilog/div.sv riscv-formal/cores/cpu/
cp ${DIR}/verilog/mul.sv riscv-formal/cores/cpu/
cp ${DIR}/verilog/predecoder.sv riscv-formal/cores/cpu/
cp ${DIR}/verilog/postdecoder.sv riscv-formal/cores/cpu/
cp ${DIR}/verilog/register.sv riscv-formal/cores/cpu/
cp ${DIR}/verilog/csr.sv riscv-formal/cores/cpu/
cp ${DIR}/verilog/compress.sv riscv-formal/cores/cpu/
cp ${DIR}/verilog/fetchbuffer.sv riscv-formal/cores/cpu/
cp ${DIR}/verilog/forwarding.sv riscv-formal/cores/cpu/
cp ${DIR}/verilog/fetch_stage.sv riscv-formal/cores/cpu/
cp ${DIR}/verilog/execute_stage.sv riscv-formal/cores/cpu/
cp ${DIR}/verilog/arbiter.sv riscv-formal/cores/cpu/
cp ${DIR}/verilog/pmp.sv riscv-formal/cores/cpu/
cp ${DIR}/verilog/cpu.sv riscv-formal/cores/cpu/

start=`date +%s`

cd riscv-formal/cores/cpu
rm -rf checks
python3 ../../checks/genchecks.py
make -C checks #-j$(nproc)

end=`date +%s`
echo Execution time was `expr $end - $start` seconds.
