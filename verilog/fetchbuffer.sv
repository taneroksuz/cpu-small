package fetch_wires;
  timeunit 1ns;
  timeprecision 1ps;

  import configure::*;

  typedef struct packed{
    logic [0 : 0] wen;
    logic [fetchbuffer_depth-1 : 0] wid;
    logic [fetchbuffer_depth-1 : 0] rid1;
    logic [fetchbuffer_depth-1 : 0] rid2;
    logic [32 : 0] wval;
  } fetchbuffer_data_in_type;

  typedef struct packed{
    logic [32 : 0] rval1;
    logic [32 : 0] rval2;
  } fetchbuffer_data_out_type;

endpackage

import configure::*;
import constants::*;
import wires::*;
import fetch_wires::*;

module fetchbuffer_data
(
  input logic clock,
  input fetchbuffer_data_in_type fetchbuffer_data_in,
  output fetchbuffer_data_out_type fetchbuffer_data_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [32 : 0] fetchbuffer_data_array[0:2**fetchbuffer_depth-1] = '{default:'0};

  assign fetchbuffer_data_out.rval1 = fetchbuffer_data_array[fetchbuffer_data_in.rid1];
  assign fetchbuffer_data_out.rval2 = fetchbuffer_data_array[fetchbuffer_data_in.rid2];

  always_ff @(posedge clock) begin
    if (fetchbuffer_data_in.wen == 1) begin
      fetchbuffer_data_array[fetchbuffer_data_in.wid] <= fetchbuffer_data_in.wval;
    end
  end

endmodule

