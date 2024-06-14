import configure::*;

module soc
(
  input  logic reset,
  input  logic clock,
  input  logic clock_slow,
  output logic [0  : 0] uart_valid,
  output logic [0  : 0] uart_instr,
  output logic [31 : 0] uart_addr,
  output logic [31 : 0] uart_wdata,
  output logic [3  : 0] uart_wstrb,
  input  logic [31 : 0] uart_rdata,
  input  logic [0  : 0] uart_ready
);

  timeunit 1ns;
  timeprecision 1ps;

  logic [0  : 0] rvfi_valid;
  logic [63 : 0] rvfi_order;
  logic [31 : 0] rvfi_insn;
  logic [0  : 0] rvfi_trap;
  logic [0  : 0] rvfi_halt;
  logic [0  : 0] rvfi_intr;
  logic [1  : 0] rvfi_mode;
  logic [1  : 0] rvfi_ixl;
  logic [4  : 0] rvfi_rs1_addr;
  logic [4  : 0] rvfi_rs2_addr;
  logic [31 : 0] rvfi_rs1_rdata;
  logic [31 : 0] rvfi_rs2_rdata;
  logic [4  : 0] rvfi_rd_addr;
  logic [31 : 0] rvfi_rd_wdata;
  logic [31 : 0] rvfi_pc_rdata;
  logic [31 : 0] rvfi_pc_wdata;
  logic [31 : 0] rvfi_mem_addr;
  logic [3  : 0] rvfi_mem_rmask;
  logic [3  : 0] rvfi_mem_wmask;
  logic [31 : 0] rvfi_mem_rdata;
  logic [31 : 0] rvfi_mem_wdata;

  logic [0  : 0] imemory_valid;
  logic [0  : 0] imemory_instr;
  logic [31 : 0] imemory_addr;
  logic [31 : 0] imemory_wdata;
  logic [3  : 0] imemory_wstrb;
  logic [31 : 0] imemory_rdata;
  logic [0  : 0] imemory_error;
  logic [0  : 0] imemory_ready;

  logic [0  : 0] dmemory_valid;
  logic [0  : 0] dmemory_instr;
  logic [31 : 0] dmemory_addr;
  logic [31 : 0] dmemory_wdata;
  logic [3  : 0] dmemory_wstrb;
  logic [31 : 0] dmemory_rdata;
  logic [0  : 0] dmemory_error;
  logic [0  : 0] dmemory_ready;

  logic [0  : 0] memory_valid;
  logic [0  : 0] memory_instr;
  logic [31 : 0] memory_addr;
  logic [31 : 0] memory_wdata;
  logic [3  : 0] memory_wstrb;
  logic [31 : 0] memory_rdata;
  logic [0  : 0] memory_error;
  logic [0  : 0] memory_ready;

  logic [0  : 0] mem_error;
  logic [0  : 0] mem_ready;

  logic [0  : 0] rom_valid;
  logic [0  : 0] rom_instr;
  logic [31 : 0] rom_addr;
  logic [31 : 0] rom_rdata;
  logic [0  : 0] rom_ready;

  logic [0  : 0] clint_valid;
  logic [0  : 0] clint_instr;
  logic [31 : 0] clint_addr;
  logic [31 : 0] clint_wdata;
  logic [3  : 0] clint_wstrb;
  logic [31 : 0] clint_rdata;
  logic [0  : 0] clint_ready;

  logic [0  : 0] tim_valid;
  logic [0  : 0] tim_instr;
  logic [31 : 0] tim_addr;
  logic [31 : 0] tim_wdata;
  logic [3  : 0] tim_wstrb;
  logic [31 : 0] tim_rdata;
  logic [0  : 0] tim_ready;

  logic [0  : 0] clic_valid;
  logic [0  : 0] clic_instr;
  logic [31 : 0] clic_addr;
  logic [31 : 0] clic_wdata;
  logic [3  : 0] clic_wstrb;
  logic [31 : 0] clic_rdata;
  logic [0  : 0] clic_ready;

  logic [0  : 0] clic_slow_valid;
  logic [0  : 0] clic_slow_instr;
  logic [31 : 0] clic_slow_addr;
  logic [31 : 0] clic_slow_wdata;
  logic [3  : 0] clic_slow_wstrb;
  logic [31 : 0] clic_slow_rdata;
  logic [0  : 0] clic_slow_ready;

  logic [0  : 0] ram_valid;
  logic [0  : 0] ram_instr;
  logic [31 : 0] ram_addr;
  logic [31 : 0] ram_wdata;
  logic [3  : 0] ram_wstrb;
  logic [31 : 0] ram_rdata;
  logic [0  : 0] ram_ready;

  logic [0  : 0] ram_slow_valid;
  logic [0  : 0] ram_slow_instr;
  logic [31 : 0] ram_slow_addr;
  logic [31 : 0] ram_slow_wdata;
  logic [3  : 0] ram_slow_wstrb;
  logic [31 : 0] ram_slow_rdata;
  logic [0  : 0] ram_slow_ready;

  logic [0 : 0] meip;
  logic [0 : 0] msip;
  logic [0 : 0] mtip;

  logic [31: 0] irpt;

  logic [11 : 0] meid;
  logic [63 : 0] mtime;

  logic [31 : 0] mem_addr;

  logic [31 : 0] base_addr;

  always_comb begin

    mem_error = 0;

    rom_valid = 0;
    uart_valid = 0;
    clint_valid = 0;
    clic_valid = 0;
    tim_valid = 0;
    ram_valid = 0;

    base_addr = 0;

    if (memory_valid == 1) begin
      if (memory_addr >= ram_base_addr && memory_addr < ram_top_addr) begin
          ram_valid = memory_valid;
          base_addr = ram_base_addr;
      end else if (memory_addr >= tim_base_addr && memory_addr < tim_top_addr) begin
          tim_valid = memory_valid;
          base_addr = tim_base_addr;
      end else if (memory_addr >= clic_base_addr && memory_addr < clic_top_addr) begin
          clic_valid = memory_valid;
          base_addr = clic_base_addr;
      end else if (memory_addr >= clint_base_addr && memory_addr < clint_top_addr) begin
          clint_valid = memory_valid;
          base_addr = clint_base_addr;
      end else if (memory_addr >= uart_base_addr && memory_addr < uart_top_addr) begin
          uart_valid = memory_valid;
          base_addr = uart_base_addr;
      end else if (memory_addr >= rom_base_addr && memory_addr < rom_top_addr) begin
          rom_valid = memory_valid;
          base_addr = rom_base_addr;
      end else begin
          mem_error = 1;
      end
    end

    mem_addr = memory_addr - base_addr;

    rom_instr = memory_instr;
    rom_addr = mem_addr;

    uart_instr = memory_instr;
    uart_addr = mem_addr;
    uart_wdata = memory_wdata;
    uart_wstrb = memory_wstrb;

    clint_instr = memory_instr;
    clint_addr = mem_addr;
    clint_wdata = memory_wdata;
    clint_wstrb = memory_wstrb;

    clic_instr = memory_instr;
    clic_addr = mem_addr;
    clic_wdata = memory_wdata;
    clic_wstrb = memory_wstrb;

    tim_instr = memory_instr;
    tim_addr = mem_addr;
    tim_wdata = memory_wdata;
    tim_wstrb = memory_wstrb;

    ram_instr = memory_instr;
    ram_addr = mem_addr;
    ram_wdata = memory_wdata;
    ram_wstrb = memory_wstrb;

    if (rom_ready == 1) begin
      memory_rdata = rom_rdata;
      memory_error = 0;
      memory_ready = rom_ready;
    end else if (uart_ready == 1) begin
      memory_rdata = uart_rdata;
      memory_error = 0;
      memory_ready = uart_ready;
    end else if (clint_ready == 1) begin
      memory_rdata = clint_rdata;
      memory_error = 0;
      memory_ready = clint_ready;
    end else if (clic_ready == 1) begin
      memory_rdata = clic_rdata;
      memory_error = 0;
      memory_ready = clic_ready;
    end else if (tim_ready == 1) begin
      memory_rdata = tim_rdata;
      memory_error = 0;
      memory_ready = tim_ready;
    end else if (ram_ready == 1) begin
      memory_rdata = ram_rdata;
      memory_error = 0;
      memory_ready = ram_ready;
    end else if (mem_ready == 1) begin
      memory_rdata = 0;
      memory_error = 1;
      memory_ready = 1;
    end else begin
      memory_rdata = 0;
      memory_error = 0;
      memory_ready = 0;
    end

  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      mem_ready <= 0;
    end else begin
      mem_ready <= mem_error;
    end
  end

  cpu cpu_comp
  (
    .reset (reset),
    .clock (clock),
    .rvfi_valid (rvfi_valid),
    .rvfi_order (rvfi_order),
    .rvfi_insn (rvfi_insn),
    .rvfi_trap (rvfi_trap),
    .rvfi_halt (rvfi_halt),
    .rvfi_intr (rvfi_intr),
    .rvfi_mode (rvfi_mode),
    .rvfi_ixl (rvfi_ixl),
    .rvfi_rs1_addr (rvfi_rs1_addr),
    .rvfi_rs2_addr (rvfi_rs2_addr),
    .rvfi_rs1_rdata (rvfi_rs1_rdata),
    .rvfi_rs2_rdata (rvfi_rs2_rdata),
    .rvfi_rd_addr (rvfi_rd_addr),
    .rvfi_rd_wdata (rvfi_rd_wdata),
    .rvfi_pc_rdata (rvfi_pc_rdata),
    .rvfi_pc_wdata (rvfi_pc_wdata),
    .rvfi_mem_addr (rvfi_mem_addr),
    .rvfi_mem_rmask (rvfi_mem_rmask),
    .rvfi_mem_wmask (rvfi_mem_wmask),
    .rvfi_mem_rdata (rvfi_mem_rdata),
    .rvfi_mem_wdata (rvfi_mem_wdata),
    .imemory_valid (imemory_valid),
    .imemory_instr (imemory_instr),
    .imemory_addr (imemory_addr),
    .imemory_wdata (imemory_wdata),
    .imemory_wstrb (imemory_wstrb),
    .imemory_rdata (imemory_rdata),
    .imemory_error (imemory_error),
    .imemory_ready (imemory_ready),
    .dmemory_valid (dmemory_valid),
    .dmemory_instr (dmemory_instr),
    .dmemory_addr (dmemory_addr),
    .dmemory_wdata (dmemory_wdata),
    .dmemory_wstrb (dmemory_wstrb),
    .dmemory_rdata (dmemory_rdata),
    .dmemory_error (dmemory_error),
    .dmemory_ready (dmemory_ready),
    .meip (meip),
    .msip (msip),
    .mtip (mtip),
    .mtime (mtime)
  );

  arbiter arbiter_comp
  (
    .reset (reset),
    .clock (clock),
    .imemory_valid (imemory_valid),
    .imemory_instr (imemory_instr),
    .imemory_addr (imemory_addr),
    .imemory_wdata (imemory_wdata),
    .imemory_wstrb (imemory_wstrb),
    .imemory_rdata (imemory_rdata),
    .imemory_error (imemory_error),
    .imemory_ready (imemory_ready),
    .dmemory_valid (dmemory_valid),
    .dmemory_instr (dmemory_instr),
    .dmemory_addr (dmemory_addr),
    .dmemory_wdata (dmemory_wdata),
    .dmemory_wstrb (dmemory_wstrb),
    .dmemory_rdata (dmemory_rdata),
    .dmemory_error (dmemory_error),
    .dmemory_ready (dmemory_ready),
    .memory_valid (memory_valid),
    .memory_instr (memory_instr),
    .memory_addr (memory_addr),
    .memory_wdata (memory_wdata),
    .memory_wstrb (memory_wstrb),
    .memory_rdata (memory_rdata),
    .memory_error (memory_error),
    .memory_ready (memory_ready)
  );

  rom rom_comp
  (
    .reset (reset),
    .clock (clock),
    .rom_valid (rom_valid),
    .rom_instr (rom_instr),
    .rom_addr (rom_addr),
    .rom_rdata (rom_rdata),
    .rom_ready (rom_ready)
  );

  clint clint_comp
  (
    .reset (reset),
    .clock (clock),
    .clint_valid (clint_valid),
    .clint_instr (clint_instr),
    .clint_addr (clint_addr),
    .clint_wdata (clint_wdata),
    .clint_wstrb (clint_wstrb),
    .clint_rdata (clint_rdata),
    .clint_ready (clint_ready),
    .clint_msip (msip),
    .clint_mtip (mtip),
    .clint_mtime (mtime)
  );

  ccd #(
    .clock_rate (clk_divider_slow)
  ) ccd_clic_comp
  (
    .reset (reset),
    .clock (clock),
    .clock_slow (clock_slow),
    .memory_valid (clic_valid),
    .memory_instr (clic_instr),
    .memory_addr (clic_addr),
    .memory_wdata (clic_wdata),
    .memory_wstrb (clic_wstrb),
    .memory_rdata (clic_rdata),
    .memory_ready (clic_ready),
    .memory_slow_valid (clic_slow_valid),
    .memory_slow_instr (clic_slow_instr),
    .memory_slow_addr (clic_slow_addr),
    .memory_slow_wdata (clic_slow_wdata),
    .memory_slow_wstrb (clic_slow_wstrb),
    .memory_slow_rdata (clic_slow_rdata),
    .memory_slow_ready (clic_slow_ready)
  );

  clic clic_comp
  (
    .reset (reset),
    .clock (clock_slow),
    .clic_valid (clic_slow_valid),
    .clic_instr (clic_slow_instr),
    .clic_addr (clic_slow_addr),
    .clic_wdata (clic_slow_wdata),
    .clic_wstrb (clic_slow_wstrb),
    .clic_rdata (clic_slow_rdata),
    .clic_ready (clic_slow_ready),
    .clic_meip (meip),
    .clic_meid (meid),
    .clic_irpt (irpt)
  );

  tim tim_comp
  (
    .reset (reset),
    .clock (clock),
    .tim_valid (tim_valid),
    .tim_instr (tim_instr),
    .tim_addr (tim_addr),
    .tim_wdata (tim_wdata),
    .tim_wstrb (tim_wstrb),
    .tim_rdata (tim_rdata),
    .tim_ready (tim_ready)
  );

  ccd #(
    .clock_rate (clk_divider_slow)
  ) ccd_ram_comp
  (
    .reset (reset),
    .clock (clock),
    .clock_slow (clock_slow),
    .memory_valid (ram_valid),
    .memory_instr (ram_instr),
    .memory_addr (ram_addr),
    .memory_wdata (ram_wdata),
    .memory_wstrb (ram_wstrb),
    .memory_rdata (ram_rdata),
    .memory_ready (ram_ready),
    .memory_slow_valid (ram_slow_valid),
    .memory_slow_instr (ram_slow_instr),
    .memory_slow_addr (ram_slow_addr),
    .memory_slow_wdata (ram_slow_wdata),
    .memory_slow_wstrb (ram_slow_wstrb),
    .memory_slow_rdata (ram_slow_rdata),
    .memory_slow_ready (ram_slow_ready)
  );

  ram ram_comp
  (
    .reset (reset),
    .clock (clock_slow),
    .ram_valid (ram_slow_valid),
    .ram_instr (ram_slow_instr),
    .ram_addr (ram_slow_addr),
    .ram_wdata (ram_slow_wdata),
    .ram_wstrb (ram_slow_wstrb),
    .ram_rdata (ram_slow_rdata),
    .ram_ready (ram_slow_ready)
  );

endmodule
