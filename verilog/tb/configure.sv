package configure;
  timeunit 1ns;
  timeprecision 1ps;

  parameter mul_performance = 1;

  parameter fetchbuffer_depth = 4;

  parameter bram_depth = 262144;

  parameter pmp_region = 4;

  parameter rom_base_addr = 32'h0;
  parameter rom_top_addr  = 32'h80;

  parameter print_base_addr = 32'h1000000;
  parameter print_top_addr  = 32'h1000004;

  parameter clint_base_addr = 32'h2000000;
  parameter clint_top_addr  = 32'h200C000;

  parameter clic_base_addr = 32'h3000000;
  parameter clic_top_addr  = 32'h3005000;

  parameter bram_base_addr = 32'h80000000;
  parameter bram_top_addr  = 32'h90000000;

  parameter clk_freq = 1000000000; // 1GHz
  parameter rtc_freq = 100000000; // 100MHz

  parameter clk_divider_rtc = clk_freq/rtc_freq-1;

endpackage
