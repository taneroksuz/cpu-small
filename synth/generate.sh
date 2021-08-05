#!/bin/bash

DIR=${1}
SV2V=${2}
FPGA=${3}

if [ -d "${DIR}/synth/verilog" ]; then
	rm -rf ${DIR}/synth/verilog
fi

mkdir ${DIR}/synth/verilog

cd ${DIR}/synth/verilog

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
				${DIR}/verilog/register.sv \
				${DIR}/verilog/csr.sv \
				${DIR}/verilog/compress.sv \
				${DIR}/verilog/prefetch.sv \
				${DIR}/verilog/forwarding.sv \
				${DIR}/verilog/fetch_stage.sv \
				${DIR}/verilog/execute_stage.sv \
				${DIR}/verilog/arbiter.sv \
				${DIR}/verilog/timer.sv \
				${DIR}/verilog/cpu.sv \
				${DIR}/verilog/${FPGA}/bram.sv \
				${DIR}/verilog/${FPGA}/soc.sv \
				> soc.v
