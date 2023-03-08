import configure::*;
import wires::*;

module sram
(
  input  logic reset,
  input  logic clock,
  input  logic [0  : 0] sram_valid,
  input  logic [0  : 0] sram_instr,
  input  logic [31 : 0] sram_addr,
  input  logic [31 : 0] sram_wdata,
  input  logic [3  : 0] sram_wstrb,
  output logic [31 : 0] sram_rdata,
  output logic [0  : 0] sram_ready,
  inout  logic [15 : 0] sram_d,
  output logic [17 : 0] sram_a,
  output logic [0  : 0] sram_lb_n,
  output logic [0  : 0] sram_ub_n,
  output logic [0  : 0] sram_ce_n,
  output logic [0  : 0] sram_oe_n,
  output logic [0  : 0] sram_we_n
);
  timeunit 1ns;
  timeprecision 1ps;

  typedef struct packed{
    logic [1  : 0] state;
    logic [31 : 0] data;
    logic [3  : 0] strb;
    logic [17 : 0] addr;
    logic [0  : 0] wren;
    logic [0  : 0] rden;
    logic [15 : 0] d;
    logic [17 : 0] a;
    logic [0  : 0] ub;
    logic [0  : 0] lb;
    logic [0  : 0] ce;
    logic [0  : 0] oe;
    logic [0  : 0] we;
    logic [31 : 0] rdata;
    logic [0  : 0] ready;
  } register_type;

  register_type init_register = '{
    state : 0,
    data : 0,
    strb : 0,
    addr : 0,
    wren : 0,
    rden : 0,
    d : 0,
    a : 0,
    lb : 0,
    ub : 0,
    ce : 0,
    oe : 0,
    we : 0,
    rdata : 0,
    ready : 0
  };

  register_type r,rin,v;

  always_comb begin

    v = r;

    v.d = 0;
    v.a = 0;
    v.lb = 0;
    v.ub = 0;
    v.ce = 0;
    v.oe = 0;
    v.we = 0;

    v.rdata = 0;
    v.ready = 0;

    case(r.state)
      0 : begin
        v.state = 0;
        v.addr = 0;
        v.data = 0;
        v.strb = 0;
        v.wren = 0;
        v.rden = 0;
        if (sram_valid == 1) begin
          v.state = 1;
          v.addr = sram_addr[19:2];
          v.data = sram_wdata;
          v.strb = sram_wstrb;
          v.wren = |(sram_wstrb);
          v.rden = ~(|(sram_wstrb));
        end
        v.d = v.data[15:0];
        v.a = v.addr[17:0];
        v.lb = v.strb[0];
        v.ub = v.strb[1];
        v.ce = v.rden | v.wren;
        v.oe = v.rden;
        v.we = v.wren;
        if (v.rden == 1) begin
          v.lb = 1;
          v.ub = 1;
        end
      end
      1 : begin
        v.state = 0;
        v.d = v.data[31:16];
        v.a = v.addr[17:0] + 1;
        v.lb = v.strb[2];
        v.ub = v.strb[3];
        v.ce = v.rden | v.wren;
        v.oe = v.rden;
        v.we = v.wren;
        if (v.rden == 1) begin
          v.state = 2;
          v.lb = 1;
          v.ub = 1;
          v.rdata[15:0] = sram_d;
        end else if (v.wren == 1) begin 
          v.ready = 1;
        end
      end
      2 : begin
        v.state = 0;
        if (v.rden == 1) begin
          v.rdata[31:16] = sram_d;
          v.ready = 1;
        end
      end
      default : begin
        v.state = 0;
        v.addr = 0;
        v.data = 0;
        v.strb = 0;
        v.wren = 0;
        v.rden = 0;
      end
    endcase

    rin = v;

    sram_d = v.we == 1 ? v.d : 16'bz;
    sram_a = v.a;
    sram_lb_n = ~v.lb;
    sram_ub_n = ~v.ub;
    sram_ce_n = ~v.ce;
    sram_oe_n = ~v.oe;
    sram_we_n = ~v.we;

  end

  assign sram_rdata = v.rdata;
  assign sram_ready = v.ready;

  always_ff @ (posedge clock) begin
    if (reset == 1) begin
      r <= init_register;
    end else begin
      r <= rin;
    end
  end

endmodule