module fetchbuffer_ctrl
(
  input logic reset,
  input logic clock,
  input fetchbuffer_data_out_type fetchbuffer_data_out,
  output fetchbuffer_data_in_type fetchbuffer_data_in,
  input mem_in_type fetchbuffer_in,
  output mem_out_type fetchbuffer_out,
  input mem_out_type imem_out,
  output mem_in_type imem_in
);
  timeunit 1ns;
  timeprecision 1ps;

  localparam [fetchbuffer_depth : 0] limit = {{fetchbuffer_depth{1'b1}},1'b0};

  typedef struct packed{
    logic [fetchbuffer_depth-1:0] wid;
    logic [fetchbuffer_depth-1:0] rid1;
    logic [fetchbuffer_depth-1:0] rid2;
    logic [fetchbuffer_depth:0] count;
    logic [fetchbuffer_depth:0] step;
    logic [0:0] wren;
    logic [0:0] rden;
    logic [0:0] wen;
    logic [0:0] ren1;
    logic [0:0] ren2;
    logic [32:0] wval;
    logic [32:0] rval1;
    logic [32:0] rval2;
    logic [0:0] comp;
    logic [0:0] valid;
    logic [0:0] spec;
    logic [0:0] fence;
    logic [1:0] mode;
    logic [31:0] addr;
    logic [31:0] rdata;
    logic [0:0] error;
    logic [0:0] ready;
  } reg_type;

  parameter reg_type init_reg = '{
    wid : 0,
    rid1 : 0,
    rid2 : 1,
    count : 0,
    step : 0,
    wren : 0,
    rden : 0,
    wen : 0,
    ren1 : 0,
    ren2 : 0,
    wval : 0,
    rval1 : 0,
    rval2 : 0,
    comp : 0,
    valid : 0,
    spec : 0,
    fence : 0,
    mode : m_mode,
    addr : 0,
    rdata : 0,
    error : 0,
    ready : 0
  };

  reg_type r,rin;
  reg_type v;

  always_comb begin

    v = r;

    v.wen = 0;
    v.ren1 = 0;
    v.ren2 = 0;

    v.step = 0;

    v.valid = 1;
    v.fence = 0;

    v.rdata = 0;
    v.error = 0;
    v.ready = 0;

    if (imem_out.mem_ready == 1) begin
      v.wren = 1;
      v.wval = {imem_out.mem_error,imem_out.mem_rdata};
      v.spec = 0;
    end

    if (fetchbuffer_in.mem_valid == 1) begin
      v.rden = 1;
      v.comp = fetchbuffer_in.mem_addr[1];
    end

    if (fetchbuffer_in.mem_spec == 1) begin
      v.spec = 1;
      v.mode = fetchbuffer_in.mem_mode;
      v.addr = {fetchbuffer_in.mem_addr[31:2],2'b00};
    end

    if (fetchbuffer_in.mem_fence == 1) begin
      v.fence = 1;
    end

    if (v.spec == 1 || v.fence == 1) begin
      v.wren = 0;
      v.rden = 0;
      v.wid = 0;
      v.rid1 = 0;
      v.rid2 = 1;
      v.count = 0;
    end

    if (v.wren == 1) begin
      if (v.count < limit) begin
        v.wen = 1;
        v.count = v.count + 2;
      end
    end

    fetchbuffer_data_in.wen = v.wen;
    fetchbuffer_data_in.wid = v.wid;
    fetchbuffer_data_in.wval = v.wval;

    fetchbuffer_data_in.rid1 = v.rid1;
    fetchbuffer_data_in.rid2 = v.rid2;

    v.rval1 = fetchbuffer_data_out.rval1;
    v.rval2 = fetchbuffer_data_out.rval2;

    if (v.wen == 1) begin
      v.wren = 0;
      v.wid = v.wid + 1;
      v.addr = v.addr + 4;
    end

    if (v.comp == 1) begin
      if (v.count > 4) begin
        v.rdata[15:0] = v.rval2[31:16];
        v.error = v.rval2[32];
        v.ready = 1;
      end else if (v.count > 2) begin
        v.rdata[15:0] = v.rval1[31:16];
        v.error = v.rval1[32];
        v.ready = 1;
      end
      if (v.count > 3) begin
        v.rdata[31:16] = v.rval1[15:0];
        v.error = v.error | v.rval1[32];
        v.ready = 1;
      end else if (v.count > 1) begin
        v.rdata[31:16] = v.wval[15:0];
        v.error = v.error | v.wval[32];
        v.ready = v.ready | ~(&(v.rdata[1:0]));
      end
    end else begin
      if (v.count > 3) begin
        v.rdata = v.rval1[31:0];
        v.error = v.rval1[32];
        v.ready = 1;
      end else if (v.count > 1) begin
        v.rdata = v.wval[31:0];
        v.error = v.wval[32];
        v.ready = 1;
      end
    end

    if (v.spec == 1 || v.fence == 1) begin
      v.ready = 0;
    end

    if (v.ready == 1) begin
      v.rden = 0;
      v.step = v.rdata[1:0] == 3 ? 2 : 1;
      v.count = v.count - v.step;
      if (v.step == 2 || (v.step == 1 && v.comp == 1)) begin
        v.rid2 = v.rid1;
        v.rid1 = v.rid1 + 1;
      end
    end

    imem_in.mem_valid = v.valid;
    imem_in.mem_fence = 0;
    imem_in.mem_spec = 0;
    imem_in.mem_instr = 1;
    imem_in.mem_mode = v.mode;
    imem_in.mem_addr = v.addr;
    imem_in.mem_wdata = 0;
    imem_in.mem_wstrb = 0;

    fetchbuffer_out.mem_rdata = v.rdata;
    fetchbuffer_out.mem_error = v.error;
    fetchbuffer_out.mem_ready = v.ready;

    rin = v;

  end

  always_ff @(posedge clock) begin
    if (reset == 1) begin
      r <= init_reg;
    end else begin
      r <= rin;
    end
  end

endmodule

module fetchbuffer
(
  input logic reset,
  input logic clock,
  input mem_in_type fetchbuffer_in,
  output mem_out_type fetchbuffer_out,
  input mem_out_type imem_out,
  output mem_in_type imem_in
);
  timeunit 1ns;
  timeprecision 1ps;

  fetchbuffer_data_in_type fetchbuffer_data_in;
  fetchbuffer_data_out_type fetchbuffer_data_out;

  fetchbuffer_data fetchbuffer_data_comp
  (
    .clock (clock),
    .fetchbuffer_data_in (fetchbuffer_data_in),
    .fetchbuffer_data_out (fetchbuffer_data_out)
  );

  fetchbuffer_ctrl fetchbuffer_ctrl_comp
  (
    .reset (reset),
    .clock (clock),
    .fetchbuffer_data_out (fetchbuffer_data_out),
    .fetchbuffer_data_in (fetchbuffer_data_in),
    .fetchbuffer_in (fetchbuffer_in),
    .fetchbuffer_out (fetchbuffer_out),
    .imem_out (imem_out),
    .imem_in (imem_in)
  );

endmodule
