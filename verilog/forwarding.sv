import wires::*;

module forwarding
(
  input forwarding_in_type forwarding_in,
  output forwarding_out_type forwarding_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [31:0] res1;
  logic [31:0] res2;

  always_comb begin
    res1 = forwarding_in.register_rdata1;
    res2 = forwarding_in.register_rdata2;
    if (forwarding_in.execute_wren == 1 & forwarding_in.register_raddr1 == forwarding_in.execute_waddr) begin
      res1 = forwarding_in.execute_wdata;
    end
    if (forwarding_in.execute_wren == 1 & forwarding_in.register_raddr2 == forwarding_in.execute_waddr) begin
      res2 = forwarding_in.execute_wdata;
    end
    forwarding_out.data1 = res1;
    forwarding_out.data2 = res2;
  end

endmodule
