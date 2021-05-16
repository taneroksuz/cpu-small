import constants::*;
import functions::*;
import wires::*;

module fetch_stage
(
  input logic rst,
  input logic clk,
  input predecoder_out_type predecoder_out,
  output predecoder_in_type predecoder_in,
  input compress_out_type compress_out,
  output compress_in_type compress_in,
  input agu_out_type agu_out,
  output agu_in_type agu_in,
  input bcu_out_type bcu_out,
  output bcu_in_type bcu_in,
  input register_out_type register_out,
  output register_read_in_type register_rin,
  input forwarding_out_type forwarding_out,
  output forwarding_register_in_type forwarding_rin,
  input csr_out_type csr_out,
  input prefetch_out_type prefetch_out,
  output prefetch_in_type prefetch_in,
  input mem_out_type imem_out,
  output mem_in_type imem_in,
  output mem_in_type dmem_in,
  input fetch_in_type a,
  input fetch_in_type d,
  output fetch_out_type y,
  output fetch_out_type q
);
  timeunit 1ns;
  timeprecision 1ps;

  fetch_reg_type r,rin;
  fetch_reg_type v;

  always_comb begin

    v = r;

    v.vpc = r.pc;

    v.instr = prefetch_out.instr;

    if (d.e.stall == 1) begin
      v = r;
    end

    v.stall = prefetch_out.stall | a.e.stall | d.e.clear;
    v.clear = csr_out.exception | csr_out.mret | d.e.clear;
    v.spec = d.e.clear;

    if (v.clear == 1 | d.f.fence == 1) begin
      v.instr = nop_instr;
    end

    v.waddr = v.instr[11:7];
    v.raddr1 = v.instr[19:15];
    v.raddr2 = v.instr[24:20];
    v.caddr = v.instr[31:20];

    v.imm = 0;
    v.wren = 0;
    v.rden1 = 0;
    v.rden2 = 0;
    v.lui = 0;
    v.auipc = 0;
    v.jal = 0;
    v.jalr = 0;
    v.branch = 0;
    v.load = 0;
    v.store = 0;
    v.fence = 0;
    v.alu_op = 0;
    v.bcu_op = 0;
    v.lsu_op = 0;
    v.ebreak = 0;
    v.valid = 0;
    v.invalid = 1;

    predecoder_in.instr = v.instr;

    if (predecoder_out.valid == 1) begin
      v.imm = predecoder_out.imm;
      v.wren = predecoder_out.wren;
      v.rden1 = predecoder_out.rden1;
      v.rden2 = predecoder_out.rden2;
      v.auipc = predecoder_out.auipc;
      v.jal = predecoder_out.jal;
      v.jalr = predecoder_out.jalr;
      v.branch = predecoder_out.branch;
      v.load = predecoder_out.load;
      v.store = predecoder_out.store;
      v.fence = predecoder_out.fence;
      v.bcu_op = predecoder_out.bcu_op;
      v.lsu_op = predecoder_out.lsu_op;
      v.valid = predecoder_out.valid;
      v.invalid = 0;
    end

    compress_in.instr = v.instr;

    if (compress_out.valid == 1) begin
      v.imm = compress_out.imm;
      v.waddr = compress_out.waddr;
      v.raddr1 = compress_out.raddr1;
      v.raddr2 = compress_out.raddr2;
      v.wren = compress_out.wren;
      v.rden1 = compress_out.rden1;
      v.rden2 = compress_out.rden2;
      v.lui = compress_out.lui;
      v.jal = compress_out.jal;
      v.jalr = compress_out.jalr;
      v.branch = compress_out.branch;
      v.load = compress_out.load;
      v.store = compress_out.store;
      v.alu_op = compress_out.alu_op;
      v.bcu_op = compress_out.bcu_op;
      v.lsu_op = compress_out.lsu_op;
      v.ebreak = compress_out.ebreak;
      v.valid = compress_out.valid;
      v.invalid = 0;
    end

    register_rin.raddr1 = v.raddr1;
    register_rin.raddr2 = v.raddr2;

    forwarding_rin.raddr1 = v.raddr1;
    forwarding_rin.raddr2 = v.raddr2;
    forwarding_rin.rdata1 = register_out.rdata1;
    forwarding_rin.rdata2 = register_out.rdata2;

    v.rdata1 = forwarding_out.data1;
    v.rdata2 = forwarding_out.data2;

    bcu_in.rdata1 = v.rdata1;
    bcu_in.rdata2 = v.rdata2;
    bcu_in.bcu_op = v.bcu_op;

    v.jump = v.jal | v.jalr | bcu_out.branch;

    agu_in.rdata1 = v.rdata1;
    agu_in.imm = v.imm;
    agu_in.pc = v.pc;
    agu_in.auipc = v.auipc;
    agu_in.jal = v.jal;
    agu_in.jalr = v.jalr;
    agu_in.branch = v.branch;
    agu_in.load = v.load;
    agu_in.store = v.store;
    agu_in.lsu_op = v.lsu_op;

    v.address = agu_out.address;
    v.byteenable = agu_out.byteenable;
    v.exception = agu_out.exception;
    v.ecause = agu_out.ecause;
    v.etval = agu_out.etval;

    if (v.stall == 1) begin
      v.wren = 0;
      v.jal = 0;
      v.jalr = 0;
      v.branch = 0;
      v.load = 0;
      v.store = 0;
      v.fence = 0;
      v.ebreak = 0;
      v.jump = 0;
      v.invalid = 1;
    end

    if (v.exception == 1) begin
      if (v.load == 1) begin
        v.load = 0;
        v.wren = 0;
      end else if (v.store == 1) begin
        v.store = 0;
      end else if (v.jump == 1) begin
        v.jump = 0;
        v.wren = 0;
      end else begin
        v.exception = 0;
      end
    end

    if (csr_out.exception == 1) begin
      v.pc = csr_out.mtvec;
      v.spec = 1;
    end else if (csr_out.mret == 1) begin
      v.pc = csr_out.mepc;
      v.spec = 1;
    end else if (v.jump == 1) begin
      v.pc = v.address;
      v.spec = 1;
    end else if (v.stall == 0 & d.f.fence == 0) begin
      v.pc = v.pc + ((v.instr[1:0] == 2'b11) ? 4 : 2);
    end

    prefetch_in.pc = r.pc;
    prefetch_in.vpc = r.vpc;
    prefetch_in.npc = v.pc;
    prefetch_in.jump = v.spec;
    prefetch_in.fence = d.f.fence;
    prefetch_in.rdata = imem_out.mem_rdata;
    prefetch_in.ready = imem_out.mem_ready;

    imem_in.mem_valid = 1;
    imem_in.mem_instr = 1;
    imem_in.mem_addr = prefetch_out.fpc;
    imem_in.mem_wdata = 0;
    imem_in.mem_wstrb = 0;

    dmem_in.mem_valid = v.load | v.store;
    dmem_in.mem_instr = 0;
    dmem_in.mem_addr = v.address;
    dmem_in.mem_wdata = store_data(v.rdata2,v.lsu_op.lsu_sb,v.lsu_op.lsu_sh,v.lsu_op.lsu_sw);
    dmem_in.mem_wstrb = (v.load == 1) ? 4'h0 : v.byteenable;

    rin = v;

    y.pc = v.vpc;
    y.imm = v.imm;
    y.instr = v.instr;
    y.rdata1 = v.rdata1;
    y.rdata2 = v.rdata2;
    y.wren = v.wren;
    y.rden1 = v.rden1;
    y.rden2 = v.rden2;
    y.waddr = v.waddr;
    y.caddr = v.caddr;
    y.lui = v.lui;
    y.auipc = v.auipc;
    y.jal = v.jal;
    y.jalr = v.jalr;
    y.branch = v.branch;
    y.load = v.load;
    y.store = v.store;
    y.fence = v.fence;
    y.ebreak = v.ebreak;
    y.valid = v.valid;
    y.invalid = v.invalid;
    y.jump = v.jump;
    y.address = v.address;
    y.byteenable = v.byteenable;
    y.alu_op = v.alu_op;
    y.bcu_op = v.bcu_op;
    y.lsu_op = v.lsu_op;
    y.exception = v.exception;
    y.ecause = v.ecause;
    y.etval = v.etval;

    q.pc = r.vpc;
    q.imm = r.imm;
    q.instr = r.instr;
    q.rdata1 = r.rdata1;
    q.rdata2 = r.rdata2;
    q.wren = r.wren;
    q.rden1 = r.rden1;
    q.rden2 = r.rden2;
    q.waddr = r.waddr;
    q.caddr = r.caddr;
    q.lui = r.lui;
    q.auipc = r.auipc;
    q.jal = r.jal;
    q.jalr = r.jalr;
    q.branch = r.branch;
    q.load = r.load;
    q.store = r.store;
    q.fence = r.fence;
    q.ebreak = r.ebreak;
    q.valid = r.valid;
    q.invalid = r.invalid;
    q.jump = r.jump;
    q.address = r.address;
    q.byteenable = r.byteenable;
    q.alu_op = r.alu_op;
    q.bcu_op = r.bcu_op;
    q.lsu_op = r.lsu_op;
    q.exception = r.exception;
    q.ecause = r.ecause;
    q.etval = r.etval;

  end

  always_ff @(posedge clk) begin
    if (rst == 0) begin
      r <= init_fetch_reg;
    end else begin
      r <= rin;
    end
  end

endmodule
