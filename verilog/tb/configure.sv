package configure;
  timeunit 1ns; timeprecision 1ps;

  parameter mul_performance = 1;

  parameter buffer_depth = 8;

  parameter tim_width = 32;
  parameter tim_depth = 8192;

  parameter ram_type = 0;
  parameter ram_depth = 262144;

  parameter pmp_region = 4;

  parameter rom_base_addr = 32'h0;
  parameter rom_top_addr = 32'h80;

  parameter uart_base_addr = 32'h1000000;
  parameter uart_top_addr = 32'h1000004;

  parameter clint_base_addr = 32'h2000000;
  parameter clint_top_addr = 32'h200C000;

  parameter clic_base_addr = 32'h3000000;
  parameter clic_top_addr = 32'h3005000;

  parameter tim_base_addr = 32'h10000000;
  parameter tim_top_addr = 32'h10100000;

  parameter ram_base_addr = 32'h80000000;
  parameter ram_top_addr = 32'h90000000;

  parameter clk_freq = 100000000;  // 100MHz
  parameter rtc_freq = 1000000;  // 1MHz
  parameter slow_freq = 10000000;  // 10MHz
  parameter baudrate = 115200;

  parameter clk_divider_rtc = clk_freq / rtc_freq;
  parameter clk_divider_slow = clk_freq / slow_freq;
  parameter clks_per_bit = clk_freq / baudrate - 1;

endpackage
