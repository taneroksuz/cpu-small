package configure;
  timeunit 1ns;
  timeprecision 1ps;

  parameter start_base_addr = 32'h0;

  parameter uart_base_addr = 32'h100000;
  parameter uart_top_addr = 32'h100004;

  parameter timer_base_address = 32'h200000;
  parameter timer_top_address = 32'h200010;

  parameter mul_performance = 1;

  parameter prefetch_depth = 4;
  parameter bram_depth = 12;

  parameter clk_freq = 100000000; // 100MHz
  parameter clk_pll = 50000000; // 50MHz
  parameter rtc_freq = 32768; // 32768Hz
  parameter baudrate = 115200;

  parameter clk_divider_pll = (clk_freq/clk_pll)/2-1;
  parameter clk_divider_rtc = (clk_freq/rtc_freq)/2-1;
  parameter clks_per_bit = clk_pll/baudrate-1;

endpackage
