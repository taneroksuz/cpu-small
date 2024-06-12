import wires::*;
import constants::*;

module ccd(
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

  typedef struct packed{
    logic [0  : 0] memory_valid;
    logic [0  : 0] memory_instr;
    logic [31 : 0] memory_addr;
    logic [31 : 0] memory_wdata;
    logic [3  : 0] memory_wstrb;
  } reg_type_in;

  parameter reg_type_in init_reg_in = '{
    memory_valid : 0,
    memory_instr : 0,
    memory_addr : 0,
    memory_wdata : 0,
    memory_wstrb : 0
  };

  typedef struct packed{
    logic [31 : 0] memory_rdata;
    logic [0  : 0] memory_ready;
  } reg_type_out;

  parameter reg_type_out init_reg_out = '{
    memory_rdata : 0,
    memory_ready : 0
  };

  reg_type_in r,rin,v;

  reg_type_out r_out_1,r_out_2,r_out_3;

  always_comb begin

    v = r;

    if (memory_valid == 1 && memory_slow_valid == 0) begin
      v.memory_valid = memory_valid;
      v.memory_instr = memory_instr;
      v.memory_addr = memory_addr;
      v.memory_wdata = memory_wdata;
      v.memory_wstrb = memory_wstrb;
    end else if (memory_valid == 0 && memory_slow_valid == 1) begin
      v.memory_valid = 0;
      v.memory_instr = 0;
      v.memory_addr = 0;
      v.memory_wdata = 0;
      v.memory_wstrb = 0;
    end

    rin = v;

  end

  always_comb begin

    if (r_out_3.memory_ready == 0 && r_out_2.memory_ready == 1) begin
      memory_rdata = r_out_2.memory_rdata;
      memory_ready = r_out_2.memory_ready;
    end else begin
      memory_rdata = r_out_2.memory_rdata;
      memory_ready = r_out_2.memory_ready;
    end

  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      r <= init_reg_in;
    end else begin
      r <= rin;
    end
  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      r_out_1 <= init_reg_out;
      r_out_2 <= init_reg_out;
      r_out_3 <= init_reg_out;
    end else begin
      r_out_1.memory_rdata <= memory_slow_rdata;
      r_out_1.memory_ready <= memory_slow_ready;
      r_out_2 <= r_out_1;
      r_out_3 <= r_out_2;
    end
  end

  always_ff @(posedge clock_slow) begin
    if (reset == 0) begin
      memory_slow_valid <= 0;
      memory_slow_instr <= 0;
      memory_slow_addr <= 0;
      memory_slow_wdata <= 0;
      memory_slow_wstrb <= 0;
    end else begin
      memory_slow_valid <= rin.memory_valid;
      memory_slow_instr <= rin.memory_instr;
      memory_slow_addr <= rin.memory_addr;
      memory_slow_wdata <= rin.memory_wdata;
      memory_slow_wstrb <= rin.memory_wstrb;
    end
  end

endmodule
