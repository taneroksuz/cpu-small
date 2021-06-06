module soc
(
  input logic rst,
  input logic clk,
  input logic rtc
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [0  : 0] memory_valid;
  logic [0  : 0] memory_instr;
  logic [31 : 0] memory_addr;
  logic [31 : 0] memory_wdata;
  logic [3  : 0] memory_wstrb;
  logic [31 : 0] memory_rdata;
  logic [0  : 0] memory_ready;

  logic [0  : 0] bram_valid;
  logic [0  : 0] bram_instr;
  logic [31 : 0] bram_addr;
  logic [31 : 0] bram_wdata;
  logic [3  : 0] bram_wstrb;
  logic [31 : 0] bram_rdata;
  logic [0  : 0] bram_ready;

  logic [0  : 0] timer_valid;
  logic [0  : 0] timer_instr;
  logic [31 : 0] timer_addr;
  logic [31 : 0] timer_wdata;
  logic [3  : 0] timer_wstrb;
  logic [31 : 0] timer_rdata;
  logic [0  : 0] timer_ready;
  logic [0  : 0] timer_irpt;

  always_comb begin

    if (memory_addr >= timer_base_address &&
      memory_addr < timer_top_address) begin
      bram_valid = 0;
      timer_valid = memory_valid;
    end else begin
      bram_valid = memory_valid;
      timer_valid = 0;
    end

    bram_instr = memory_instr;
    bram_addr = memory_addr;
    bram_wdata = memory_wdata;
    bram_wstrb = memory_wstrb;

    timer_instr = memory_instr;
    timer_addr = memory_addr ^ timer_base_address;
    timer_wdata = memory_wdata;
    timer_wstrb = memory_wstrb;

    if (bram_ready == 1) begin
      memory_rdata = bram_rdata;
      memory_ready = bram_ready;
    end else if  (timer_ready == 1) begin
      memory_rdata = timer_rdata;
      memory_ready = timer_ready;
    end else begin
      memory_rdata = 0;
      memory_ready = 0;
    end

  end

  cpu cpu_comp
  (
    .rst (rst),
    .clk (clk),
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
    .rst (rst),
    .clk (clk),
    .bram_valid (bram_valid),
    .bram_instr (bram_instr),
    .bram_addr (bram_addr),
    .bram_wdata (bram_wdata),
    .bram_wstrb (bram_wstrb),
    .bram_rdata (bram_rdata),
    .bram_ready (bram_ready)
  );

  timer timer_comp
  (
    .rst (rst),
    .clk (clk),
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
