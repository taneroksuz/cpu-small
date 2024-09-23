package configure;
  timeunit 1ns; timeprecision 1ps;

  // fpga -> 0
  parameter simulation = 1;

  parameter mul_performance = 1;

  parameter buffer_depth = 4;

  parameter tim_width = 32;
  parameter tim_depth = 8192;

  // xilinx -> 0 altera -> 1
  parameter ram_type = 0;

  parameter pmp_region = 4;

  parameter rom_base_addr = 32'h00;
  parameter rom_mask_addr = 32'hFF;

  parameter spi_base_addr = 32'h100000;
  parameter spi_mask_addr = 32'h0FFFFF;

  parameter uart_tx_base_addr = 32'h1000000;
  parameter uart_tx_mask_addr = 32'h0000003;

  parameter uart_rx_base_addr = 32'h1000004;
  parameter uart_rx_mask_addr = 32'h0000007;

  parameter clint_base_addr = 32'h2000000;
  parameter clint_mask_addr = 32'h000FFFF;

  parameter tim_base_addr = 32'h10000000;
  parameter tim_mask_addr = 32'h000FFFFF;

  parameter sram_base_addr = 32'h80000000;
  parameter sram_mask_addr = 32'h000FFFFF;

  parameter clk_freq = 100000000;  // 100MHz
  parameter per_freq = 10000000;  // 10MHz
  parameter rtc_freq = 1000000;  // 1MHz
  parameter baudrate = 115200;

  parameter clk_divider_per = clk_freq / per_freq;
  parameter clk_divider_rtc = clk_freq / rtc_freq;
  parameter clk_divider_bit = clk_freq / baudrate;

endpackage
