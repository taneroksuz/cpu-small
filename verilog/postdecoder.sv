import constants::*;
import wires::*;

module postdecoder
(
  input postdecoder_in_type postdecoder_in,
  output postdecoder_out_type postdecoder_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [31 : 0] instr;

  logic [31 : 0] imm_c;
  logic [31 : 0] imm_i;
  logic [31 : 0] imm_u;
  logic [31 : 0] imm;

  logic [6  : 0] opcode;
  logic [2  : 0] funct3;

  logic [4  : 0] waddr;
  logic [4  : 0] raddr1;
  logic [11 : 0] caddr;

  logic [0  : 0] wren;
  logic [0  : 0] rden1;
  logic [0  : 0] rden2;

  logic [0  : 0] cwren;
  logic [0  : 0] crden;

  logic [0  : 0] lui;
  logic [0  : 0] csr;
  logic [0  : 0] div;
  logic [0  : 0] mul;
  logic [0  : 0] ecall;
  logic [0  : 0] ebreak;
  logic [0  : 0] mret;
  logic [0  : 0] wfi;
  logic [0  : 0] valid;

  alu_op_type alu_op;
  csr_op_type csr_op;

  div_op_type div_op;
  mul_op_type mul_op;

  logic [0  : 0] nonzero_waddr;
  logic [0  : 0] nonzero_raddr1;

  logic [0  : 0] nonzero_imm_c;
  logic [0  : 0] nonzero_imm_i;
  logic [0  : 0] nonzero_imm_u;

  always_comb begin

    instr = postdecoder_in.instr;

    imm_c = {{27{instr[19]}},instr[19:15]};
    imm_i = {{20{instr[31]}},instr[31:20]};
    imm_u = {instr[31:12],12'h0};

    imm = 0;

    opcode = instr[6:0];
    funct3 = instr[14:12];

    waddr = instr[11:7];
    raddr1 = instr[19:15];
    caddr = instr[31:20];

    wren = 0;
    rden1 = 0;
    rden2 = 0;

    cwren = 0;
    crden = 0;

    lui = 0;
    csr = 0;
    div = 0;
    mul = 0;
    ecall = 0;
    ebreak = 0;
    mret = 0;
    wfi = 0;
    valid = 1;

    alu_op = init_alu_op;
    csr_op = init_csr_op;

    div_op = init_div_op;
    mul_op = init_mul_op;

    nonzero_waddr = |waddr;
    nonzero_raddr1 = |raddr1;

    nonzero_imm_c = |imm_c;
    nonzero_imm_i = |imm_i;
    nonzero_imm_u = |imm_u;

    case (opcode)
      opcode_lui : begin
        imm = imm_u;
        wren = nonzero_waddr;
        lui = 1;
      end
      opcode_immediate : begin
        wren = nonzero_waddr;
        rden1 = 1;
        imm = imm_i;
        case (funct3)
          funct_add : alu_op.alu_add = 1;
          funct_sll : begin
            alu_op.alu_sll = 1;
            valid = ~instr[25];
          end
          funct_srl : begin
            alu_op.alu_srl = ~instr[30];
            alu_op.alu_sra = instr[30];
            valid = ~instr[25];
          end
          funct_slt : alu_op.alu_slt = 1;
          funct_sltu : alu_op.alu_sltu = 1;
          funct_and : alu_op.alu_and = 1;
          funct_or : alu_op.alu_or = 1;
          funct_xor : alu_op.alu_xor = 1;
          default : valid = 0;
        endcase;
      end
      opcode_register : begin
        wren = nonzero_waddr;
        rden1 = 1;
        rden2 = 1;
        if (instr[25] == 0) begin
          case (funct3)
            funct_add : begin
              alu_op.alu_add = ~instr[30];
              alu_op.alu_sub = instr[30];
            end
            funct_sll : alu_op.alu_sll = 1;
            funct_srl : begin
              alu_op.alu_srl = ~instr[30];
              alu_op.alu_sra = instr[30];
            end
            funct_slt : alu_op.alu_slt = 1;
            funct_sltu : alu_op.alu_sltu = 1;
            funct_and : alu_op.alu_and = 1;
            funct_or : alu_op.alu_or = 1;
            funct_xor : alu_op.alu_xor = 1;
            default : valid = 0;
          endcase;
        end else if (instr[25] == 1) begin
          case (funct3)
            funct_mul : begin
              mul = 1;
              mul_op.mul = 1;
            end
            funct_mulh :  begin
              mul = 1;
              mul_op.mulh = 1;
            end
            funct_mulhsu :  begin
              mul = 1;
              mul_op.mulhsu = 1;
            end
            funct_mulhu :  begin
              mul = 1;
              mul_op.mulhu = 1;
            end
            funct_div :  begin
              div = 1;
              div_op.div = 1;
            end
            funct_divu :  begin
              div = 1;
              div_op.divu = 1;
            end
            funct_rem :  begin
              div = 1;
              div_op.rem = 1;
            end
            funct_remu :  begin
              div = 1;
              div_op.remu = 1;
            end
            default : valid = 0;
          endcase;
        end
      end
      opcode_system : begin
        imm = imm_c;
        if (funct3 == 0) begin
          case (caddr)
            csr_ecall : ecall = 1;
            csr_ebreak : ebreak = 1;
            csr_mret : mret = 1;
            csr_wfi : wfi = 1;
            default : valid = 0;
          endcase
        end else if (funct3 == 1) begin
          wren = nonzero_waddr;
          rden1 = 1;
          cwren = 1;
          crden = nonzero_waddr;
          csr_op.csrrw = 1;
          csr = 1;
        end else if (funct3 == 2) begin
          wren = nonzero_waddr;
          rden1 = 1;
          cwren = nonzero_waddr;
          crden = 1;
          csr_op.csrrs = 1;
          csr = 1;
        end else if (funct3 == 3) begin
          wren = nonzero_waddr;
          rden1 = 1;
          cwren = nonzero_waddr;
          crden = 1;
          csr_op.csrrc = 1;
          csr = 1;
        end else if (funct3 == 5) begin
          wren = nonzero_waddr;
          cwren = 1;
          crden = nonzero_waddr;
          csr_op.csrrwi = 1;
          csr = 1;
        end else if (funct3 == 6) begin
          wren = nonzero_waddr;
          cwren = nonzero_imm_c;
          crden = 1;
          csr_op.csrrsi = 1;
          csr = 1;
        end else if (funct3 == 7) begin
          wren = nonzero_waddr;
          cwren = nonzero_imm_c;
          crden = 1;
          csr_op.csrrci = 1;
          csr = 1;
        end
      end
      default : valid = 0;
    endcase;

    if (instr == nop) begin
      alu_op.alu_add = 0;
    end

    postdecoder_out.imm = imm;
    postdecoder_out.wren = wren;
    postdecoder_out.rden1 = rden1;
    postdecoder_out.rden2 = rden2;
    postdecoder_out.cwren = cwren;
    postdecoder_out.crden = crden;
    postdecoder_out.lui = lui;
    postdecoder_out.csr = csr;
    postdecoder_out.div = div;
    postdecoder_out.mul = mul;
    postdecoder_out.alu_op = alu_op;
    postdecoder_out.csr_op = csr_op;
    postdecoder_out.div_op = div_op;
    postdecoder_out.mul_op = mul_op;
    postdecoder_out.ecall = ecall;
    postdecoder_out.ebreak = ebreak;
    postdecoder_out.mret = mret;
    postdecoder_out.wfi = wfi;
    postdecoder_out.valid = valid;

  end

endmodule
