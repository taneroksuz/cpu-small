import wires::*;

module muldiv
(
  input logic rst,
  input logic clk,
  input muldiv_in_type muldiv_in,
  output muldiv_out_type muldiv_out
);
  timeunit 1ns;
  timeprecision 1ps;

  muldiv_reg_type r,rin;
  muldiv_reg_type v;

  always_comb begin

    v = r;

    case (r.counter)
      0 : begin
        v.op1 = muldiv_in.rdata1;
        v.op2 = muldiv_in.rdata2;
        v.muldiv_op = muldiv_in.muldiv_op;
        v.op1_signed = v.muldiv_op.muldiv_mul | v.muldiv_op.muldiv_mulh |
                       v.muldiv_op.muldiv_mulhsu | v.muldiv_op.muldiv_div |
                       v.muldiv_op.muldiv_rem;
        v.op2_signed = v.muldiv_op.muldiv_mul | v.muldiv_op.muldiv_mulh |
                       v.muldiv_op.muldiv_div | v.muldiv_op.muldiv_rem;
        v.negativ = 0;
        v.mul_op = v.muldiv_op.muldiv_mul | v.muldiv_op.muldiv_mulh |
                   v.muldiv_op.muldiv_mulhsu | v.muldiv_op.muldiv_mulhu;
        v.div_op = v.muldiv_op.muldiv_div | v.muldiv_op.muldiv_divu |
                   v.muldiv_op.muldiv_rem | v.muldiv_op.muldiv_remu;
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
        v.divisionbyzero = 0;
        if (v.div_op == 1 && v.op2 == 0) begin
          v.divisionbyzero = 1;
          v.counter = 32;
        end
        v.overflow = 0;
        if ((v.muldiv_op.muldiv_div == 1 | v.muldiv_op.muldiv_rem == 1) &&
            v.op1 == 32'h80000000 && v.op2 == 32'hFFFFFFFF) begin
          v.overflow = 1;
          v.counter = 32;
        end
        if (v.mul_op == 1) begin
          v.result = 0;
        end else if (v.div_op == 1) begin
          v.result = {33'b0,v.op1};
          v.result = v.result << v.counter;
        end
        if (muldiv_in.enable == 0) begin
          v.counter = 0;
        end else if (muldiv_in.enable == 1) begin
          v.counter = v.counter + 1;
        end
        muldiv_out.result = 0;
        muldiv_out.ready = 0;
      end
      33 : begin
        if (v.negativ == 1) begin
          if (v.mul_op == 1) begin
            v.result = -v.result;
          end else if (v.div_op == 1) begin
            v.result[31:0] = -v.result[31:0];
          end
        end
        if (v.op1_neg == 1) begin
          if (v.div_op == 1) begin
            v.result[63:32] = -v.result[63:32];
          end
        end
        v.counter = 0;
        if (v.muldiv_op.muldiv_mul == 1) begin
          muldiv_out.result = v.result[31:0];
        end else if (v.muldiv_op.muldiv_mulh == 1 |
                     v.muldiv_op.muldiv_mulhsu == 1 |
                     v.muldiv_op.muldiv_mulhu == 1) begin
          muldiv_out.result = v.result[63:32];
        end else if (v.muldiv_op.muldiv_div == 1) begin
          if (v.divisionbyzero == 1) begin
            muldiv_out.result = 32'hFFFFFFFF;
          end else if (v.overflow == 1) begin
            muldiv_out.result = 32'h80000000;
          end else begin
            muldiv_out.result = v.result[31:0];
          end
        end else if (v.muldiv_op.muldiv_divu == 1) begin
          if (v.divisionbyzero == 1) begin
            muldiv_out.result = 32'hFFFFFFFF;
          end else begin
            muldiv_out.result = v.result[31:0];
          end
        end else if (v.muldiv_op.muldiv_rem == 1) begin
          if (v.divisionbyzero == 1) begin
            muldiv_out.result = v.op1;
          end else if (v.overflow == 1) begin
            muldiv_out.result = 0;
          end else begin
            muldiv_out.result = v.result[63:32];
          end
        end else if (v.muldiv_op.muldiv_remu == 1) begin
          if (v.divisionbyzero == 1) begin
            muldiv_out.result = v.op1;
          end else begin
            muldiv_out.result = v.result[63:32];
          end
        end else begin
          muldiv_out.result = 0;
        end
        muldiv_out.ready = 1;
      end
      default : begin
        if (v.mul_op == 1) begin
          v.result = {v.result[63:0],1'b0};
          if (v.op1[32-v.counter] == 1) begin
            v.result = v.result + {33'b0,v.op2};
          end
        end else if (v.div_op == 1) begin
          v.result = {v.result[63:0],1'b0};
          v.result[64:32] = v.result[64:32] - {1'b0,v.op2};
          if (v.result[64] == 0) begin
            v.result[0] = 1;
          end else if (v.result[64] == 1) begin
            v.result = {r.result[63:0],1'b0};
          end
        end
        v.counter = v.counter + 1;
        muldiv_out.result = 0;
        muldiv_out.ready = 0;
      end
    endcase

    rin = v;

  end

  always_ff @ (posedge clk) begin
    if (rst == 0) begin
      r <= init_muldiv_reg;
    end else begin
      r <= rin;
    end

  end

endmodule
