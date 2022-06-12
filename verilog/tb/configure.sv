package configure;
  timeunit 1ns;
  timeprecision 1ps;

  parameter mul_performance = 1;

  parameter prefetch_depth = 4;

  parameter bram_depth = 18;

  parameter bram_base_addr = 32'h000000;
  parameter bram_top_addr  = 32'h100000;

  parameter print_base_addr = 32'h1000000;
  parameter print_top_addr  = 32'h1000004;

  parameter clint_base_addr = 32'h2000000;
  parameter clint_top_addr  = 32'h200C000;

endpackage
