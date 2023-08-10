import constants::*;
import functions::*;
import wires::*;

module fetch_stage
(
  input logic reset,
  input logic clock,
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
  input mem_out_type imem_out,
  output mem_in_type imem_in,
  input buffer_out_type buffer_out,
  output buffer_in_type buffer_in,
  output mem_in_type dmem_in,
  input fetch_in_type a,
  input fetch_in_type d,
  output fetch_out_type y,
  output fetch_out_type q
);
  timeunit 1ns;
  timeprecision 1ps;

  localparam [1:0] idle = 0;
  localparam [1:0] busy = 1;
  localparam [1:0] ctrl = 2;
  localparam [1:0] inv = 3;

  fetch_reg_type r,rin;
  fetch_reg_type v;

  always_comb begin

    v = r;

    v.valid = 0;
    v.stall = buffer_out.stall;

    v.fence = 0;
    v.spec = 0;
    v.mode = csr_out.mode;

    v.rdata = imem_out.mem_rdata;
    v.error = imem_out.mem_error;
    v.ready = imem_out.mem_ready;

    case(v.state)
      idle : begin
        v.stall = 1;
      end
      busy : begin
        if (v.ready == 0) begin
          v.stall = 1;
        end
      end
      ctrl : begin
        v.stall = 1;
      end
      inv : begin
        v.stall = 1;
      end
      default : begin
      end
    endcase

    if (csr_out.trap == 1) begin
      v.fence = 0;
      v.spec = 1;
      v.addr = csr_out.mtvec;
    end else if (csr_out.mret == 1) begin
      v.fence = 0;
      v.spec = 1;
      v.addr = csr_out.mepc;
    end else if (d.f.instr.op.jump == 1) begin
      v.fence = 0;
      v.spec = 1;
      v.addr = d.f.instr.address;
    end else if (a.e.instr.op.fence == 1) begin
      v.fence = 1;
      v.spec = 1;
      v.addr = a.e.instr.npc;
    end else if (v.stall == 0) begin
      v.fence = 0;
      v.spec = 0;
      v.addr = v.addr + 4;
    end

    case(v.state)
      idle : begin
        if (d.e.clear == 0) begin
          v.state = busy;
          v.valid = 1;
        end
      end
      busy : begin
        if (v.ready == 1) begin
          v.state = busy;
          v.valid = 1;
        end else if (v.spec == 1) begin
          v.state = ctrl;
          v.valid = 0;
        end else if (v.fence == 1) begin
          v.state = inv;
          v.valid = 0;
        end else begin
          v.state = busy;
          v.valid = 0;
        end
      end
      ctrl : begin
        if (v.ready == 1) begin
          v.state = busy;
          v.valid = 1;
        end else begin
          v.state = ctrl;
          v.valid = 0;
        end
        v.ready = 0;
      end
      inv : begin
        if (v.ready == 1) begin
          v.state = busy;
          v.valid = 1;
        end else begin
          v.state = inv;
          v.valid = 0;
        end
        v.ready = 0;
      end
      default : begin
      end
    endcase

    buffer_in.pc = {r.addr[31:2],2'b00};
    buffer_in.rdata = v.rdata;
    buffer_in.error = v.error;
    buffer_in.ready = v.ready;
    buffer_in.align = v.addr[1];
    buffer_in.clear = v.spec;
    buffer_in.stall = a.e.stall;

    imem_in.mem_valid = v.valid;
    imem_in.mem_fence = v.fence;
    imem_in.mem_spec = v.spec;
    imem_in.mem_instr = 1;
    imem_in.mem_mode = v.mode;
    imem_in.mem_addr = v.addr;
    imem_in.mem_wdata = 0;
    imem_in.mem_wstrb = 0;

    v.instr.pc = buffer_out.pc;
    v.instr.instr = buffer_out.instr;
    v.miss = buffer_out.miss;
    v.done = buffer_out.done;

    v.stall = 0;
    v.clear = csr_out.trap | csr_out.mret | d.e.clear;

    v.instr.waddr = v.instr.instr[11:7];
    v.instr.raddr1 = v.instr.instr[19:15];
    v.instr.raddr2 = v.instr.instr[24:20];
    v.instr.caddr = v.instr.instr[31:20];

    v.instr.imm = 0;
    v.instr.alu_op = 0;
    v.instr.bcu_op = 0;
    v.instr.lsu_op = 0;
    v.instr.op.wren = 0;
    v.instr.op.rden1 = 0;
    v.instr.op.rden2 = 0;
    v.instr.op.lui = 0;
    v.instr.op.auipc = 0;
    v.instr.op.jal = 0;
    v.instr.op.jalr = 0;
    v.instr.op.branch = 0;
    v.instr.op.load = 0;
    v.instr.op.store = 0;
    v.instr.op.ebreak = 0;
    v.instr.op.valid = 0;

    predecoder_in.instr = v.instr.instr;

    if (predecoder_out.valid == 1) begin
      v.instr.imm = predecoder_out.imm;
      v.instr.bcu_op = predecoder_out.bcu_op;
      v.instr.lsu_op = predecoder_out.lsu_op;
      v.instr.op.wren = predecoder_out.wren;
      v.instr.op.rden1 = predecoder_out.rden1;
      v.instr.op.rden2 = predecoder_out.rden2;
      v.instr.op.auipc = predecoder_out.auipc;
      v.instr.op.jal = predecoder_out.jal;
      v.instr.op.jalr = predecoder_out.jalr;
      v.instr.op.branch = predecoder_out.branch;
      v.instr.op.load = predecoder_out.load;
      v.instr.op.store = predecoder_out.store;
      v.instr.op.valid = predecoder_out.valid;
    end

    compress_in.instr = v.instr.instr;

    if (compress_out.valid == 1) begin
      v.instr.imm = compress_out.imm;
      v.instr.waddr = compress_out.waddr;
      v.instr.raddr1 = compress_out.raddr1;
      v.instr.raddr2 = compress_out.raddr2;
      v.instr.alu_op = compress_out.alu_op;
      v.instr.bcu_op = compress_out.bcu_op;
      v.instr.lsu_op = compress_out.lsu_op;
      v.instr.op.wren = compress_out.wren;
      v.instr.op.rden1 = compress_out.rden1;
      v.instr.op.rden2 = compress_out.rden2;
      v.instr.op.lui = compress_out.lui;
      v.instr.op.jal = compress_out.jal;
      v.instr.op.jalr = compress_out.jalr;
      v.instr.op.branch = compress_out.branch;
      v.instr.op.load = compress_out.load;
      v.instr.op.store = compress_out.store;
      v.instr.op.ebreak = compress_out.ebreak;
      v.instr.op.valid = compress_out.valid;
    end

    register_rin.raddr1 = v.instr.raddr1;
    register_rin.raddr2 = v.instr.raddr2;

    forwarding_rin.raddr1 = v.instr.raddr1;
    forwarding_rin.raddr2 = v.instr.raddr2;
    forwarding_rin.rdata1 = register_out.rdata1;
    forwarding_rin.rdata2 = register_out.rdata2;

    v.instr.rdata1 = forwarding_out.data1;
    v.instr.rdata2 = forwarding_out.data2;

    v.instr.sdata = v.instr.rdata2;

    bcu_in.rdata1 = v.instr.rdata1;
    bcu_in.rdata2 = v.instr.rdata2;
    bcu_in.bcu_op = v.instr.bcu_op;

    v.instr.op.jump = v.instr.op.jal | v.instr.op.jalr | bcu_out.branch;

    agu_in.rdata1 = v.instr.rdata1;
    agu_in.imm = v.instr.imm;
    agu_in.pc = v.instr.pc;
    agu_in.lsu_op = v.instr.lsu_op;
    agu_in.auipc = v.instr.op.auipc;
    agu_in.jal = v.instr.op.jal;
    agu_in.jalr = v.instr.op.jalr;
    agu_in.branch = v.instr.op.branch;
    agu_in.load = v.instr.op.load;
    agu_in.store = v.instr.op.store;

    v.instr.address = agu_out.address;
    v.instr.byteenable = agu_out.byteenable;
    v.instr.ecause = agu_out.ecause;
    v.instr.etval = agu_out.etval;
    v.instr.op.exception = agu_out.exception;

    if ((v.stall | v.clear) == 1) begin
      v.instr.op = init_operation;
    end

    if (v.clear == 1) begin
      v.stall = 0;
    end

    if (v.instr.op.exception == 1) begin
      if (v.instr.op.load == 1) begin
        v.instr.op.load = 0;
        v.instr.op.wren = 0;
      end else if (v.instr.op.store == 1) begin
        v.instr.op.store = 0;
      end else if (v.instr.op.jump == 1) begin
        v.instr.op.jump = 0;
        v.instr.op.wren = 0;
      end else begin
        v.instr.op.exception = 0;
      end
    end

    if (v.miss == 1) begin
      v.instr.op.exception = 1;
      v.instr.ecause = except_instr_access_fault;
      v.instr.etval = r.instr.pc;
    end

    dmem_in.mem_valid = v.instr.op.load | v.instr.op.store;
    dmem_in.mem_fence = v.instr.op.fence;
    dmem_in.mem_spec = 0;
    dmem_in.mem_instr = 0;
    dmem_in.mem_mode = v.mode;
    dmem_in.mem_addr = v.instr.address;
    dmem_in.mem_wdata = store_data(v.instr.sdata,v.instr.lsu_op.lsu_sb,v.instr.lsu_op.lsu_sh,v.instr.lsu_op.lsu_sw);
    dmem_in.mem_wstrb = (v.instr.op.load == 1) ? 4'h0 : v.instr.byteenable;

    rin = v;

    y.instr = v.instr;
    y.stall = v.stall;
    y.clear = v.clear;

    q.instr = r.instr;
    q.stall = r.stall;
    q.clear = r.clear;

  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      r <= init_fetch_reg;
    end else begin
      r <= rin;
    end
  end

endmodule
