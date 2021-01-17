import constants::*;
import wires::*;

module predecoder
(
  input predecoder_in_type predecoder_in,
  output predecoder_out_type predecoder_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [31 : 0] instr;

  logic [31 : 0] imm_i;
  logic [31 : 0] imm_s;
  logic [31 : 0] imm_b;
  logic [31 : 0] imm_j;
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

  logic [0  : 0] auipc;
  logic [0  : 0] jal;
  logic [0  : 0] jalr;
  logic [0  : 0] branch;
  logic [0  : 0] load;
  logic [0  : 0] store;
  logic [0  : 0] fence;
  logic [0  : 0] valid;

  bcu_op_type bcu_op;
  lsu_op_type lsu_op;

  logic [0  : 0] nonzero_waddr;
  logic [0  : 0] nonzero_raddr1;

  logic [0  : 0] nonzero_imm_i;
  logic [0  : 0] nonzero_imm_s;
  logic [0  : 0] nonzero_imm_b;
  logic [0  : 0] nonzero_imm_j;
  logic [0  : 0] nonzero_imm_u;

  always_comb begin

    instr = predecoder_in.instr;

    imm_i = {{20{instr[31]}},instr[31:20]};
    imm_s = {{20{instr[31]}},instr[31:25],instr[11:7]};
    imm_b = {{19{instr[31]}},instr[31],instr[7],instr[30:25],instr[11:8],1'b0};
    imm_j = {{11{instr[31]}},instr[31],instr[19:12],instr[20],instr[30:25],instr[24:21],1'b0};
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

    auipc = 0;
    jal = 0;
    jalr = 0;
    branch = 0;
    load = 0;
    store = 0;
    fence = 0;
    valid = 1;

    bcu_op = init_bcu_op;
    lsu_op = init_lsu_op;

    nonzero_waddr = |waddr;
    nonzero_raddr1 = |raddr1;

    nonzero_imm_i = |imm_i;
    nonzero_imm_s = |imm_s;
    nonzero_imm_b = |imm_b;
    nonzero_imm_j = |imm_j;

    case (opcode)
      opcode_auipc : begin
        imm = imm_u;
        wren = nonzero_waddr;
        auipc = 1;
      end
      opcode_jal : begin
        wren = nonzero_waddr;
        imm = imm_j;
        jal = 1;
      end
      opcode_jalr : begin
        imm = imm_i;
        wren = nonzero_waddr;
        rden1 = 1;
        jalr = 1;
      end
      opcode_branch : begin
        imm = imm_b;
        rden1 = 1;
        rden2 = 1;
        branch = 1;
        case (funct3)
          funct_beq : bcu_op.bcu_beq = 1;
          funct_bne : bcu_op.bcu_bne = 1;
          funct_blt : bcu_op.bcu_blt = 1;
          funct_bge : bcu_op.bcu_bge = 1;
          funct_bltu : bcu_op.bcu_bltu = 1;
          funct_bgeu : bcu_op.bcu_bgeu = 1;
          default : valid = 0;
        endcase
      end
      opcode_load : begin
        imm = imm_i;
        wren = nonzero_waddr;
        rden1 = 1;
        load = 1;
        case (funct3)
          funct_lb : lsu_op.lsu_lb = 1;
          funct_lh : lsu_op.lsu_lh = 1;
          funct_lw : lsu_op.lsu_lw = 1;
          funct_lbu : lsu_op.lsu_lbu = 1;
          funct_lhu : lsu_op.lsu_lhu = 1;
          default : valid = 0;
        endcase;
      end
      opcode_store : begin
        imm = imm_s;
        rden1 = 1;
        rden2 = 1;
        store = 1;
        case (funct3)
          funct_sb : lsu_op.lsu_sb = 1;
          funct_sh : lsu_op.lsu_sh = 1;
          funct_sw : lsu_op.lsu_sw = 1;
          default : valid = 0;
        endcase;
      end
      opcode_fence : begin
        if (funct3 == 1) begin
          fence = 1;
        end
      end
      default : valid = 0;
    endcase;

    predecoder_out.imm = imm;
    predecoder_out.wren = wren;
    predecoder_out.rden1 = rden1;
    predecoder_out.rden2 = rden2;
    predecoder_out.auipc = auipc;
    predecoder_out.jal = jal;
    predecoder_out.jalr = jalr;
    predecoder_out.branch = branch;
    predecoder_out.load = load;
    predecoder_out.store = store;
    predecoder_out.bcu_op = bcu_op;
    predecoder_out.lsu_op = lsu_op;
    predecoder_out.fence = fence;
    predecoder_out.valid = valid;

  end

endmodule
