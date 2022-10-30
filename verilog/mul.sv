import wires::*;

module mul
(
  input logic rst,
  input logic clk,
  input mul_in_type mul_in,
  output mul_out_type mul_out
);
  timeunit 1ns;
  timeprecision 1ps;

  parameter PERFORMANCE = 1;

  mul_reg_type r,rin;
  mul_reg_type v;

  logic signed [32:0] op1;
  logic signed [32:0] op2;

  logic signed [65:0] result;

  mul_op_type op;

  logic [0:0] op1_signed;
  logic [0:0] op2_signed;

  generate

    if (PERFORMANCE == 0) begin

      always_comb begin

        v = r;

        case (r.counter)
          0 : begin
            v.op1 = mul_in.rdata1;
            v.op2 = mul_in.rdata2;
            v.op = mul_in.op;
            v.op1_signed = v.op.muls | v.op.mulh |
                           v.op.mulhsu;
            v.op2_signed = v.op.muls | v.op.mulh;
            v.negativ = 0;
            v.mult = v.op.muls | v.op.mulh |
                   v.op.mulhsu | v.op.mulhu;
            v.op1_neg = 0;
            if (v.op1_signed == 1 && v.op1[31] == 1) begin
              v.negativ = ~v.negativ;
              v.op1 = -v.op1;
              v.op1_neg = 1;
            end
            if (v.op2_signed == 1 && v.op2[31] == 1) begin
              v.negativ = ~v.negativ;
              v.op2 = -v.op2;
            end
            v.counter = 0;
            for (int i=31; i>=0; i--) begin
              if (v.op1[i] == 1) begin
                break;
              end
              v.counter = v.counter + 1;
            end
            if (v.mult == 1) begin
              v.result = 0;
            end
            if (mul_in.enable == 0) begin
              v.counter = 0;
            end else if (mul_in.enable == 1) begin
              v.counter = v.counter + 1;
            end
            mul_out.result = 0;
            mul_out.ready = 0;
          end
          33 : begin
            if (v.negativ == 1) begin
              if (v.mult == 1) begin
                v.result = -v.result;
              end
            end
            v.counter = 0;
            if (v.op.muls == 1) begin
              mul_out.result = v.result[31:0];
            end else if (v.op.mulh == 1 |
                         v.op.mulhsu == 1 |
                         v.op.mulhu == 1) begin
              mul_out.result = v.result[63:32];
            end
            mul_out.ready = 1;
          end
          default : begin
            if (v.mult == 1) begin
              v.result = {v.result[63:0],1'b0};
              if (v.op1[32-v.counter] == 1) begin
                v.result = v.result + {33'b0,v.op2};
              end
            end
            v.counter = v.counter + 1;
            mul_out.result = 0;
            mul_out.ready = 0;
          end
        endcase

        rin = v;

      end

      always_ff @ (posedge clk) begin
        if (rst == 0) begin
          r <= init_mul_reg;
        end else begin
          r <= rin;
        end

      end

    end

    if (PERFORMANCE == 1) begin

      always_comb begin

        op1 = {1'b0,mul_in.rdata1};
        op2 = {1'b0,mul_in.rdata2};
        op = mul_in.op;
        op1_signed = op.muls | op.mulh |
                     op.mulhsu;
        op2_signed = op.muls | op.mulh;
        if (op1_signed == 1) begin
          op1[32] = op1[31];
        end
        if (op2_signed == 1) begin
          op2[32] = op2[31];
        end
        result = op1*op2;
        if (op.muls == 1) begin
          mul_out.result = result[31:0];
        end else begin
          mul_out.result = result[63:32];
        end
        mul_out.ready = mul_in.enable;

      end

    end

  endgenerate

endmodule
