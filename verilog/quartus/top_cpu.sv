import configure::*;

module top_cpu
(
  input logic rst,
  input logic clk,
  input logic rx,
  output logic tx
);
  timeunit 1ns;
  timeprecision 1ps;

  logic rst_not;
  logic rtc;
  logic clk_pll;

  logic [0  : 0] memory_valid;
  logic [0  : 0] memory_instr;
  logic [31 : 0] memory_addr;
  logic [31 : 0] memory_wdata;
  logic [3  : 0] memory_wstrb;
  logic [31 : 0] memory_rdata;
  logic [0  : 0] memory_ready;

  logic [0  : 0] bram_valid;
  logic [0  : 0] bram_wen;
  logic [0  : 0] bram_instr;
  logic [31 : 0] bram_addr;
  logic [31 : 0] bram_wdata;
  logic [3  : 0] bram_wstrb;
  logic [31 : 0] bram_rdata;
  logic [0  : 0] bram_ready;

  logic [0  : 0] uart_valid;
  logic [0  : 0] uart_instr;
  logic [31 : 0] uart_addr;
  logic [31 : 0] uart_wdata;
  logic [3  : 0] uart_wstrb;
  logic [31 : 0] uart_rdata;
  logic [0  : 0] uart_ready;

  logic [0  : 0] timer_valid;
  logic [0  : 0] timer_instr;
  logic [31 : 0] timer_addr;
  logic [31 : 0] timer_wdata;
  logic [3  : 0] timer_wstrb;
  logic [31 : 0] timer_rdata;
  logic [0  : 0] timer_ready;
  logic [0  : 0] timer_irpt;

  always_comb begin

    if (memory_addr >= uart_base_addr &&
          memory_addr < uart_top_addr) begin
      bram_valid = 0;
      timer_valid = 0;
      uart_valid = memory_valid;
    end else if (memory_addr >= timer_base_address &&
          memory_addr < timer_top_address) begin
      bram_valid = 0;
      timer_valid = memory_valid;
      uart_valid = 0;
    end else begin
      bram_valid = memory_valid;
      timer_valid = 0;
      uart_valid = 0;
    end

    bram_wen = bram_valid & (|memory_wstrb);
    bram_instr = memory_instr;
    bram_addr = memory_addr;
    bram_wdata = memory_wdata;
    bram_wstrb = memory_wstrb;

    timer_instr = memory_instr;
    timer_addr = memory_addr ^ timer_base_address;
    timer_wdata = memory_wdata;
    timer_wstrb = memory_wstrb;

    uart_instr = memory_instr;
    uart_addr = memory_addr ^ uart_base_addr;
    uart_wdata = memory_wdata;
    uart_wstrb = memory_wstrb;

    if (bram_ready == 1) begin
      memory_rdata = bram_rdata;
      memory_ready = bram_ready;
    end else if  (uart_ready == 1) begin
      memory_rdata = uart_rdata;
      memory_ready = uart_ready;
    end else if  (timer_ready == 1) begin
      memory_rdata = timer_rdata;
      memory_ready = timer_ready;
    end else begin
      memory_rdata = 0;
      memory_ready = 0;
    end

  end

  always_ff @(posedge clk_pll) begin

    if (bram_valid == 1) begin
      bram_ready <= 1;
    end else begin
      bram_ready <= 0;
    end

  end

  assign rst_not = ~rst;

  pll pll_comp
  (
    .refclk (clk),
    .outclk_0 (clk_pll),
    .outclk_1 (rtc)
  );

  cpu cpu_comp
  (
    .rst (rst),
    .clk (clk_pll),
    .memory_valid (memory_valid),
    .memory_instr (memory_instr),
    .memory_addr (memory_addr),
    .memory_wdata (memory_wdata),
    .memory_wstrb (memory_wstrb),
    .memory_rdata (memory_rdata),
    .memory_ready (memory_ready),
    .extern_irpt (1'b0),
    .timer_irpt (timer_irpt),
    .soft_irpt (1'b0)
  );

  bram bram_comp
  (
    .clk (clk_pll),
    .bram_wen (bram_wen),
    .bram_waddr (bram_addr),
    .bram_raddr (bram_addr),
    .bram_wdata (bram_wdata),
    .bram_wstrb (bram_wstrb),
    .bram_rdata (bram_rdata)
  );

  uart uart_comp
  (
    .rst (rst),
    .clk (clk_pll),
    .uart_valid (uart_valid),
    .uart_instr (uart_instr),
    .uart_addr (uart_addr),
    .uart_wdata (uart_wdata),
    .uart_wstrb (uart_wstrb),
    .uart_rdata (uart_rdata),
    .uart_ready (uart_ready),
    .uart_rx (rx),
    .uart_tx (tx)
  );

  timer timer_comp
  (
    .rst (rst),
    .clk (clk_pll),
    .rtc (rtc),
    .timer_valid (timer_valid),
    .timer_instr (timer_instr),
    .timer_addr (timer_addr),
    .timer_wdata (timer_wdata),
    .timer_wstrb (timer_wstrb),
    .timer_rdata (timer_rdata),
    .timer_ready (timer_ready),
    .timer_irpt (timer_irpt)
  );

endmodule
