package configure;
  timeunit 1ns;
  timeprecision 1ps;

  parameter bram_latency = 0;

  parameter start_base_addr = 32'h0;

  parameter uart_base_addr = 32'h100000;
  parameter uart_top_addr = 32'h100004;

  parameter timer_base_address = 32'h200000;
  parameter timer_top_address = 32'h200010;

  parameter prefetch_depth = 4;
  parameter bram_depth = 16;

endpackage
