import configure::*;
import wires::*;

module timer
(
  input logic rst,
  input logic clk,
  input logic rtc,
  input logic [0   : 0] timer_valid,
  input logic [0   : 0] timer_instr,
  input logic [31  : 0] timer_addr,
  input logic [31  : 0] timer_wdata,
  input logic [3   : 0] timer_wstrb,
  output logic [31 : 0] timer_rdata,
  output logic [0  : 0] timer_ready,
  output logic timer_irpt
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [63:0] timer = 0;
  logic [63:0] timer_cmp = 0;

  logic [31:0] rdata;
  logic [0:0] ready;

  always_ff @(posedge clk) begin
    if (rst == 0) begin
      timer_cmp <= 0;
      rdata <= 0;
      ready <= 0;
    end else begin
      ready <= 0;
      if (timer_valid == 1) begin
        if (timer_addr == 0) begin
          if (|timer_wstrb == 0) begin
            rdata <= timer_cmp[31:0];
            ready <= 1;
          end else begin
            if (timer_wstrb[0] == 1) begin
              timer_cmp[7:0] <= timer_wdata[7:0];
              ready <= 1;
            end
            if (timer_wstrb[1] == 1) begin
              timer_cmp[15:8] <= timer_wdata[15:8];
              ready <= 1;
            end
            if (timer_wstrb[2] == 1) begin
              timer_cmp[23:16] <= timer_wdata[23:16];
              ready <= 1;
            end
            if (timer_wstrb[3] == 1) begin
              timer_cmp[31:24] <= timer_wdata[31:24];
              ready <= 1;
            end
          end
        end else if (timer_addr == 4) begin
          if (|timer_wstrb == 0) begin
            rdata <= timer_cmp[63:32];
            ready <= 1;
          end else begin
            if (timer_wstrb[0] == 1) begin
              timer_cmp[39:32] <= timer_wdata[7:0];
              ready <= 1;
            end
            if (timer_wstrb[1] == 1) begin
              timer_cmp[47:40] <= timer_wdata[15:8];
              ready <= 1;
            end
            if (timer_wstrb[2] == 1) begin
              timer_cmp[55:48] <= timer_wdata[23:16];
              ready <= 1;
            end
            if (timer_wstrb[3] == 1) begin
              timer_cmp[63:56] <= timer_wdata[31:24];
              ready <= 1;
            end
          end
        end else if (timer_addr == 8) begin
          if (|timer_wstrb == 0) begin
            rdata <= timer[31:0];
            ready <= 1;
          end
        end else if (timer_addr == 12) begin
          if (|timer_wstrb == 0) begin
            rdata <= timer[63:32];
            ready <= 1;
          end
        end
      end
    end
  end

  assign timer_rdata = rdata;
  assign timer_ready = ready;

  always_ff @(posedge clk) begin
    if (rst == 0) begin
      timer_irpt <= 0;
    end else begin
      if (timer >= timer_cmp) begin
        timer_irpt <= 1;
      end else begin
        timer_irpt <= 0;
      end
    end
  end

  always_ff @(posedge rtc) begin
    timer <= timer + 1;
  end

endmodule
