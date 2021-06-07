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

  logic [31 : 0] prefetch_buffer[0:2**prefetch_depth-1];

  typedef struct packed{
    logic [31:0] pc;
    logic [31:0] npc;
    logic [31:0] fpc;
    logic [31:0] nfpc;
    logic [31:0] instr;
    logic [31:0] rdata;
    logic [31:0] rdata1;
    logic [31:0] rdata2;
    logic [31:0] wdata;
    logic [0:0] incr;
    logic [0:0] oflow;
    logic [0:0] wden1;
    logic [0:0] wden2;
    logic [0:0] rden1;
    logic [0:0] rden2;
    logic [0:0] ready;
    logic [0:0] wren;
    logic [0:0] wben;
    logic [0:0] valid;
    logic [0:0] spec;
    logic [0:0] fence;
    logic [0:0] nspec;
    logic [0:0] nfence;
    logic [prefetch_depth-1:0] waddr;
    logic [prefetch_depth-1:0] raddr1;
    logic [prefetch_depth-1:0] raddr2;
    logic [prefetch_depth-1:0] wbaddr;
    logic [0:0] stall;
  } reg_type;

  reg_type init_reg = '{
    pc : 0,
    npc : 0,
    fpc : 0,
    nfpc : 0,
    instr : nop_instr,
    rdata : 0,
    rdata1 : 0,
    rdata2 : 0,
    wdata : 0,
    incr : 0,
    oflow : 0,
    wden1 : 0,
    wden2 : 0,
    rden1 : 0,
    rden2 : 0,
    ready : 0,
    wren : 0,
    wben : 0,
    valid : 0,
    spec : 0,
    fence : 0,
    nspec : 0,
    nfence : 0,
    waddr : 0,
    raddr1 : 0,
    raddr2 : 1,
    wbaddr : 0,
    stall : 0
  };

  reg_type r,rin;
  reg_type v;

  always_comb begin

    v = r;

    v.instr = nop_instr;
    v.stall = 0;
    v.incr = 0;
    v.wren = 0;
    v.wben = 0;
    v.wden1 = 0;
    v.wden2 = 0;
    v.rden1 = 0;
    v.rden2 = 0;

    v.pc = prefetch_in.pc;
    v.npc = prefetch_in.npc;
    v.spec = prefetch_in.spec;
    v.fence = prefetch_in.fence;
    v.valid = prefetch_in.valid;

    v.rdata = prefetch_in.rdata;
    v.ready = prefetch_in.ready;

    if (v.ready == 1) begin
      if (v.oflow == 1 && v.waddr < v.raddr1) begin
        v.wren = 1;
      end else if (v.oflow == 0) begin
        v.wren = 1;
      end
      v.wdata = v.rdata;
    end

    if (v.oflow == 0 && v.raddr1 < v.waddr) begin
      v.rden1 = 1;
    end else if (v.oflow == 1) begin
      v.rden1 = 1;
    end

    if (v.oflow == 0 && v.raddr2 < v.waddr) begin
      v.rden2 = 1;
    end else if (v.oflow == 1 && v.raddr2 != v.waddr) begin
      v.rden2 = 1;
    end

    if (v.wren == 1 && v.rden1 == 0 && v.waddr == v.raddr1) begin
      v.wden1 = 1;
    end
    if (v.wren == 1 && v.rden2 == 0 && v.waddr == v.raddr2) begin
      v.wden2 = 1;
    end

    if ((v.nfence | v.nspec) == 1) begin
      v.wren = 0;
      v.wden1 = 0;
      v.wden2 = 0;
      v.rden1 = 0;
      v.rden2 = 0;
    end

    v.wben = v.wren;
    v.wbaddr = v.waddr;

    v.rdata1 = prefetch_buffer[v.raddr1];
    v.rdata2 = prefetch_buffer[v.raddr2];

    if (v.wden1 == 1) begin
      v.rden1 = v.wden1;
      v.rdata1 = v.wdata;
    end
    if (v.wden2 == 1) begin
      v.rden2 = v.wden2;
      v.rdata2 = v.wdata;
    end

    if (v.pc[1] == 0) begin
      if (v.rden1 == 1) begin
        v.instr = v.rdata1;
      end else begin
        v.stall = 1;
      end
    end else if (v.pc[1] == 1) begin
      if (v.rden1 == 1) begin
        if (v.rdata1[17:16] == 2'b11) begin
          if (v.rden2 == 1) begin
            v.instr = {v.rdata2[15:0],v.rdata1[31:16]};
          end else begin
            v.stall = 1;
          end
        end else begin
          v.instr = {16'h0,v.rdata1[31:16]};
        end
      end else begin
        v.stall = 1;
      end
    end

    if (v.valid == 1) begin
      if (v.stall == 0) begin
        if (v.pc[1] == 0) begin
          if (v.instr[1:0] == 2'b11) begin
            v.incr = 1;
          end
        end else if (v.pc[1] == 1) begin
          v.incr = 1;
        end
      end
    end

    if (v.ready == 1) begin
      if (v.wren == 1) begin
        if (v.waddr == 2**prefetch_depth-1) begin
          v.oflow = 1;
          v.waddr = 0;
        end else begin
          v.waddr = v.waddr + 1;
        end
        v.fpc = v.fpc + 4;
      end
    end

    if (v.valid == 1) begin
      if (v.incr == 1) begin
        if (v.raddr1 == 2**prefetch_depth-1) begin
          v.oflow = 0;
          v.raddr1 = 0;
        end else begin
          v.raddr1 = v.raddr1 + 1;
        end
        if (v.raddr2 == 2**prefetch_depth-1) begin
          v.raddr2 = 0;
        end else begin
          v.raddr2 = v.raddr2 + 1;
        end
      end
    end

    if (v.valid == 1) begin
      if (v.spec == 1) begin
        v.nfpc = {v.npc[31:2],2'b0};
        v.nspec = 1;
        v.spec = 0;
        v.oflow = 0;
        v.waddr = 0;
        v.raddr1 = 0;
        v.raddr2 = 1;
      end else if (v.fence == 1) begin
        v.nfpc = {v.npc[31:2],2'b0};
        v.nfence = 1;
        v.fence = 0;
        v.oflow = 0;
        v.waddr = 0;
        v.raddr1 = 0;
        v.raddr2 = 1;
      end
    end

    if (v.ready == 1) begin
      if (v.valid == 1) begin
        if (v.nspec == 1 || v.nfence == 1) begin
          v.fpc = v.nfpc;
          v.spec = v.nspec;
          v.fence = v.nfence;
          v.nspec = 0;
          v.nfence = 0;
        end
      end
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
      r <= rin;
    end
  end

  always_ff @(posedge clk) begin
    if (rin.wben == 1) begin
      prefetch_buffer[rin.wbaddr] <= rin.wdata;
    end
  end

endmodule
