#!/bin/bash

DIR=${1}
SV2V=${2}
FPGA=${3}
TEST=${4}

if [ -d "${DIR}/synth/verilog" ]; then
	rm -rf ${DIR}/synth/verilog
fi

mkdir ${DIR}/synth/verilog

cd ${DIR}/synth/verilog

if [ -f "${DIR}/build/${TEST}/dat/${TEST}.dat" ]; then
	cp ${DIR}/build/${TEST}/dat/${TEST}.dat bram.dat
fi

${SV2V} ${DIR}/verilog/${FPGA}/configure.sv \
				${DIR}/verilog/constants.sv \
				${DIR}/verilog/functions.sv \
				${DIR}/verilog/wires.sv \
				${DIR}/verilog/alu.sv \
				${DIR}/verilog/agu.sv \
				${DIR}/verilog/bcu.sv \
				${DIR}/verilog/lsu.sv \
				${DIR}/verilog/csr_alu.sv \
				${DIR}/verilog/div.sv \
				${DIR}/verilog/mul.sv \
				${DIR}/verilog/predecoder.sv \
				${DIR}/verilog/postdecoder.sv \
				${DIR}/verilog/register_ff.sv \
				${DIR}/verilog/csr.sv \
				${DIR}/verilog/compress.sv \
				${DIR}/verilog/prefetch.sv \
				${DIR}/verilog/forwarding.sv \
				${DIR}/verilog/fetch_stage.sv \
				${DIR}/verilog/execute_stage.sv \
				${DIR}/verilog/arbiter.sv \
				${DIR}/verilog/clint.sv \
				${DIR}/verilog/clic.sv \
				${DIR}/verilog/uart.sv \
				${DIR}/verilog/cpu.sv \
				> cpu.v

cp ${DIR}/verilog/${FPGA}/configure.sv configure.sv
cp ${DIR}/verilog/${FPGA}/bram.sv bram.sv
cp ${DIR}/verilog/${FPGA}/soc.sv soc.sv
