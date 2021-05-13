import wires::*;

module cpu
(
  input logic rst,
  input logic clk,
  output logic [0  : 0] memory_valid,
  output logic [0  : 0] memory_instr,
  output logic [31 : 0] memory_addr,
  output logic [31 : 0] memory_wdata,
  output logic [3  : 0] memory_wstrb,
  input logic [31  : 0] memory_rdata,
  input logic [0   : 0] memory_ready,
  input logic [0   :0] extern_irpt,
  input logic [0   :0] timer_irpt,
  input logic [0   :0] soft_irpt
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
  prefetch_in_type prefetch_in;
  prefetch_out_type prefetch_out;
  mem_in_type imem_in;
  mem_out_type imem_out;
  mem_in_type dmem_in;
  mem_out_type dmem_out;

  assign fetch_in_a.f = fetch_out_y;
  assign fetch_in_a.e = execute_out_y;
  assign execute_in_a.f = fetch_out_y;
  assign execute_in_a.e = execute_out_y;

  assign fetch_in_d.f = fetch_out_q;
  assign fetch_in_d.e = execute_out_q;
  assign execute_in_d.f = fetch_out_q;
  assign execute_in_d.e = execute_out_q;

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
    .rst (rst),
    .clk (clk),
    .div_in (div_in),
    .div_out (div_out)
  );

  mul mul_comp
  (
    .rst (rst),
    .clk (clk),
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
    .rst (rst),
    .clk (clk),
    .register_rin (register_rin),
    .register_win (register_win),
    .register_out (register_out)
  );

  csr csr_comp
  (
    .rst (rst),
    .clk (clk),
    .csr_in (csr_in),
    .csr_out (csr_out),
    .extern_irpt (extern_irpt),
    .timer_irpt (timer_irpt),
    .soft_irpt (soft_irpt)
  );

  arbiter arbiter_comp
  (
    .rst (rst),
    .clk (clk),
    .imem_in (imem_in),
    .imem_out (imem_out),
    .dmem_in (dmem_in),
    .dmem_out (dmem_out),
    .memory_valid (memory_valid),
    .memory_instr (memory_instr),
    .memory_addr (memory_addr),
    .memory_wdata (memory_wdata),
    .memory_wstrb (memory_wstrb),
    .memory_rdata (memory_rdata),
    .memory_ready (memory_ready)
  );

  prefetch prefetch_comp
  (
    .rst (rst),
    .clk (clk),
    .prefetch_in (prefetch_in),
    .prefetch_out (prefetch_out)
  );

  fetch_stage fetch_stage_comp
  (
    .rst (rst),
    .clk (clk),
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
    .prefetch_out (prefetch_out),
    .prefetch_in (prefetch_in),
    .imem_out (imem_out),
    .imem_in (imem_in),
    .dmem_in (dmem_in),
    .a (fetch_in_a),
    .d (fetch_in_d),
    .y (fetch_out_y),
    .q (fetch_out_q)
  );

  execute_stage execute_stage_comp
  (
    .rst (rst),
    .clk (clk),
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
    .dmem_out (dmem_out),
    .a (execute_in_a),
    .d (execute_in_d),
    .y (execute_out_y),
    .q (execute_out_q)
  );

endmodule
