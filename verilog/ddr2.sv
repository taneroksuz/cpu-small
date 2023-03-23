import configure::*;
import wires::*;

module ddr2
(
  input  logic reset,
  input  logic clock,
  input  logic clock_ddr2,
  input  logic [0  : 0] dmem_valid,
  input  logic [0  : 0] dmem_instr,
  input  logic [31 : 0] dmem_addr,
  input  logic [31 : 0] dmem_wdata,
  input  logic [3  : 0] dmem_wstrb,
  output logic [31 : 0] dmem_rdata,
  output logic [0  : 0] dmem_ready,
  output logic [12 : 0] ddr2_addr,
  output logic [2  : 0] ddr2_ba,
  output logic [0  : 0] ddr2_ras_n,
  output logic [0  : 0] ddr2_cas_n,
  output logic [0  : 0] ddr2_we_n,
  output logic [0  : 0] ddr2_ck_p,
  output logic [0  : 0] ddr2_ck_n,
  output logic [0  : 0] ddr2_cke,
  output logic [0  : 0] ddr2_cs_n,
  output logic [1  : 0] ddr2_dm,
  output logic [0  : 0] ddr2_odt,
  inout  logic [15 : 0] ddr2_dq,
  inout  logic [1  : 0] ddr2_dqs_p,
  inout  logic [1  : 0] ddr2_dqs_n
);
  timeunit 1ns;
  timeprecision 1ps;

  function void transform
  (
    input  logic [31 : 0] addr_in,
    input  logic [31 : 0] data_in,
    input  logic [3  : 0] strb_in,
    output logic [12 : 0] addr_out,
    output logic [31 : 0] data_out,
    output logic [3  : 0] strb_out,
    output logic [0  : 0] wren_out,
    output logic [0  : 0] rden_out
  );
    addr_out = 0;
    data_out = 0;
    strb_out = 0;
    wren_out = 0;
    rden_out = 0;
  endfunction

  typedef struct packed{
    logic [2  : 0] state;
    logic [31 : 0] data;
    logic [3  : 0] strb;
    logic [12 : 0] addr;
    logic [0  : 0] wren;
    logic [0  : 0] rden;
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
    rdata : 0,
    ready : 0
  };

  register_type r,rin,v;

  always_comb begin

    v = r;

    v.ready = 0;

    case(r.state)
      0 : begin
        v.state = 0;
        v.addr = 0;
        v.data = 0;
        v.strb = 0;
        v.wren = 0;
        v.rden = 0;
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

  end

  assign dmem_rdata = r.rdata;
  assign dmem_ready = r.ready;

  always_ff @ (posedge clock) begin
    if (reset == 1) begin
      r <= init_register;
    end else begin
      r <= rin;
    end
  end

endmodule
