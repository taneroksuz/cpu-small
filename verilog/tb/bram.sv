import configure::*;

module bram
(
  input logic rst,
  input logic clk,
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

  logic [31 : 0] bram_block[0:2**bram_depth-1];

  logic [31 : 0] host[0:0];

  logic [31 : 0] rdata;
  logic [0  : 0] ready;

  task check;
    input logic [31 : 0] bram_block[0:2**bram_depth-1];
    input logic [31 : 0] bram_addr;
    input logic [31 : 0] bram_wdata;
    input logic [3  : 0] bram_wstrb;
    input logic [31 : 0] host;
    logic [0 : 0] ok;
    begin
      ok = 0;
      if (|bram_block[host[bram_depth+1:2]] == 0 & bram_addr[(bram_depth+1):2] == host[bram_depth+1:2]  & |bram_wstrb == 1) begin
        ok = 1;
      end
      if (ok == 1) begin
        if (bram_wdata == 32'h1) begin
          $display("TEST SUCCEEDED");
          $finish;
        end else begin
          $display("TEST FAILED");
          $finish;
        end
      end
    end
  endtask

  initial begin
    $readmemh("bram.dat", bram_block);
    $readmemh("host.dat", host);
  end

  always_ff @(posedge clk) begin

    if (bram_valid == 1) begin

      check(bram_block,bram_addr,bram_wdata,bram_wstrb,host[0]);

      if (bram_addr == uart_base_addr) begin
        if (bram_wstrb[0] == 1) begin
          $write("%c",bram_wdata[7:0]);
        end
      end else if (bram_addr[31:2] >= 2**bram_depth) begin
        $display("ADDRESS EXCEEDS MEMORY");
        $finish;
      end else begin
        if (bram_wstrb[0] == 1)
          bram_block[bram_addr[(bram_depth+1):2]][7:0] <= bram_wdata[7:0];
        if (bram_wstrb[1] == 1)
          bram_block[bram_addr[(bram_depth+1):2]][15:8] <= bram_wdata[15:8];
        if (bram_wstrb[2] == 1)
          bram_block[bram_addr[(bram_depth+1):2]][23:16] <= bram_wdata[23:16];
        if (bram_wstrb[3] == 1)
          bram_block[bram_addr[(bram_depth+1):2]][31:24] <= bram_wdata[31:24];
      end

      rdata <= bram_block[bram_addr[(bram_depth+1):2]];
      ready <= 1;

    end else begin

      ready <= 0;

    end

  end

  assign bram_rdata = rdata;
  assign bram_ready = ready;


endmodule
