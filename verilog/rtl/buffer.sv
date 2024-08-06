package buffer_wires;
  timeunit 1ns; timeprecision 1ps;

  import configure::*;

  localparam depth = $clog2(buffer_depth - 1);

  typedef struct packed {
    logic [0 : 0] wen0;
    logic [0 : 0] wen1;
    logic [depth-1 : 0] waddr0;
    logic [depth-1 : 0] waddr1;
    logic [depth-1 : 0] raddr0;
    logic [depth-1 : 0] raddr1;
    logic [48 : 0] wdata0;
    logic [48 : 0] wdata1;
  } buffer_reg_in_type;

  typedef struct packed {
    logic [48 : 0] rdata0;
    logic [48 : 0] rdata1;
  } buffer_reg_out_type;

endpackage

import configure::*;
import constants::*;
import wires::*;
import buffer_wires::*;

module buffer_reg (
    input logic clock,
    input buffer_reg_in_type buffer_reg_in,
    output buffer_reg_out_type buffer_reg_out
);
  timeunit 1ns; timeprecision 1ps;

  localparam depth = $clog2(buffer_depth - 1);

  logic [48:0] buffer_reg_array0[0:buffer_depth-1] = '{default: '0};
  logic [48:0] buffer_reg_array1[0:buffer_depth-1] = '{default: '0};

  logic [48:0] rdata0;
  logic [48:0] rdata1;

  always_ff @(posedge clock) begin
    if (buffer_reg_in.wen0 == 1) begin
      buffer_reg_array0[buffer_reg_in.waddr0] <= buffer_reg_in.wdata0;
    end
  end

  always_ff @(posedge clock) begin
    if (buffer_reg_in.wen1 == 1) begin
      buffer_reg_array1[buffer_reg_in.waddr1] <= buffer_reg_in.wdata1;
    end
  end

  always_comb begin
    rdata0 = buffer_reg_array0[buffer_reg_in.raddr0];
    rdata1 = buffer_reg_array1[buffer_reg_in.raddr1];
  end

  always_comb begin
    buffer_reg_out.rdata0 = buffer_reg_in.raddr0 == buffer_reg_in.waddr0 ? buffer_reg_in.wdata0 : rdata0;
    buffer_reg_out.rdata1 = buffer_reg_in.raddr1 == buffer_reg_in.waddr1 ? buffer_reg_in.wdata1 : rdata1;
  end

endmodule

