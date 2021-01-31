import configure::*;
import constants::*;
import wires::*;

module prefetch
(
  input logic rst,
  input logic clk,
  input prefetch_in_type prefetch_in,
  output prefetch_out_type prefetch_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [15 : 0] prefetch_buffer[0:2**prefetch_depth-1];

  typedef struct packed{
		logic [31:0] pc;
		logic [31:0] npc;
		logic [31:0] fpc;
		logic [31:0] instr;
		logic [0:0] wren;
		logic [0:0] rden;
		logic [0:0] wrdis;
		logic [0:0] wrbuf;
		logic [0:0] equal;
		logic [0:0] full;
		logic [prefetch_depth-1:0] wid;
		logic [prefetch_depth-1:0] rid;
		logic stall;
  } reg_type;

  reg_type init_reg = '{
		pc : 0,
		npc : 0,
		fpc : 0,
		instr : 0,
		wren : 0,
		rden : 0,
		wrdis : 0,
		wrbuf : 0,
		equal : 0,
		full : 0,
		wid : 0,
		rid : 0,
		stall : 0
  };

  reg_type r,rin;

  reg_type v;

  always_comb begin

    v = r;

    v.instr = nop_instr;
    v.stall = 0;
    v.wrdis = 0;
    v.wrbuf = 0;

    v.pc = prefetch_in.pc;
    v.npc = prefetch_in.npc;

    if (prefetch_in.fence == 1) begin
      v.fpc = {prefetch_in.vpc[31:2],2'b00};
    end

    v.wid = v.fpc[prefetch_depth:1];
    v.rid = v.pc[prefetch_depth:1];

    v.equal = ~|(v.fpc[31:2]^v.pc[31:2]);
    v.full = ~|(v.fpc[prefetch_depth:2]^v.pc[prefetch_depth:2]);

    if (v.equal == 1) begin
      v.wren = 1;
      v.rden = 0;
    end else if (v.full == 1) begin
      v.wren = 0;
    end else if (v.full == 0) begin
      v.wren = 1;
      v.rden = 1;
    end

    if (prefetch_in.ready == 1) begin
      if (v.wren == 1) begin
        v.wrbuf = 1;
        v.fpc = v.fpc + 4;
      end
    end else if (prefetch_in.ready == 0) begin
      if (v.wren == 1) begin
        v.wrdis = 1;
      end
    end

    if (prefetch_in.jump == 1) begin
      v.fpc = {v.npc[31:2],2'b00};
    end

    if (v.rden == 1) begin
      if (v.rid == 2**prefetch_depth-1) begin
        if (v.wid == 0) begin
          if (v.wrdis == 1) begin
            v.stall = 1;
          end else begin
            v.instr = {prefetch_in.rdata[15:0],prefetch_buffer[v.rid]};
          end
        end else begin
          v.instr = {prefetch_buffer[0],prefetch_buffer[v.rid]};
        end
      end else begin
        if (v.wid == v.rid+1) begin
          if (v.wrdis == 1) begin
            v.stall = 1;
          end else begin
            v.instr = {prefetch_in.rdata[15:0],prefetch_buffer[v.rid]};
          end
        end else begin
          v.instr = {prefetch_buffer[v.rid+1],prefetch_buffer[v.rid]};
        end
      end
    end else if (prefetch_in.ready == 1) begin
      if (v.pc[1] == 0) begin
        v.instr = prefetch_in.rdata[31:0];
      end else if (v.pc[1] == 1) begin
        if (&(prefetch_in.rdata[17:16]) == 0) begin
          v.instr = {16'h0,prefetch_in.rdata[31:16]};
        end else begin
          v.stall = 1;
        end
      end
    end else if (prefetch_in.ready == 0) begin
      v.stall = 1;
    end

    prefetch_out.fpc = v.fpc;
    prefetch_out.instr = v.instr;
    prefetch_out.stall = v.stall;

    rin = v;

  end

  always_ff @(posedge clk) begin
    if (rst == 0) begin
      r <= init_reg;
    end else begin
      if (rin.wrbuf == 1) begin
        prefetch_buffer[rin.wid] <= prefetch_in.rdata[15:0];
        prefetch_buffer[rin.wid+1] <= prefetch_in.rdata[31:16];
      end
      r <= rin;
    end
  end

endmodule
