import wires::*;

module forwarding
(
  input forwarding_register_in_type forwarding_rin,
  input forwarding_execute_in_type forwarding_ein,
  output forwarding_out_type forwarding_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [31:0] res1;
  logic [31:0] res2;

  always_comb begin
    res1 = forwarding_rin.rdata1;
    res2 = forwarding_rin.rdata2;
    if (forwarding_ein.wren == 1 & forwarding_rin.raddr1 == forwarding_ein.waddr) begin
      res1 = forwarding_ein.wdata;
    end
    if (forwarding_ein.wren == 1 & forwarding_rin.raddr2 == forwarding_ein.waddr) begin
      res2 = forwarding_ein.wdata;
    end
    forwarding_out.data1 = res1;
    forwarding_out.data2 = res2;
  end

endmodule
