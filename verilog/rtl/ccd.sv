import wires::*;
import constants::*;

module ccd
#(
  parameter clock_rate
)
(
  input  logic reset,
  input  logic clock,
  input  logic clock_slow,
  input  logic [0  : 0] memory_valid,
  input  logic [0  : 0] memory_instr,
  input  logic [31 : 0] memory_addr,
  input  logic [31 : 0] memory_wdata,
  input  logic [3  : 0] memory_wstrb,
  output logic [31 : 0] memory_rdata,
  output logic [0  : 0] memory_ready,
  output logic [0  : 0] memory_slow_valid,
  output logic [0  : 0] memory_slow_instr,
  output logic [31 : 0] memory_slow_addr ,
  output logic [31 : 0] memory_slow_wdata,
  output logic [3  : 0] memory_slow_wstrb,
  input  logic [31 : 0] memory_slow_rdata,
  input  logic [0  : 0] memory_slow_ready
);
  timeunit 1ns;
  timeprecision 1ps;

  localparam depth = $clog2(clock_rate);
  localparam full = clock_rate-1;

  localparam [depth-1:0] one = 1;

  logic [depth-1:0] count;

  logic [31 : 0] memory_fast_rdata;
  logic [0  : 0] memory_fast_ready;

  typedef struct packed{
    logic [0  : 0] memory_valid;
    logic [0  : 0] memory_instr;
    logic [31 : 0] memory_addr;
    logic [31 : 0] memory_wdata;
    logic [3  : 0] memory_wstrb;
  } reg_type;

  reg_type r,rin,v;

  initial begin
    count = 0;
  end

  always_comb begin

    v = r;

    v.memory_valid = 0;
    v.memory_instr = 0;
    v.memory_addr = 0;
    v.memory_wdata = 0;
    v.memory_wstrb = 0;

    if (memory_valid == 1) begin
      v.memory_valid = memory_valid;
      v.memory_instr = memory_instr;
      v.memory_addr = memory_addr;
      v.memory_wdata = memory_wdata;
      v.memory_wstrb = memory_wstrb;
    end

    memory_slow_valid = v.memory_valid;
    memory_slow_instr = v.memory_instr;
    memory_slow_addr = v.memory_addr;
    memory_slow_wdata = v.memory_wdata;
    memory_slow_wstrb = v.memory_wstrb;

    memory_rdata = memory_fast_rdata;
    memory_ready = memory_fast_ready;

    rin = v;

  end

  always_ff @(posedge clock) begin
    if (count == full[depth-1:0]) begin
      count <= 0;
    end else begin
      count <= count + one;
    end
  end

  always_ff @(posedge clock) begin
    if (count == full[depth-1:0] && memory_slow_ready == 1) begin
      memory_fast_rdata <= memory_slow_rdata;
      memory_fast_ready <= memory_slow_ready;
    end else begin
      memory_fast_rdata <= 0;
      memory_fast_ready <= 0;
    end
  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      r <= '{default:0};
    end else begin
      r <= rin;
    end
  end

endmodule
