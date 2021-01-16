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

  logic [0:0] access_type;
  logic [0:0] release_type;

  always_comb begin

    access_type = dmem_in.mem_valid == 1 ? data_access : instr_access;

    if (release_type == data_access && memory_ready == 0) begin
      memory_valid = 0;
      memory_instr = 0;
      memory_addr = 0;
      memory_wdata = 0;
      memory_wstrb = 0;
    end else begin
      memory_valid = (access_type == instr_access) ? imem_in.mem_valid : dmem_in.mem_valid;
      memory_instr = (access_type == instr_access) ? imem_in.mem_instr : dmem_in.mem_instr;
      memory_addr = (access_type == instr_access) ? imem_in.mem_addr : dmem_in.mem_addr;
      memory_wdata = (access_type == instr_access) ? imem_in.mem_wdata : dmem_in.mem_wdata;
      memory_wstrb = (access_type == instr_access) ? imem_in.mem_wstrb : dmem_in.mem_wstrb;
    end

    imem_out.mem_rdata = (release_type == instr_access) ? memory_rdata : 0;
    imem_out.mem_ready = (release_type == instr_access) ? memory_ready : 0;

    dmem_out.mem_rdata = (release_type == data_access) ? memory_rdata : 0;
    dmem_out.mem_ready = (release_type == data_access) ? memory_ready : 0;

  end

  always_ff @(posedge clk) begin
    if (rst == 0) begin
      release_type <= instr_access;
    end else begin
      if (release_type == instr_access) begin
        if (access_type == data_access) begin
          release_type <= data_access;
        end
      end else if (release_type == data_access) begin
        if (memory_ready == 1 & access_type == instr_access) begin
          release_type <= instr_access;
        end
      end
    end
  end

endmodule