module buffer_ctrl (
    input logic reset,
    input logic clock,
    input buffer_in_type buffer_in,
    output buffer_out_type buffer_out,
    input buffer_reg_out_type buffer_reg_out,
    output buffer_reg_in_type buffer_reg_in
);
  timeunit 1ns; timeprecision 1ps;

  localparam depth = $clog2(buffer_depth - 1);
  localparam total = buffer_depth - 2;

  localparam [depth-1:0] one = 1;

  typedef struct packed {
    logic [depth : 0] wid;
    logic [depth : 0] rid;
    logic [depth : 0] diff;
    logic [depth : 0] count;
    logic [depth : 0] align;
    logic [48 : 0] wdata0;
    logic [48 : 0] wdata1;
    logic [48 : 0] rdata0;
    logic [48 : 0] rdata1;
    logic [31 : 0] pc;
    logic [31 : 0] instr;
    logic [0 : 0] wen;
    logic [0 : 0] comp;
    logic [0 : 0] ready;
    logic [0 : 0] error;
    logic [0 : 0] clear;
    logic [0 : 0] stall;
  } reg_type;

  parameter reg_type init_reg = '{
      wid : 0,
      rid : 0,
      diff : 0,
      count : 0,
      align : 0,
      wdata0 : 0,
      wdata1 : 0,
      rdata0 : 0,
      rdata1 : 0,
      pc : 0,
      instr : 0,
      wen : 0,
      comp : 0,
      ready : 0,
      error : 0,
      clear : 0,
      stall : 0
  };

  reg_type r, rin, v;

  always_comb begin

    v = r;

    if (buffer_in.clear == 1) begin
      v.wid   = 0;
      v.rid   = 0;
      v.count = 0;
      v.clear = 1;
    end

    if (r.clear == 1 && buffer_in.clear == 0 && buffer_in.ready == 1) begin
      v.rid   = {{depth{1'b0}}, buffer_in.pc[1]};
      v.align = {{depth{1'b0}}, buffer_in.pc[1]};
      v.clear = 0;
    end

    v.wen = (~buffer_in.clear) & (~r.stall) & buffer_in.ready;

    v.wdata0 = {buffer_in.error, buffer_in.pc[31:2], 2'b00, buffer_in.rdata[15:0]};
    v.wdata1 = {buffer_in.error, buffer_in.pc[31:2], 2'b10, buffer_in.rdata[31:16]};

    buffer_reg_in.wen0 = v.wen;
    buffer_reg_in.wen1 = v.wen;
    buffer_reg_in.waddr0 = v.wid[depth:1];
    buffer_reg_in.waddr1 = v.wid[depth:1];
    buffer_reg_in.wdata0 = v.wdata0;
    buffer_reg_in.wdata1 = v.wdata1;

    if (v.rid[0] == 0) begin
      buffer_reg_in.raddr0 = v.rid[depth:1];
      buffer_reg_in.raddr1 = v.rid[depth:1];
    end else begin
      buffer_reg_in.raddr0 = v.rid[depth:1] + one;
      buffer_reg_in.raddr1 = v.rid[depth:1];
    end

    if (v.rid[0] == 0) begin
      v.rdata0 = buffer_reg_out.rdata0;
      v.rdata1 = buffer_reg_out.rdata1;
    end else begin
      v.rdata0 = buffer_reg_out.rdata1;
      v.rdata1 = buffer_reg_out.rdata0;
    end

    if (v.wen == 1) begin
      v.wid   = v.wid + 2;
      v.count = v.count + 2;
    end

    v.diff = 0;

    v.comp = ~(&v.rdata0[1:0]);

    v.pc = 0;
    v.instr = 0;
    v.ready = 0;
    v.error = 0;

    if (v.comp == 1) begin
      if (v.count > v.align) begin
        v.pc = v.rdata0[47:16];
        v.instr = {16'b0, v.rdata0[15:0]};
        v.ready = 1;
        v.error = v.rdata0[48];
        v.diff = 1;
      end
    end
    if (v.comp == 0) begin
      if (v.count > v.align + 1) begin
        v.pc = v.rdata0[47:16];
        v.instr = {v.rdata1[15:0], v.rdata0[15:0]};
        v.ready = 1;
        v.error = v.rdata1[48] | v.rdata0[48];
        v.diff = 2;
      end
    end

    if (buffer_in.stall == 1) begin
      v.diff  = 0;
      v.ready = 0;
      v.error = 0;
    end

    v.count = v.count - v.diff;
    v.rid   = v.rid + v.diff;

    v.stall = 0;

    if (v.count > total) begin
      v.stall = 1;
    end

    buffer_out.pc = v.ready ? v.pc : 0;
    buffer_out.instr = v.ready ? v.instr : 0;
    buffer_out.miss = v.ready ? v.error : 0;
    buffer_out.done = v.ready;
    buffer_out.stall = ~v.wen;

    rin = v;

  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      r <= init_reg;
    end else begin
      r <= rin;
    end
  end

endmodule

module buffer (
    input logic reset,
    input logic clock,
    input buffer_in_type buffer_in,
    output buffer_out_type buffer_out
);
  timeunit 1ns; timeprecision 1ps;

  buffer_reg_in_type  buffer_reg_in;
  buffer_reg_out_type buffer_reg_out;

  buffer_reg buffer_reg_comp (
      .clock(clock),
      .buffer_reg_in(buffer_reg_in),
      .buffer_reg_out(buffer_reg_out)
  );

  buffer_ctrl buffer_ctrl_comp (
      .reset(reset),
      .clock(clock),
      .buffer_in(buffer_in),
      .buffer_out(buffer_out),
      .buffer_reg_in(buffer_reg_in),
      .buffer_reg_out(buffer_reg_out)
  );

endmodule
