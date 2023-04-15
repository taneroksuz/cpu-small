package configure;
  timeunit 1ns;
  timeprecision 1ps;

  parameter mul_performance = 1;

  parameter fetchbuffer_depth = 4;

  parameter pmp_region = 4;

  parameter rom_base_addr = 32'h0;
  parameter rom_top_addr  = 32'h80;

  parameter uart_base_addr = 32'h1000000;
  parameter uart_top_addr  = 32'h1000004;

  parameter clint_base_addr = 32'h2000000;
  parameter clint_top_addr  = 32'h200C000;

  parameter clic_base_addr = 32'h3000000;
  parameter clic_top_addr  = 32'h3005000;

  parameter wb_base_addr = 32'h80000000;
  parameter wb_top_addr  = 32'h90000000;

  parameter clk_freq = 20000000; // 20MHz
  parameter rtc_freq = 32768; // 32768Hz
  parameter baudrate = 115200;

  parameter clk_divider_rtc = clk_freq/rtc_freq-1;
  parameter clks_per_bit = clk_freq/baudrate-1;

endpackage
