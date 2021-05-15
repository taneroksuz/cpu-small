module testbench;

  timeunit 1ns;
  timeprecision 1ps;

  logic rst;
  logic clk;
  logic rx;
  logic tx;

  initial begin
    rx = 0;
    clk = 1;
  end

  always begin
    #10;
    clk = !clk;
  end

  initial begin
    rst = 0;
    #100;
    rst = 1;
  end

  top_cpu top_cpu_comp
  (
    .rst (rst),
    .clk (clk),
    .rx (rx),
    .tx (tx)
  );

endmodule
