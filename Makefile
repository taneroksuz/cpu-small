default: simulate

export VERILATOR ?= verilator
export VERIBLE ?= verible
export PYTHON ?= python3
export PYTHON ?= /usr/bin/python3
export SERIAL ?= /dev/ttyUSB0
export BASEDIR ?= $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
export BENCHMARK ?= benchmark

export RISCV ?= /opt/rv32imc
export ARCH ?= rv32imc_zicsr_zifencei
export ABI ?= ilp32

export MAXTIME ?= 10000000
export DUMP ?= 0# "1" on, "0" off

simulate:
	sim/run.sh

compile:
	benchmark/riscv-tests.sh
	benchmark/coremark.sh
	benchmark/whetstone.sh
	benchmark/free-rtos.sh
	benchmark/isa.sh
	benchmark/rom.sh

parse:
	check/run.sh

program:
	serial/transfer.sh
