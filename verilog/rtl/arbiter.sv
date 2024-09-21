import wires::*;
import constants::*;

module arbiter (
    input logic reset,
    input logic clock,
    input mem_in_type imem_in,
    output mem_out_type imem_out,
    input mem_in_type dmem_in,
    output mem_out_type dmem_out,
    output mem_in_type mem_in,
    input mem_out_type mem_out
);
  timeunit 1ns; timeprecision 1ps;

  localparam [1:0] no_access = 0;
  localparam [1:0] instr_access = 1;
  localparam [1:0] data_access = 2;

  typedef struct packed {
    logic [1:0] access_type;
    mem_in_type mem_in;
    mem_in_type imem_in;
    mem_in_type dmem_in;
  } reg_type;

  localparam reg_type init_reg = '{default: 0};

  reg_type r, rin;
  reg_type v;

  always_comb begin

    v = r;

    if (mem_out.mem_ready == 1) begin
      v.access_type = no_access;
    end

    if (dmem_in.mem_valid == 1) begin
      v.dmem_in = dmem_in;
    end

    if (imem_in.mem_valid == 1) begin
      v.imem_in = imem_in;
    end

    if (v.access_type == no_access) begin
      if (v.dmem_in.mem_valid == 1) begin
        v.access_type = data_access;
        v.mem_in = v.dmem_in;
        v.dmem_in = init_mem_in;
      end else if (v.imem_in.mem_valid == 1) begin
        v.access_type = instr_access;
        v.mem_in = v.imem_in;
        v.imem_in = init_mem_in;
      end
    end

    if (v.access_type != no_access) begin
      mem_in = v.mem_in;
    end else begin
      mem_in = init_mem_in;
    end

    rin = v;

    if (r.access_type == data_access) begin
      dmem_out = mem_out;
    end else begin
      dmem_out = init_mem_out;
    end

    if (r.access_type == instr_access) begin
      imem_out = mem_out;
    end else begin
      imem_out = init_mem_out;
    end

  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      r <= init_reg;
    end else begin
      r <= rin;
    end
  end

endmodule
