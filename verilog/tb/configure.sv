package configure;
  timeunit 1ns;
  timeprecision 1ps;

  parameter bram_latency = 0;

  parameter mul_performance = 1;

  parameter prefetch_depth = 4;

  parameter bram_depth = 17;

  parameter clint_contexts = 0;

  parameter plic_contexts = 0;

  parameter start_base_addr = 32'h0;

  parameter uart_base_addr = 32'h100000;
  parameter uart_top_addr  = 32'h100004;

  parameter clint_base_addr = 32'h2000000;
  parameter clint_top_addr  = 32'h200C000;

  parameter plic_base_addr = 32'h0C000000;
  parameter plic_top_addr  = 32'h10000000;

endpackage
