import configure::*;
import wires::*;

module clic
#(
  parameter clic_sources    = 7,
  parameter clic_trigger    = 4,
  parameter clic_preemption = 4
)
(
  input logic rst,
  input logic clk,
  input logic rtc,
  input logic [0   : 0] clic_valid,
  input logic [0   : 0] clic_instr,
  input logic [31  : 0] clic_addr,
  input logic [31  : 0] clic_wdata,
  input logic [3   : 0] clic_wstrb,
  output logic [31 : 0] clic_rdata,
  output logic [0  : 0] clic_ready,
  output logic [0  : 0] clic_meip
);
  timeunit 1ns;
  timeprecision 1ps;

  localparam  clic_cfg_start  = 0;
  localparam  clic_cfg_end    = clic_cfg_start+1;
  localparam  clic_info_start = 4;
  localparam  clic_info_end   = clic_info_start + 4;
  localparam  clic_trig_start = 64;
  localparam  clic_trig_end   = clic_trig_start + 2**clic_trigger*4;
  localparam  clic_int_start  = 4096;
  localparam  clic_int_end    = clic_int_start + 2**clic_sources*4;

  logic [7  : 0] clic_cfg;
  logic [31 : 0] clic_info;

  logic [31 : 0] clic_int_trig [0:2**clic_trigger-1];

  logic [7  : 0] clic_int_ip [0:2**clic_sources-1];
  logic [7  : 0] clic_int_ie [0:2**clic_sources-1];
  logic [7  : 0] clic_int_attr [0:2**clic_sources-1];
  logic [7  : 0] clic_int_ctl [0:2**clic_sources-1];

  logic [31 : 0] rdata = 0;
  logic [0  : 0] ready = 0;

  logic [0  : 0] meip = 0;

  always_ff @(posedge clk) begin
    if (rst == 0) begin
      rdata <= 0;
      ready <= 0;
    end else begin
      rdata <= 0;
      ready <= 0;
      if (clic_valid == 1) begin
        if (clic_addr < clic_cfg_end) begin
          if (|clic_wstrb == 0) begin
            rdata[7:0] <= clic_cfg;
          end else begin
            clic_cfg <= clic_wdata[7:0];
          end
          ready <= 1;
        end else if (clic_addr >= clic_info_start && clic_addr < clic_info_end) begin
          if (|clic_wstrb == 0) begin
            rdata <= clic_info;
          end
          ready <= 1;
        end else if (clic_addr >= clic_trig_start && clic_addr < clic_trig_end) begin
          if (|clic_wstrb == 0) begin
            rdata <= clic_int_trig[clint_addr[clic_trigger+2:2]];
          end else begin
            clic_int_trig[clint_addr[clic_trigger+2:2]] <= clic_wdata;
          end
        end else if (clic_addr >= clic_int_start && clic_addr < clic_int_end) begin
          if (|clic_wstrb == 0) begin
            rdata[7:0] <= clic_int_ip[clint_addr[clic_sources+2:2]];
            rdata[15:8] <= clic_int_ie[clint_addr[clic_sources+2:2]];
            rdata[23:16] <= clic_int_attr[clint_addr[clic_sources+2:2]];
            rdata[31:24] <= clic_int_ctl[clint_addr[clic_sources+2:2]];
          end else begin
            if (clic_wstrb[0] == 1) begin
              clic_int_ip[clint_addr[clic_sources+2:2]] <= clic_wdata[7:0];
            end
            if (clic_wstrb[1] == 1) begin
              clic_int_ie[clint_addr[clic_sources+2:2]] <= clic_wdata[15:8];
            end
            if (clic_wstrb[2] == 1) begin
              clic_int_attr[clint_addr[clic_sources+2:2]] <= clic_wdata[31:24];
            end
            if (clic_wstrb[3] == 1) begin
              clic_int_ctl[clint_addr[clic_sources+2:2]] <= clic_wdata[23:16];
            end
          end
        end
      end
    end
  end

  assign clic_rdata = rdata;
  assign clic_ready = ready;

  assign clic_meip = meip;

endmodule
