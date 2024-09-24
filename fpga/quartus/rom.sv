import configure::*;

module rom (
    input logic reset,
    input logic clock,
    input mem_in_type rom_in,
    output mem_out_type rom_out
);
  timeunit 1ns; timeprecision 1ps;

  logic [ 5 : 0] raddr;

  logic [31 : 0] rdata;
  logic [ 0 : 0] ready;

  assign raddr = rom_in.mem_addr[7:2];

  always_ff @(posedge clock) begin

    case (raddr)
      6'b000000: rdata <= 32'h41014081;
      6'b000001: rdata <= 32'h42014181;
      6'b000010: rdata <= 32'h43014281;
      6'b000011: rdata <= 32'h44014381;
      6'b000100: rdata <= 32'h45014481;
      6'b000101: rdata <= 32'h46014581;
      6'b000110: rdata <= 32'h47014681;
      6'b000111: rdata <= 32'h48014781;
      6'b001000: rdata <= 32'h49014881;
      6'b001001: rdata <= 32'h4A014981;
      6'b001010: rdata <= 32'h4B014A81;
      6'b001011: rdata <= 32'h4C014B81;
      6'b001100: rdata <= 32'h4D014C81;
      6'b001101: rdata <= 32'h4E014D81;
      6'b001110: rdata <= 32'h4F014E81;
      6'b001111: rdata <= 32'h62F94F81;
      6'b010000: rdata <= 32'h60028293;
      6'b010001: rdata <= 32'h3002A073;
      6'b010010: rdata <= 32'hA07342A1;
      6'b010011: rdata <= 32'h62853002;
      6'b010100: rdata <= 32'h80028293;
      6'b010101: rdata <= 32'h3042A073;
      6'b010110: rdata <= 32'h00000297;
      6'b010111: rdata <= 32'h02028293;
      6'b011000: rdata <= 32'h30529073;
      6'b011001: rdata <= 32'h010002B7;
      6'b011010: rdata <= 32'h03370291;
      6'b011011: rdata <= 32'h43818000;
      6'b011100: rdata <= 32'h00080E37;
      6'b011101: rdata <= 32'h0001A001;
      6'b011110: rdata <= 32'h800002B7;
      6'b011111: rdata <= 32'h237302E1;
      6'b100000: rdata <= 32'h99E33420;
      6'b100001: rdata <= 32'h8E83FE62;
      6'b100010: rdata <= 32'h00230002;
      6'b100011: rdata <= 32'h030501D3;
      6'b100100: rdata <= 32'hD4630385;
      6'b100101: rdata <= 32'h007301C3;
      6'b100110: rdata <= 32'h00B73020;
      6'b100111: rdata <= 32'h80678000;
      6'b101000: rdata <= 32'h00000000;
      6'b101001: rdata <= 32'h00000000;
      6'b101010: rdata <= 32'h00000000;
      6'b101011: rdata <= 32'h00000000;
      6'b101100: rdata <= 32'h00000000;
      6'b101101: rdata <= 32'h00000000;
      6'b101110: rdata <= 32'h00000000;
      6'b101111: rdata <= 32'h00000000;
      6'b110000: rdata <= 32'h00000000;
      6'b110001: rdata <= 32'h00000000;
      6'b110010: rdata <= 32'h00000000;
      6'b110011: rdata <= 32'h00000000;
      6'b110100: rdata <= 32'h00000000;
      6'b110101: rdata <= 32'h00000000;
      6'b110110: rdata <= 32'h00000000;
      6'b110111: rdata <= 32'h00000000;
      6'b111000: rdata <= 32'h00000000;
      6'b111001: rdata <= 32'h00000000;
      6'b111010: rdata <= 32'h00000000;
      6'b111011: rdata <= 32'h00000000;
      6'b111100: rdata <= 32'h00000000;
      6'b111101: rdata <= 32'h00000000;
      6'b111110: rdata <= 32'h00000000;
      6'b111111: rdata <= 32'h00000000;
    endcase

  end

  always_ff @(posedge clock) begin

    if (rom_in.mem_valid == 1) begin
      ready <= 1;
    end else begin
      ready <= 0;
    end

  end

  assign rom_out.mem_rdata = rdata;
  assign rom_out.mem_error = 0;
  assign rom_out.mem_ready = ready;


endmodule
