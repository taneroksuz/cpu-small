import configure::*;
import wires::*;

module sram #(
    parameter clock_rate
) (
    input logic reset,
    input logic clock,
    input mem_in_type sram_in,
    output mem_out_type sram_out,
    output sram_ce_n,
    output sram_we_n,
    output sram_oe_n,
    output sram_ub_n,
    output sram_lb_n,
    inout [15:0] sram_dq,
    output [17:0] sram_addr
);
  timeunit 1ns; timeprecision 1ps;

  generate

    if (hardware == 0) begin

      localparam depth = $clog2(sram_depth);

      logic [31 : 0] sram_block[0:sram_depth-1];

      initial begin
        $readmemh("sram.dat", sram_block);
      end

      always_ff @(posedge clock) begin

        if (sram_in.mem_valid == 1) begin

          if (sram_in.mem_wstrb[0] == 1)
            sram_block[sram_in.mem_addr[(depth+1):2]][7:0] <= sram_in.mem_wdata[7:0];
          if (sram_in.mem_wstrb[1] == 1)
            sram_block[sram_in.mem_addr[(depth+1):2]][15:8] <= sram_in.mem_wdata[15:8];
          if (sram_in.mem_wstrb[2] == 1)
            sram_block[sram_in.mem_addr[(depth+1):2]][23:16] <= sram_in.mem_wdata[23:16];
          if (sram_in.mem_wstrb[3] == 1)
            sram_block[sram_in.mem_addr[(depth+1):2]][31:24] <= sram_in.mem_wdata[31:24];

          sram_out.mem_rdata <= sram_block[sram_in.mem_addr[(depth+1):2]];
          sram_out.mem_error <= 0;
          sram_out.mem_ready <= 1;

        end else begin

          sram_out.mem_rdata <= 0;
          sram_out.mem_error <= 0;
          sram_out.mem_ready <= 0;

        end

      end

    end

    if (hardware == 1) begin

      localparam full = clock_rate - 1;

      typedef struct packed {
        logic [31 : 0] counter;
        logic [31 : 0] data;
        logic [3 : 0]  strb;
        logic [15 : 0] dq;
        logic [17 : 0] addr;
        logic [0 : 0]  ce_n;
        logic [0 : 0]  we_n;
        logic [0 : 0]  oe_n;
        logic [0 : 0]  ub_n;
        logic [0 : 0]  lb_n;
        logic [1 : 0]  state;
        logic [0 : 0]  write;
        logic [0 : 0]  read;
        logic [0 : 0]  ready;
      } register_type;

      register_type init_register = 0;

      register_type r, rin, v;

      always_comb begin

        v = r;

        v.counter = v.counter + 1;
        v.ready = 0;
        v.ce_n = 1;
        v.we_n = 1;
        v.oe_n = 1;
        v.ub_n = 1;
        v.lb_n = 1;

        if (sram_in.mem_valid == 1 && v.state == 0) begin
          v.addr = sram_in.mem_addr[18:1];
          v.data = sram_in.mem_wdata;
          v.strb = sram_in.mem_wstrb;
          v.write = |v.strb;
          v.read = ~v.write;
          v.counter = 0;
          v.state = 1;
        end

        if (v.counter > full) begin
          if (v.write == 1) begin
            if (v.state == 2) begin
              v.ready = 1;
              v.write = 0;
              v.state = 0;
            end
            if (v.state == 1) begin
              v.addr[0] = 1'b1;
              v.state = 2;
            end
          end
          if (v.read == 1) begin
            if (v.state == 2) begin
              v.data[31:16] = sram_dq;
              v.ready = 1;
              v.read = 0;
              v.state = 0;
            end
            if (v.state == 1) begin
              v.data[15:0] = sram_dq;
              v.addr[0] = 1'b1;
              v.state = 2;
            end
          end
          v.counter = 0;
        end

        if (v.write == 1) begin
          v.ce_n = 0;
          v.we_n = 0;
          if (v.state == 2) begin
            v.dq   = v.data[31:16];
            v.ub_n = ~v.strb[3];
            v.lb_n = ~v.strb[2];
          end
          if (v.state == 1) begin
            v.dq   = v.data[15:0];
            v.ub_n = ~v.strb[1];
            v.lb_n = ~v.strb[0];
          end
        end else if (v.read == 1) begin
          v.ce_n = 0;
          v.oe_n = 0;
          v.ub_n = 0;
          v.lb_n = 0;
        end

        rin = v;

      end

      assign sram_out.mem_rdata = r.data;
      assign sram_out.mem_error = 0;
      assign sram_out.mem_ready = r.ready;

      assign sram_ce_n = r.ce_n;
      assign sram_we_n = r.we_n;
      assign sram_oe_n = r.oe_n;
      assign sram_ub_n = r.ub_n;
      assign sram_lb_n = r.lb_n;
      assign sram_addr = r.addr;
      assign sram_dq = r.we_n == 0 ? r.dq : 16'bz;

      always_ff @(posedge clock) begin
        if (reset == 0) begin
          r <= init_register;
        end else begin
          r <= rin;
        end
      end

    end

  endgenerate

endmodule
