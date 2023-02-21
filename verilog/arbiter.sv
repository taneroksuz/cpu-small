import wires::*;
import constants::*;

module arbiter(
  input logic rst,
  input logic clk,
  input mem_in_type imem_in,
  output mem_out_type imem_out,
  input mem_in_type dmem_in,
  output mem_out_type dmem_out,
  input pmp_out_type pmp_out,
  output pmp_in_type pmp_in,
  output logic [0  : 0] memory_valid,
  output logic [0  : 0] memory_instr,
  output logic [31 : 0] memory_addr ,
  output logic [31 : 0] memory_wdata,
  output logic [3  : 0] memory_wstrb,
  input logic [31  : 0] memory_rdata,
  input logic [0   : 0] memory_ready
);
  timeunit 1ns;
  timeprecision 1ps;

  parameter [1:0] no_access = 0;
  parameter [1:0] instr_access = 1;
  parameter [1:0] data_access = 2;

  typedef struct packed{
    logic [1:0] access_type;
    logic [0:0] mem_valid;
    logic [0:0] mem_instr;
    logic [1:0] mem_mode;
    logic [31:0] mem_addr;
    logic [31:0] mem_wdata;
    logic [3:0] mem_wstrb;
    logic [0:0] mem_error;
  } reg_type;

  parameter reg_type init_reg = '{
    access_type : no_access,
    mem_valid : 1,
    mem_instr : 1,
    mem_mode : m_mode,
    mem_addr : 0,
    mem_wdata : 0,
    mem_wstrb : 0,
    mem_error : 0
  };

  reg_type r,rin;
  reg_type v;

  always_comb begin

    v = r;

    if (memory_ready == 1 || v.mem_error == 1) begin
      v.access_type = no_access;
    end

    if (v.access_type == no_access) begin
      if (dmem_in.mem_valid == 1) begin
        v.access_type = data_access;
        v.mem_valid = dmem_in.mem_valid;
        v.mem_instr = dmem_in.mem_instr;
        v.mem_mode = dmem_in.mem_mode;
        v.mem_addr = dmem_in.mem_addr;
        v.mem_wdata = dmem_in.mem_wdata;
        v.mem_wstrb = dmem_in.mem_wstrb;
      end else if (imem_in.mem_valid == 1) begin
        v.access_type = instr_access;
        v.mem_valid = imem_in.mem_valid;
        v.mem_instr = imem_in.mem_instr;
        v.mem_mode = imem_in.mem_mode;
        v.mem_addr = imem_in.mem_addr;
        v.mem_wdata = imem_in.mem_wdata;
        v.mem_wstrb = imem_in.mem_wstrb;
      end
    end

    pmp_in.mem_valid = v.mem_valid;
    pmp_in.mem_mode = v.mem_mode;
    pmp_in.mem_instr = v.mem_instr;
    pmp_in.mem_addr = v.mem_addr;
    pmp_in.mem_wstrb = v.mem_wstrb;

    v.mem_error = pmp_out.mem_error;

    if (v.mem_error == 1) begin
      memory_valid = 0;
      memory_instr = 0;
      memory_addr = 0;
      memory_wdata = 0;
      memory_wstrb = 0;
    end else if (v.access_type != no_access) begin
      memory_valid = v.mem_valid;
      memory_instr = v.mem_instr;
      memory_addr = v.mem_addr;
      memory_wdata = v.mem_wdata;
      memory_wstrb = v.mem_wstrb;
    end else begin
      memory_valid = 0;
      memory_instr = 0;
      memory_addr = 0;
      memory_wdata = 0;
      memory_wstrb = 0;
    end

    rin = v;

    if (r.access_type == instr_access) begin
      if (r.mem_error == 1) begin
        imem_out.mem_ready = 1;
        imem_out.mem_error = 1;
        imem_out.mem_rdata = 0;
      end else begin
        imem_out.mem_ready = memory_ready;
        imem_out.mem_error = 0;
        imem_out.mem_rdata = memory_rdata;
      end
    end else begin
      imem_out.mem_ready = 0;
      imem_out.mem_error = 0;
      imem_out.mem_rdata = 0;
    end

    if (r.access_type == data_access) begin
      if (r.mem_error == 1) begin
        dmem_out.mem_ready = 1;
        dmem_out.mem_error = 1;
        dmem_out.mem_rdata = 0;
      end else begin
        dmem_out.mem_ready = memory_ready;
        dmem_out.mem_error = 0;
        dmem_out.mem_rdata = memory_rdata;
      end
    end else begin
      dmem_out.mem_ready = 0;
      dmem_out.mem_error = 0;
      dmem_out.mem_rdata = 0;
    end

  end

  always_ff @(posedge clk) begin
    if (rst == 0) begin
      r <= init_reg;
    end else begin
      r <= rin;
    end
  end

endmodule
