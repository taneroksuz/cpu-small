#include <systemc.h>
#include <verilated.h>
#include <verilated_vcd_sc.h>

#include "Vtop_cpu.h"

#include <iostream>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

using namespace std;

int sc_main(int argc, char* argv[])
{
  Verilated::commandArgs(argc, argv);

  long long unsigned time;
  string filename;
  char *p;
  const char *dumpfile;

  if (argc>1)
  {
    time = strtol(argv[1], &p, 10);
  }
  if (argc>2)
  {
    filename = string(argv[2]);
    filename = filename + ".vcd";
    dumpfile = filename.c_str();
  }

  sc_clock clk ("clk", 1,SC_NS, 0.5, 0.5,SC_NS, false);
  sc_clock rtc ("rst", 30.517578125,SC_US, 15.2587890625, 15.2587890625,SC_US, false);
  sc_signal<bool> rst;

  Vtop_cpu* top_cpu = new Vtop_cpu("top_cpu");

  top_cpu->clk (clk);
  top_cpu->rtc (rtc);
  top_cpu->rst (rst);

#if VM_TRACE
  Verilated::traceEverOn(true);
#endif

#if VM_TRACE
  VerilatedVcdSc* dump = new VerilatedVcdSc;
  top_cpu->trace(dump, 99);
  dump->open(dumpfile);
#endif

  while (!Verilated::gotFinish())
  {
#if VM_TRACE
    if (dump) dump->flush();
#endif
    if (VL_TIME_Q() > 0 && VL_TIME_Q() < 10)
    {
      rst = !1;
    }
    else if (VL_TIME_Q() > 0)
    {
      rst = !0;
    }
    if (VL_TIME_Q() > time)
    {
      break;
    }
    sc_start(1,SC_NS);
  }

  cout << "End of simulation is " << sc_time_stamp() << endl;

  top_cpu->final();

#if VM_TRACE
  if (dump)
  {
    dump->close();
    dump = NULL;
  }
#endif

  delete top_cpu;
  top_cpu = NULL;

  return 0;
}
