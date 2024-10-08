import configure::*;
import wires::*;

module clint #(
    parameter clock_rate
) (
    input logic reset,
    input logic clock,
    input mem_in_type clint_in,
    output mem_out_type clint_out,
    output logic [63 : 0] clint_mtime,
    output logic clint_msip,
    output logic clint_mtip
);
  timeunit 1ns; timeprecision 1ps;

  localparam depth = $clog2(clock_rate);
  localparam full = clock_rate - 1;

  logic [depth-1 : 0] count = 0;

  localparam clint_msip_start = 32'h0000;
  localparam clint_msip_end = clint_msip_start + 4;
  localparam clint_mtimecmp_start = 32'h4000;
  localparam clint_mtimecmp_end = clint_mtimecmp_start + 8;
  localparam clint_mtime_start = 32'hBFF8;
  localparam clint_mtime_end = clint_mtime_start + 8;

  logic [63 : 0] mtimecmp = 0;
  logic [63 : 0] mtime = 0;

  logic [ 0 : 0] mtip = 0;
  logic [ 0 : 0] msip = 0;

  logic [ 0 : 0] enable = 0;

  logic [31 : 0] rdata_ms = 0;
  logic [31 : 0] rdata_mt = 0;
  logic [31 : 0] rdata_mtc = 0;

  logic [ 0 : 0] ready_ms = 0;
  logic [ 0 : 0] ready_mt = 0;
  logic [ 0 : 0] ready_mtc = 0;

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      rdata_ms <= 0;
      ready_ms <= 0;
      msip <= 0;
    end else begin
      rdata_ms <= 0;
      ready_ms <= 0;
      if (clint_in.mem_valid == 1) begin
        if (clint_in.mem_addr < clint_msip_end) begin
          if (|clint_in.mem_wstrb == 0) begin
            rdata_ms[0] <= msip;
            ready_ms <= 1;
          end else begin
            msip <= clint_in.mem_wdata[0];
            ready_ms <= 1;
          end
        end
      end
    end
  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      rdata_mt <= 0;
      ready_mt <= 0;
      mtime <= 0;
    end else begin
      rdata_mt <= 0;
      ready_mt <= 0;
      if (enable == 1) begin
        mtime <= mtime + 64'h1;
      end
      if (clint_in.mem_valid == 1) begin
        if (clint_in.mem_addr >= clint_mtime_start && clint_in.mem_addr < clint_mtime_end) begin
          if (|clint_in.mem_wstrb == 0) begin
            if (clint_in.mem_addr[2] == 0) begin
              rdata_mt <= mtime[31:0];
            end else begin
              rdata_mt <= mtime[63:32];
            end
            ready_mt <= 1;
          end else begin
            if (clint_in.mem_addr[2] == 0) begin
              mtime[31:0] <= clint_in.mem_wdata;
            end else begin
              mtime[63:32] <= clint_in.mem_wdata;
            end
            ready_mt <= 1;
          end
        end
      end
    end
  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      rdata_mtc <= 0;
      ready_mtc <= 0;
      mtimecmp  <= 0;
    end else begin
      rdata_mtc <= 0;
      ready_mtc <= 0;
      if (clint_in.mem_valid == 1) begin
        if (clint_in.mem_addr >= clint_mtimecmp_start && clint_in.mem_addr < clint_mtimecmp_end) begin
          if (|clint_in.mem_wstrb == 0) begin
            if (clint_in.mem_addr[2] == 0) begin
              rdata_mtc <= mtimecmp[31:0];
            end else begin
              rdata_mtc <= mtimecmp[63:32];
            end
            ready_mtc <= 1;
          end else begin
            if (clint_in.mem_addr[2] == 0) begin
              mtimecmp[31:0] <= clint_in.mem_wdata;
            end else begin
              mtimecmp[63:32] <= clint_in.mem_wdata;
            end
            ready_mtc <= 1;
          end
        end
      end
    end
  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      mtip <= 0;
    end else begin
      if (mtime >= mtimecmp) begin
        mtip <= 1;
      end else begin
        mtip <= 0;
      end
    end
  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      count  <= 0;
      enable <= 0;
    end else begin
      if (count == full[depth-1:0]) begin
        count  <= 0;
        enable <= 1;
      end else begin
        count  <= count + 1;
        enable <= 0;
      end
    end
  end

  assign clint_out.mem_rdata = (ready_ms == 1) ? rdata_ms :
                               (ready_mt == 1) ? rdata_mt :
                               (ready_mtc == 1) ? rdata_mtc : 0;
  assign clint_out.mem_error = 0;
  assign clint_out.mem_ready = ready_ms | ready_mt | ready_mtc;

  assign clint_msip = msip;
  assign clint_mtip = mtip;
  assign clint_mtime = mtime;

endmodule
