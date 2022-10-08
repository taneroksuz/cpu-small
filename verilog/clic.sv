import configure::*;
import constants::*;
import wires::*;

module clic
#(
  parameter clic_interrupt = 128,
  parameter clic_trigger   = 32,
  parameter clic_level     = 16,
  parameter clic_intctlbit = 8
)
(
  input logic rst,
  input logic clk,
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
  localparam  clic_trig_end   = clic_trig_start + clic_trigger*4;
  localparam  clic_int_start  = 4096;
  localparam  clic_int_end    = clic_int_start + clic_interrupt*4;

  typedef struct packed{
    logic [6 : 5] nmbits;
    logic [4 : 1] nlbits;
    logic [0 : 0] nvbits;
  } clic_cfg_type;

  parameter clic_cfg_type init_clic_cfg = '{
    nmbits : 0,
    nlbits : 0,
    nvbits : 0
  };

  typedef struct packed{
    logic [30 : 25] num_trigger;
    logic [24 : 21] num_intctlbit;
    logic [20 : 17] arch_version;
    logic [16 : 13] impl_version;
    logic [12 :  0] num_interrupt;
  } clic_info_type;

  parameter clic_info_type init_clic_info = '{
    num_trigger : clic_trigger,
    num_intctlbit : clic_intctlbit,
    arch_version : 0,
    impl_version : 0,
    num_interrupt : clic_interrupt
  };

  typedef struct packed{
    logic [31 : 31] enable;
    logic [12 :  0] num_interrupt;
  } clic_trig_type;

  parameter clic_trig_type init_clic_trig = '{
    enable : 0,
    num_interrupt : 0
  };

  typedef struct packed{
    logic [7 : 5] mode;
    logic [2 : 1] trig;
    logic [0 : 0] shv;
  } clic_attr_type;

  parameter clic_attr_type init_clic_attr = '{
    mode : 0,
    trig : 0,
    shv : 0
  };

  clic_cfg_type clic_cfg;
  clic_info_type clic_info;

  clic_trig_type clic_int_trig [0:clic_trigger-1];

  clic_attr_type clic_int_attr [0:clic_interrupt-1];

  logic [0  : 0] clic_int_ip [0:clic_interrupt-1];
  logic [0  : 0] clic_int_ie [0:clic_interrupt-1];
  logic [7  : 0] clic_int_ctl [0:clic_interrupt-1];

  logic [31 : 0] rdata_cfg = 0;
  logic [31 : 0] rdata_info = 0;
  logic [31 : 0] rdata_trig = 0;
  logic [31 : 0] rdata_irpt = 0;

  logic [0  : 0] ready_cfg = 0;
  logic [0  : 0] ready_info = 0;
  logic [0  : 0] ready_trig = 0;
  logic [0  : 0] ready_irpt = 0;

  logic [0  : 0] meip = 0;

  always_ff @(posedge clk) begin
    if (rst == 0) begin
      rdata_cfg <= 0;
      ready_cfg <= 0;
    end else begin
      rdata_cfg <= 0;
      ready_cfg <= 0;
      if (clic_valid == 1) begin
        if (clic_addr < clic_cfg_end) begin
          if (|clic_wstrb == 0) begin
            rdata_cfg[6:5] <= clic_cfg.nmbits;
            rdata_cfg[4:1] <= clic_cfg.nlbits;
            rdata_cfg[0:0] <= clic_cfg.nvbits;
          end else begin
            clic_cfg.nmbits <= clic_wdata[6:5];
            clic_cfg.nlbits <= clic_wdata[4:1];
            clic_cfg.nvbits <= clic_wdata[0:0];
          end
          ready_cfg <= 1;
        end
      end
    end
  end

  always_ff @(posedge clk) begin
    if (rst == 0) begin
      rdata_info <= 0;
      ready_info <= 0;
    end else begin
      rdata_info <= 0;
      ready_info <= 0;
      if (clic_valid == 1) begin
        if (clic_addr >= clic_info_start && clic_addr < clic_info_end) begin
          if (|clic_wstrb == 0) begin
            rdata_info[30:25] <= clic_info.num_trigger;
            rdata_info[24:21] <= clic_info.num_intctlbit;
            rdata_info[20:17] <= clic_info.arch_version;
            rdata_info[16:13] <= clic_info.impl_version;
            rdata_info[12:0] <= clic_info.num_interrupt;
          end
          ready_info <= 1;
        end
      end
    end
  end

  always_ff @(posedge clk) begin
    if (rst == 0) begin
      rdata_trig <= 0;
      ready_trig <= 0;
    end else begin
      rdata_trig <= 0;
      ready_trig <= 0;
      if (clic_valid == 1) begin
        if (clic_addr >= clic_trig_start && clic_addr < clic_trig_end) begin
          if (|clic_wstrb == 0) begin
            rdata_trig[31] <= clic_int_trig[clint_addr[$clog2(clic_trigger)+2:2]].enable;
            rdata_trig[12:0] <= clic_int_trig[clint_addr[$clog2(clic_trigger)+2:2]].num_interrupt;
          end else begin
            clic_int_trig[clint_addr[$clog2(clic_trigger)+2:2]].enable <= clic_wdata[31];
            clic_int_trig[clint_addr[$clog2(clic_trigger)+2:2]].num_interrupt <= clic_wdata[12:0];
          end
          ready_trig <= 1;
        end
      end
    end
  end

  always_ff @(posedge clk) begin
    if (rst == 0) begin
      rdata_irpt <= 0;
      ready_irpt <= 0;
    end else begin
      rdata_irpt <= 0;
      ready_irpt <= 0;
      if (clic_valid == 1) begin
        if (clic_addr >= clic_int_start && clic_addr < clic_int_end) begin
          if (|clic_wstrb == 0) begin
            rdata_irpt[0:0] <= clic_int_ip[clint_addr[$clog2(clic_interrupt)+2:2]];
            rdata_irpt[8:8] <= clic_int_ie[clint_addr[$clog2(clic_interrupt)+2:2]];
            rdata_irpt[16:16] <= clic_int_attr[clint_addr[$clog2(clic_interrupt)+2:2]].shv;
            rdata_irpt[18:17] <= clic_int_attr[clint_addr[$clog2(clic_interrupt)+2:2]].trig;
            rdata_irpt[23:22] <= clic_int_attr[clint_addr[$clog2(clic_interrupt)+2:2]].mode;
            rdata_irpt[31:24] <= clic_int_ctl[clint_addr[$clog2(clic_interrupt)+2:2]];
          end else begin
            clic_int_ip[clint_addr[$clog2(clic_interrupt)+2:2]] <= clic_wdata[0:0];
            clic_int_ie[clint_addr[$clog2(clic_interrupt)+2:2]] <= clic_wdata[8:8];
            clic_int_attr[clint_addr[$clog2(clic_interrupt)+2:2]].shv <= clic_wdata[16:16];
            clic_int_attr[clint_addr[$clog2(clic_interrupt)+2:2]].trig <= clic_wdata[18:17];
            clic_int_attr[clint_addr[$clog2(clic_interrupt)+2:2]].mode <= clic_wdata[23:22];
            clic_int_ctl[clint_addr[$clog2(clic_interrupt)+2:2]] <= clic_wdata[31:24];
          end
          ready_irpt <= 1;
        end
      end
    end
  end

  assign clic_rdata = (ready_cfg == 1) ? rdata_cfg :
                      (ready_info == 1) ? rdata_info :
                      (ready_trig == 1) ? rdata_trig :
                      (ready_irpt == 1) ? rdata_irpt : 0;
  assign clic_ready = ready_cfg | ready_info | ready_trig | ready_irpt;

  assign clic_meip = meip;

endmodule
