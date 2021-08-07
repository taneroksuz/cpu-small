import configure::*;

module pll
(
  input logic refclk,
  input logic rst,
  output logic outclk_0,
  output logic outclk_1,
  output logic locked
);
  timeunit 1ns;
  timeprecision 1ps;

  logic clk_0 = 0;
  logic [31 : 0] count_0 = 0;

  logic clk_1 = 0;
  logic [31 : 0] count_1 = 0;

  always_ff @(posedge refclk) begin
    if (count_0 == clk_divider_pll) begin
      clk_0 <= ~clk_0;
      count_0 <= 0;
    end else begin
      count_0 <= count_0 + 1;
    end
    if (count_1 == clk_divider_rtc) begin
      clk_1 <= ~clk_1;
      count_1 <= 0;
    end else begin
      count_1 <= count_1 + 1;
    end
  end

  assign outclk_0 = clk_0;
  assign outclk_1 = clk_1;

  assign locked = ~rst;

endmodule
