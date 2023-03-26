import configure::*;
import wires::*;

module sram
(
  input  logic reset,
  input  logic clock,
  input  logic [0  : 0] smem_valid,
  input  logic [0  : 0] smem_instr,
  input  logic [31 : 0] smem_addr,
  input  logic [31 : 0] smem_wdata,
  input  logic [3  : 0] smem_wstrb,
  output logic [31 : 0] smem_rdata,
  output logic [0  : 0] smem_ready,
  inout  logic [15 : 0] sram_dq,
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
      addr_out = {addr_in[18:2],1'b0};
      data_out = 0;
      strb_out = 4'hF;
      state_out = 1;
      ready_out = 0;
      rden_out = 1;
    end else if (&(strb_in[3:0]) == 1) begin
      addr_out = {addr_in[18:2],1'b0};
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
    logic [15 : 0] s_dq;
    logic [17 : 0] s_a;
    logic [0  : 0] s_ub;
    logic [0  : 0] s_lb;
    logic [0  : 0] s_ce;
    logic [0  : 0] s_oe;
    logic [0  : 0] s_we;
    logic [31 : 0] rdata;
    logic [0  : 0] ready;
  } register_type;

  parameter register_type init_register = '{
    state : 0,
    data : 0,
    strb : 0,
    addr : 0,
    wren : 0,
    rden : 0,
    s_dq : 0,
    s_a : 0,
    s_lb : 0,
    s_ub : 0,
    s_ce : 0,
    s_oe : 0,
    s_we : 0,
    rdata : 0,
    ready : 0
  };

  register_type r,rin,v;

  always_comb begin

    v = r;

    v.s_dq = 0;
    v.s_a = 0;
    v.s_lb = 0;
    v.s_ub = 0;
    v.s_ce = 0;
    v.s_oe = 0;
    v.s_we = 0;

    v.ready = 0;

    case(r.state)
      0 : begin
        v.state = 0;
        v.addr = 0;
        v.data = 0;
        v.strb = 0;
        v.wren = 0;
        v.rden = 0;
        if (smem_valid == 1) begin
          transform(smem_addr,smem_wdata,smem_wstrb,v.addr,v.data,v.strb,v.state,v.ready,v.wren,v.rden);
        end
        v.s_dq = v.data[15:0];
        v.s_a = v.addr;
        v.s_lb = v.strb[0];
        v.s_ub = v.strb[1];
        v.s_ce = v.rden | v.wren;
        v.s_oe = v.rden;
        v.s_we = v.wren;
        if (v.rden == 1) begin
          v.rdata[15:0] = sram_dq;
        end
      end
      1 : begin
        v.state = 0;
        v.s_dq = v.data[31:16];
        v.s_a = v.addr + 1;
        v.s_lb = v.strb[2];
        v.s_ub = v.strb[3];
        v.s_ce = v.rden | v.wren;
        v.s_oe = v.rden;
        v.s_we = v.wren;
        if (v.rden == 1) begin
          v.rdata[31:16] = sram_dq;
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

    sram_dq = v.s_we == 1 ? v.s_dq : 16'hZZZZ;
    sram_a = v.s_a;
    sram_lb_n = ~v.s_lb;
    sram_ub_n = ~v.s_ub;
    sram_ce_n = ~v.s_ce;
    sram_oe_n = ~v.s_oe;
    sram_we_n = ~v.s_we;

  end

  assign smem_rdata = r.rdata;
  assign smem_ready = r.ready;

  always_ff @ (posedge clock) begin
    if (reset == 1) begin
      r <= init_register;
    end else begin
      r <= rin;
    end
  end

endmodule
