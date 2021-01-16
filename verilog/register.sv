import wires::*;

module register
(
  input logic rst,
  input logic clk,
  input register_in_type register_in,
  output register_out_type register_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [31:0] reg_file[0:31];

  always_comb begin
    register_out.rdata1 = reg_file[register_in.raddr1];
    register_out.rdata2 = reg_file[register_in.raddr2];
  end

  always_ff @(posedge clk) begin
    if (rst == 0) begin
      reg_file <= '{default:'0};
    end else begin
      if (register_in.wren == 1) begin
        reg_file[register_in.waddr] <= register_in.wdata;
      end
    end
  end

endmodule
