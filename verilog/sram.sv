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

  function void transform
  (
    input  logic [31 : 0] addr_in,
    input  logic [31 : 0] data_in,
    input  logic [3  : 0] strb_in,
    output logic [17 : 0] addr_out,
    output logic [31 : 0] data_out,
    output logic [3  : 0] strb_out,
    output logic [0  : 0] state_out,
    output logic [0  : 0] ready_out,
    output logic [0  : 0] wren_out,
    output logic [0  : 0] rden_out
  );
    addr_out = 0;
    data_out = 0;
    strb_out = 0;
    state_out = 0;
    ready_out = 0;
    wren_out = 0;
    rden_out = 0;
    if (|(strb_in[3:0]) == 0) begin
      addr_out = addr_in[18:1];
      data_out = 0;
      strb_out = 4'hF;
      state_out = 1;
      ready_out = 0;
      rden_out = 1;
    end else if (&(strb_in[3:0]) == 1) begin
      addr_out = addr_in[18:1];
      data_out = data_in;
      strb_out = 4'hF;
      state_out = 1;
      ready_out = 0;
      wren_out = 1;
    end else if (&(strb_in[1:0]) == 1) begin
      addr_out = addr_in[18:1];
      data_out = {16'h0,data_in[15:0]};
      strb_out = 4'h3;
      state_out = 0;
      ready_out = 1;
      wren_out = 1;
    end else if (&(strb_in[3:2]) == 1) begin
      addr_out = addr_in[18:1];
      data_out = {16'h0,data_in[31:16]};
      strb_out = 4'h3;
      state_out = 0;
      ready_out = 1;
      wren_out = 1;
    end else if (strb_in[0] == 1) begin
      addr_out = addr_in[18:1];
      data_out = {24'h0,data_in[7:0]};
      strb_out = 4'h1;
      state_out = 0;
      ready_out = 1;
      wren_out = 1;
    end else if (strb_in[1] == 1) begin
      addr_out = addr_in[18:1];
      data_out = {16'h0,data_in[15:8],8'h0};
      strb_out = 4'h2;
      state_out = 0;
      ready_out = 1;
      wren_out = 1;
    end else if (strb_in[2] == 1) begin
      addr_out = addr_in[18:1];
      data_out = {24'h0,data_in[23:16]};
      strb_out = 4'h1;
      state_out = 0;
      ready_out = 1;
      wren_out = 1;
    end else if (strb_in[3] == 1) begin
      addr_out = addr_in[18:1];
      data_out = {16'h0,data_in[31:24],8'h0};
      strb_out = 4'h2;
      state_out = 0;
      ready_out = 1;
      wren_out = 1;
    end
  endfunction

  typedef struct packed{
    logic [0  : 0] state;
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
          transform(sram_addr,sram_wdata,sram_wstrb,v.addr,v.data,v.strb,v.state,v.ready,v.wren,v.rden);
        end
        v.d = v.data[15:0];
        v.a = v.addr[17:0];
        v.lb = v.strb[0];
        v.ub = v.strb[1];
        v.ce = v.rden | v.wren;
        v.oe = v.rden;
        v.we = v.wren;
        if (v.rden == 1) begin
          v.rdata[15:0] = sram_d;
        end
      end
      1 : begin
        v.state = 0;
        v.d = v.data[31:16];
        v.a = v.addr + 1;
        v.lb = v.strb[2];
        v.ub = v.strb[3];
        v.ce = v.rden | v.wren;
        v.oe = v.rden;
        v.we = v.wren;
        if (v.rden == 1) begin
          v.rdata[31:16] = sram_d;
        end
        v.ready = 1;
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

    sram_d = v.we == 1 ? v.d : 16'hZZZZ;
    sram_a = v.a;
    sram_lb_n = ~v.lb;
    sram_ub_n = ~v.ub;
    sram_ce_n = ~v.ce;
    sram_oe_n = ~v.oe;
    sram_we_n = ~v.we;

  end

  assign sram_rdata = r.rdata;
  assign sram_ready = r.ready;

  always_ff @ (posedge clock) begin
    if (reset == 1) begin
      r <= init_register;
    end else begin
      r <= rin;
    end
  end

endmodule
