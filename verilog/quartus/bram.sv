import configure::*;

module bram
(
  input logic reset,
  input logic clock,
  input logic [0   : 0] bram_valid,
  input logic [0   : 0] bram_instr,
  input logic [31  : 0] bram_addr,
  input logic [31  : 0] bram_wdata,
  input logic [3   : 0] bram_wstrb,
  output logic [31 : 0] bram_rdata,
  output logic [0  : 0] bram_ready
);
	timeunit 1ns;
	timeprecision 1ps;

  logic [31 : 0] bram_block[0:31];

  logic [4  : 0] raddr;

  logic [31 : 0] rdata;
  logic [0  : 0] ready;

  initial begin
    bram_block[0] = 32'h41014081;
    bram_block[1] = 32'h42014181;
    bram_block[2] = 32'h43014281;
    bram_block[3] = 32'h44014381;
    bram_block[4] = 32'h45014481;
    bram_block[5] = 32'h46014581;
    bram_block[6] = 32'h47014681;
    bram_block[7] = 32'h48014781;
    bram_block[8] = 32'h49014881;
    bram_block[9] = 32'h4A014981;
    bram_block[10] = 32'h4B014A81;
    bram_block[11] = 32'h4C014B81;
    bram_block[12] = 32'h4D014C81;
    bram_block[13] = 32'h4E014D81;
    bram_block[14] = 32'h4F014E81;
    bram_block[15] = 32'h02B74F81;
    bram_block[16] = 32'h03370100;
    bram_block[17] = 32'h03B70800;
    bram_block[18] = 32'hCE030008;
    bram_block[19] = 32'h00230002;
    bram_block[20] = 32'h0E8501C3;
    bram_block[21] = 32'hCAE30305;
    bram_block[22] = 32'h0337FE7E;
    bram_block[23] = 32'h00670800;
    bram_block[24] = 32'h00000003;
    bram_block[25] = 32'h00000000;
    bram_block[26] = 32'h00000000;
    bram_block[27] = 32'h00000000;
    bram_block[28] = 32'h00000000;
    bram_block[29] = 32'h00000000;
    bram_block[30] = 32'h00000000;
    bram_block[31] = 32'h00000000;
  end

  assign raddr = bram_addr[6:2];

  always_ff @(posedge clock) begin
    
    rdata <= bram_block[raddr];

  end

  always_ff @(posedge clock) begin

    if (bram_valid == 1) begin
      ready <= 1;
    end else begin
      ready <= 0;
    end

  end

  assign bram_rdata = rdata;
  assign bram_ready = ready;


endmodule
