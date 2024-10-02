# CPU-SMALL

This cpu is 2-stage scalar processor.

## SPECIFICATIONS

### Architecture
- RV32-IMC
- Fast and slow option for multiplication unit
- Slow division unit
- Physical Memory Protection
### Memory
- Neumann bus architecture
- Unified Tightly Integrated Memory
### Peripheral
- UART
- Baudrate 115200
- Start Bit
- Stop Bit
- 8 Data Bits
- No Parity Bit

## TOOLS

The installation scripts of necessary tools are located in directory **tools**. These scripts need **root** permission in order to install packages and tools for simulation and testcase generation.

## USAGE

1. Clone the repository:
```console
git clone --recurse-submodules https://github.com/taneroksuz/cpu-small.git
```

2. Install necessary tools for compilation and simulation:
```console
make tool
```

3. Compile some benchmarks:
```console
make compile
```

4. Compiled executable files are located in **riscv** and dumped files are located in **dump**. Select some executable from the directory **riscv** and copy them into this directory **sim/xsim/input**:
```console
cp riscv/coremark.riscv sim/xsim/input/
```

5. Run simulation:
```console
make xsim
```

6. Run simulation with <u>debug</u> feature:
```console
make xsim DUMP=1
```

7. Run simulation with <u>short period of time</u> (e.g 1us, default 10ms):
```console
make xsim MAXTIME=1000
```

8. The simulation results together with <u>debug</u> informations are located in **sim/xsim/output**.

## BENCHMARKS

### Coremark Benchmark
| Cycles | Iteration/s/MHz | Iteration |
| ------ | --------------- | --------- |
| 339800 |            2.94 |        10 |
