import wires::*;

module arbiter(
  input logic rst,
  input logic clk,
  input mem_in_type imem_in,
  output mem_out_type imem_out,
  input mem_in_type dmem_in,
  output mem_out_type dmem_out,
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

  parameter [0:0] instr_access = 0;
  parameter [0:0] data_access = 1;

  typedef struct packed{
    logic [0:0] access_type;
    logic [0:0] release_type;
    logic [0:0] imem_valid;
    logic [0:0] imem_instr;
    logic [31:0] imem_addr;
    logic [31:0] imem_wdata;
    logic [3:0] imem_wstrb;
    logic [0:0] dmem_valid;
    logic [0:0] dmem_instr;
    logic [31:0] dmem_addr;
    logic [31:0] dmem_wdata;
    logic [3:0] dmem_wstrb;
    logic [0:0] mem_valid;
    logic [0:0] mem_instr;
    logic [31:0] mem_addr;
    logic [31:0] mem_wdata;
    logic [3:0] mem_wstrb;
  } reg_type;

  parameter reg_type init_reg = '{
    access_type : instr_access,
    release_type : instr_access,
    imem_valid : 0,
    imem_instr : 0,
    imem_addr : 0,
    imem_wdata : 0,
    imem_wstrb : 0,
    dmem_valid : 0,
    dmem_instr : 0,
    dmem_addr : 0,
    dmem_wdata : 0,
    dmem_wstrb : 0,
    mem_valid : 1,
    mem_instr : 1,
    mem_addr : 0,
    mem_wdata : 0,
    mem_wstrb : 0
  };

  reg_type r,rin;
  reg_type v;

  always_comb begin

    v = r;

    if (memory_ready == 1) begin
      if (r.release_type == data_access) begin
        v.dmem_valid = 0;
      end
      if (r.release_type == instr_access) begin
        v.imem_valid = 0;
      end
    end

    if (dmem_in.mem_valid == 1) begin
      v.dmem_valid = dmem_in.mem_valid;
      v.dmem_instr = dmem_in.mem_instr;
      v.dmem_addr = dmem_in.mem_addr;
      v.dmem_wdata = dmem_in.mem_wdata;
      v.dmem_wstrb = dmem_in.mem_wstrb;
    end

    if (imem_in.mem_valid == 1) begin
      v.imem_valid = imem_in.mem_valid;
      v.imem_instr = imem_in.mem_instr;
      v.imem_addr = imem_in.mem_addr;
      v.imem_wdata = imem_in.mem_wdata;
      v.imem_wstrb = imem_in.mem_wstrb;
    end

    if (memory_ready == 1) begin
      if (v.dmem_valid == 1) begin
        v.access_type = data_access;
        v.mem_valid = v.dmem_valid;
        v.mem_instr = v.dmem_instr;
        v.mem_addr = v.dmem_addr;
        v.mem_wdata = v.dmem_wdata;
        v.mem_wstrb = v.dmem_wstrb;
      end else if (v.imem_valid == 1) begin
        v.access_type = instr_access;
        v.mem_valid = v.imem_valid;
        v.mem_instr = v.imem_instr;
        v.mem_addr = v.imem_addr;
        v.mem_wdata = v.imem_wdata;
        v.mem_wstrb = v.imem_wstrb;
      end
    end

    if (v.release_type == instr_access) begin
      if (memory_ready == 1 && v.access_type == data_access) begin
        v.release_type = data_access;
      end
    end else if (v.release_type == data_access) begin
      if (memory_ready == 1 && v.access_type == instr_access) begin
        v.release_type = instr_access;
      end
    end

    memory_valid = v.mem_valid;
    memory_instr = v.mem_instr;
    memory_addr = v.mem_addr;
    memory_wdata = v.mem_wdata;
    memory_wstrb = v.mem_wstrb;

    rin = v;

    if (r.release_type == instr_access) begin
      imem_out.mem_ready = memory_ready;
      imem_out.mem_rdata = memory_rdata;
    end else begin
      imem_out.mem_ready = 0;
      imem_out.mem_rdata = 0;
    end

    if (r.release_type == data_access) begin
      dmem_out.mem_ready = memory_ready;
      dmem_out.mem_rdata = memory_rdata;
    end else begin
      dmem_out.mem_ready = 0;
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
