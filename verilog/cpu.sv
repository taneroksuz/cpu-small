import configure::*;
import wires::*;

module cpu
(
  input  logic reset,
  input  logic clock,
  output logic [0  : 0] rvfi_valid,
  output logic [63 : 0] rvfi_order,
  output logic [31 : 0] rvfi_insn,
  output logic [0  : 0] rvfi_trap,
  output logic [0  : 0] rvfi_halt,
  output logic [0  : 0] rvfi_intr,
  output logic [1  : 0] rvfi_mode,
  output logic [1  : 0] rvfi_ixl,
  output logic [4  : 0] rvfi_rs1_addr,
  output logic [4  : 0] rvfi_rs2_addr,
  output logic [31 : 0] rvfi_rs1_rdata,
  output logic [31 : 0] rvfi_rs2_rdata,
  output logic [4  : 0] rvfi_rd_addr,
  output logic [31 : 0] rvfi_rd_wdata,
  output logic [31 : 0] rvfi_pc_rdata,
  output logic [31 : 0] rvfi_pc_wdata,
  output logic [31 : 0] rvfi_mem_addr,
  output logic [3  : 0] rvfi_mem_rmask,
  output logic [3  : 0] rvfi_mem_wmask,
  output logic [31 : 0] rvfi_mem_rdata,
  output logic [31 : 0] rvfi_mem_wdata,
  output logic [0  : 0] imemory_valid,
  output logic [0  : 0] imemory_instr,
  output logic [31 : 0] imemory_addr,
  output logic [31 : 0] imemory_wdata,
  output logic [3  : 0] imemory_wstrb,
  input logic [31  : 0] imemory_rdata,
  input logic [0   : 0] imemory_error,
  input logic [0   : 0] imemory_ready,
  output logic [0  : 0] dmemory_valid,
  output logic [0  : 0] dmemory_instr,
  output logic [31 : 0] dmemory_addr,
  output logic [31 : 0] dmemory_wdata,
  output logic [3  : 0] dmemory_wstrb,
  input logic [31  : 0] dmemory_rdata,
  input logic [0   : 0] dmemory_error,
  input logic [0   : 0] dmemory_ready,
  input  logic [0  : 0] meip,
  input  logic [0  : 0] msip,
  input  logic [0  : 0] mtip,
  input  logic [63 : 0] mtime
);
  timeunit 1ns;
  timeprecision 1ps;

  agu_in_type agu_in;
  agu_out_type agu_out;
  alu_in_type alu_in;
  alu_out_type alu_out;
  bcu_in_type bcu_in;
  bcu_out_type bcu_out;
  lsu_in_type lsu_in;
  lsu_out_type lsu_out;
  csr_alu_in_type csr_alu_in;
  csr_alu_out_type csr_alu_out;
  div_in_type div_in;
  div_out_type div_out;
  mul_in_type mul_in;
  mul_out_type mul_out;
  predecoder_in_type predecoder_in;
  predecoder_out_type predecoder_out;
  postdecoder_in_type postdecoder_in;
  postdecoder_out_type postdecoder_out;
  compress_in_type compress_in;
  compress_out_type compress_out;
  forwarding_register_in_type forwarding_rin;
  forwarding_execute_in_type forwarding_ein;
  forwarding_out_type forwarding_out;
  csr_in_type csr_in;
  csr_out_type csr_out;
  csr_pmp_in_type csr_pmp_in;
  csr_pmp_out_type csr_pmp_out;
  register_read_in_type register_rin;
  register_write_in_type register_win;
  register_out_type register_out;
  fetch_in_type fetch_in_a;
  execute_in_type execute_in_a;
  fetch_out_type fetch_out_y;
  execute_out_type execute_out_y;
  fetch_in_type fetch_in_d;
  execute_in_type execute_in_d;
  fetch_out_type fetch_out_q;
  execute_out_type execute_out_q;
  mem_in_type fetchbuffer_in;
  mem_out_type fetchbuffer_out;
  mem_in_type imem_in;
  mem_out_type imem_out;
  mem_in_type dmem_in;
  mem_out_type dmem_out;
  mem_out_type ipmp_out;
  mem_out_type dpmp_out;
  rvfi_out_type rvfi_out;

  assign fetch_in_a.f = fetch_out_y;
  assign fetch_in_a.e = execute_out_y;
  assign execute_in_a.f = fetch_out_y;
  assign execute_in_a.e = execute_out_y;

  assign fetch_in_d.f = fetch_out_q;
  assign fetch_in_d.e = execute_out_q;
  assign execute_in_d.f = fetch_out_q;
  assign execute_in_d.e = execute_out_q;

  assign rvfi_valid = rvfi_out.rvfi_valid;
  assign rvfi_order = rvfi_out.rvfi_order;
  assign rvfi_insn = rvfi_out.rvfi_insn;
  assign rvfi_trap = rvfi_out.rvfi_trap;
  assign rvfi_halt = rvfi_out.rvfi_halt;
  assign rvfi_intr = rvfi_out.rvfi_intr;
  assign rvfi_mode = rvfi_out.rvfi_mode;
  assign rvfi_ixl = rvfi_out.rvfi_ixl;
  assign rvfi_rs1_addr = rvfi_out.rvfi_rs1_addr;
  assign rvfi_rs2_addr = rvfi_out.rvfi_rs2_addr;
  assign rvfi_rs1_rdata = rvfi_out.rvfi_rs1_rdata;
  assign rvfi_rs2_rdata = rvfi_out.rvfi_rs2_rdata;
  assign rvfi_rd_addr = rvfi_out.rvfi_rd_addr;
  assign rvfi_rd_wdata = rvfi_out.rvfi_rd_wdata;
  assign rvfi_pc_rdata = rvfi_out.rvfi_pc_rdata;
  assign rvfi_pc_wdata = rvfi_out.rvfi_pc_wdata;
  assign rvfi_mem_addr = rvfi_out.rvfi_mem_addr;
  assign rvfi_mem_rmask = rvfi_out.rvfi_mem_rmask;
  assign rvfi_mem_wmask = rvfi_out.rvfi_mem_wmask;
  assign rvfi_mem_rdata = rvfi_out.rvfi_mem_rdata;
  assign rvfi_mem_wdata = rvfi_out.rvfi_mem_wdata;

  agu agu_comp
  (
    .agu_in (agu_in),
    .agu_out (agu_out)
  );

  alu alu_comp
  (
    .alu_in (alu_in),
    .alu_out (alu_out)
  );

  bcu bcu_comp
  (
    .bcu_in (bcu_in),
    .bcu_out (bcu_out)
  );

  lsu lsu_comp
  (
    .lsu_in (lsu_in),
    .lsu_out (lsu_out)
  );

  csr_alu csr_alu_comp
  (
    .csr_alu_in (csr_alu_in),
    .csr_alu_out (csr_alu_out)
  );

  div div_comp
  (
    .reset (reset),
    .clock (clock),
    .div_in (div_in),
    .div_out (div_out)
  );

  mul #(mul_performance) mul_comp
  (
    .reset (reset),
    .clock (clock),
    .mul_in (mul_in),
    .mul_out (mul_out)
  );

  forwarding forwarding_comp
  (
    .forwarding_rin (forwarding_rin),
    .forwarding_ein (forwarding_ein),
    .forwarding_out (forwarding_out)
  );

  predecoder predecoder_comp
  (
    .predecoder_in (predecoder_in),
    .predecoder_out (predecoder_out)
  );

  postdecoder postdecoder_comp
  (
    .postdecoder_in (postdecoder_in),
    .postdecoder_out (postdecoder_out)
  );

  compress compress_comp
  (
    .compress_in (compress_in),
    .compress_out (compress_out)
  );

  register register_comp
  (
    .reset (reset),
    .clock (clock),
    .register_rin (register_rin),
    .register_win (register_win),
    .register_out (register_out)
  );

  csr csr_comp
  (
    .reset (reset),
    .clock (clock),
    .csr_in (csr_in),
    .csr_out (csr_out),
    .meip (meip),
    .msip (msip),
    .mtip (mtip),
    .mtime (mtime)
  );

  pmp pmp_comp
  (
    .reset (reset),
    .clock (clock),
    .csr_pmp_in (csr_pmp_in),
    .csr_pmp_out (csr_pmp_out),
    .imem_in (imem_in),
    .imem_out (ipmp_out),
    .dmem_in (dmem_in),
    .dmem_out (dpmp_out)
  );

  fetchbuffer fetchbuffer_comp
  (
    .reset (reset),
    .clock (clock),
    .fetchbuffer_in (fetchbuffer_in),
    .fetchbuffer_out (fetchbuffer_out),
    .imem_out (imem_out),
    .imem_in (imem_in)
  );

  fetch_stage fetch_stage_comp
  (
    .reset (reset),
    .clock (clock),
    .predecoder_out (predecoder_out),
    .predecoder_in (predecoder_in),
    .compress_out (compress_out),
    .compress_in (compress_in),
    .agu_out (agu_out),
    .agu_in (agu_in),
    .bcu_out (bcu_out),
    .bcu_in (bcu_in),
    .register_out (register_out),
    .register_rin (register_rin),
    .forwarding_out (forwarding_out),
    .forwarding_rin (forwarding_rin),
    .csr_out (csr_out),
    .fetchbuffer_out (fetchbuffer_out),
    .fetchbuffer_in (fetchbuffer_in),
    .dmem_in (dmem_in),
    .a (fetch_in_a),
    .d (fetch_in_d),
    .y (fetch_out_y),
    .q (fetch_out_q)
  );

  execute_stage execute_stage_comp
  (
    .reset (reset),
    .clock (clock),
    .postdecoder_out (postdecoder_out),
    .postdecoder_in (postdecoder_in),
    .alu_out (alu_out),
    .alu_in (alu_in),
    .lsu_out (lsu_out),
    .lsu_in (lsu_in),
    .csr_alu_out (csr_alu_out),
    .csr_alu_in (csr_alu_in),
    .div_out (div_out),
    .div_in (div_in),
    .mul_out (mul_out),
    .mul_in (mul_in),
    .register_win (register_win),
    .forwarding_ein (forwarding_ein),
    .csr_out (csr_out),
    .csr_in (csr_in),
    .csr_pmp_out (csr_pmp_out),
    .csr_pmp_in (csr_pmp_in),
    .dmem_out (dmem_out),
    .rvfi_out (rvfi_out),
    .a (execute_in_a),
    .d (execute_in_d),
    .y (execute_out_y),
    .q (execute_out_q)
  );

  assign imemory_valid = imem_in.mem_valid;
  assign imemory_instr = imem_in.mem_instr;
  assign imemory_addr = imem_in.mem_addr;
  assign imemory_wdata = imem_in.mem_wdata;
  assign imemory_wstrb = imem_in.mem_wstrb;
  assign imem_out.mem_rdata = imemory_rdata;
  assign imem_out.mem_error = imemory_error;
  assign imem_out.mem_ready = imemory_ready;

  assign dmemory_valid = dmem_in.mem_valid;
  assign dmemory_instr = dmem_in.mem_instr;
  assign dmemory_addr = dmem_in.mem_addr;
  assign dmemory_wdata = dmem_in.mem_wdata;
  assign dmemory_wstrb = dmem_in.mem_wstrb;
  assign dmem_out.mem_rdata = dmemory_rdata;
  assign dmem_out.mem_error = dmemory_error;
  assign dmem_out.mem_ready = dmemory_ready;

endmodule
