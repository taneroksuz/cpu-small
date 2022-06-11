import wires::*;

module register
(
  input logic rst,
  input logic clk,
  input register_read_in_type register_rin,
  input register_write_in_type register_win,
  output register_out_type register_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [31:0] reg_file[0:31];

  always_comb begin
    register_out.rdata1 = reg_file[register_rin.raddr1];
    register_out.rdata2 = reg_file[register_rin.raddr2];
  end

  always_ff @(posedge clk) begin
    if (rst == 0) begin
      reg_file <= '{default:'0};
    end else begin
      if (register_win.wren == 1 && register_win.waddr != 0) begin
        reg_file[register_win.waddr] <= register_win.wdata;
      end
    end
  end

endmodule
