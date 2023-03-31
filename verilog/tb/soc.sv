module soc
(
  input  logic reset,
  input  logic clock,
  input  logic clock_irpt
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

  logic [0  : 0] bram_valid;
  logic [0  : 0] bram_instr;
  logic [31 : 0] bram_addr;
  logic [31 : 0] bram_wdata;
  logic [3  : 0] bram_wstrb;
  logic [31 : 0] bram_rdata;
  logic [0  : 0] bram_ready;

  logic [0  : 0] print_valid;
  logic [0  : 0] print_instr;
  logic [31 : 0] print_addr;
  logic [31 : 0] print_wdata;
  logic [3  : 0] print_wstrb;
  logic [31 : 0] print_rdata;
  logic [0  : 0] print_ready;

  logic [0  : 0] clint_valid;
  logic [0  : 0] clint_instr;
  logic [31 : 0] clint_addr;
  logic [31 : 0] clint_wdata;
  logic [3  : 0] clint_wstrb;
  logic [31 : 0] clint_rdata;
  logic [0  : 0] clint_ready;

  logic [0  : 0] clic_valid;
  logic [0  : 0] clic_instr;
  logic [31 : 0] clic_addr;
  logic [31 : 0] clic_wdata;
  logic [3  : 0] clic_wstrb;
  logic [31 : 0] clic_rdata;
  logic [0  : 0] clic_ready;

  logic [0 : 0] meip;
  logic [0 : 0] msip;
  logic [0 : 0] mtip;

  logic [31: 0] irpt;

  logic [11 : 0] meid;
  logic [63 : 0] mtime;

  logic [31 : 0] mem_addr;

  logic [31 : 0] base_addr;

  logic [31 : 0] host[0:0] = '{default:'0};

  initial begin
    $readmemh("host.dat", host);
  end

  always_comb begin

    mem_error = 0;

    bram_valid = 0;
    print_valid = 0;
    clint_valid = 0;
    clic_valid = 0;

    base_addr = 0;

    if (memory_valid == 1) begin
      if (memory_addr >= clint_base_addr &&
        memory_addr < clint_top_addr) begin
          mem_error = 0;
          bram_valid = 0;
          print_valid = 0;
          clint_valid = memory_valid;
          clic_valid = 0;
          base_addr = clint_base_addr;
      end else if (memory_addr >= clic_base_addr &&
        memory_addr < clic_top_addr) begin
          mem_error = 0;
          bram_valid = 0;
          print_valid = 0;
          clint_valid = 0;
          clic_valid = memory_valid;
          base_addr = clic_base_addr;
      end else if (memory_addr >= print_base_addr &&
        memory_addr < print_top_addr) begin
          mem_error = 0;
          bram_valid = 0;
          print_valid = memory_valid;
          clint_valid = 0;
          clic_valid = 0;
          base_addr = print_base_addr;
      end else if (memory_addr >= bram_base_addr &&
        memory_addr < bram_top_addr) begin
          mem_error = 0;
          bram_valid = memory_valid;
          print_valid = 0;
          clint_valid = 0;
          clic_valid = 0;
          base_addr = bram_base_addr;
      end else if (memory_addr == host[0]) begin
          mem_error = 0;
          bram_valid = memory_valid;
          print_valid = 0;
          clint_valid = 0;
          clic_valid = 0;
          base_addr = bram_base_addr;
      end else begin
          mem_error = 1;
          bram_valid = 0;
          print_valid = 0;
          clint_valid = 0;
          clic_valid = 0;
          base_addr = 0;
      end
    end

    mem_addr = memory_addr - base_addr;

    bram_instr = memory_instr;
    bram_addr = mem_addr;
    bram_wdata = memory_wdata;
    bram_wstrb = memory_wstrb;

    print_instr = memory_instr;
    print_addr = mem_addr;
    print_wdata = memory_wdata;
    print_wstrb = memory_wstrb;

    clint_instr = memory_instr;
    clint_addr = mem_addr;
    clint_wdata = memory_wdata;
    clint_wstrb = memory_wstrb;

    clic_instr = memory_instr;
    clic_addr = mem_addr;
    clic_wdata = memory_wdata;
    clic_wstrb = memory_wstrb;

    if (bram_ready == 1) begin
      memory_rdata = bram_rdata;
      memory_error = 0;
      memory_ready = bram_ready;
    end else if (print_ready == 1) begin
      memory_rdata = print_rdata;
      memory_error = 0;
      memory_ready = print_ready;
    end else if (clint_ready == 1) begin
      memory_rdata = clint_rdata;
      memory_error = 0;
      memory_ready = clint_ready;
    end else if (clic_ready == 1) begin
      memory_rdata = clic_rdata;
      memory_error = 0;
      memory_ready = clic_ready;
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
    .memory_valid (memory_valid),
    .memory_instr (memory_instr),
    .memory_addr (memory_addr),
    .memory_wdata (memory_wdata),
    .memory_wstrb (memory_wstrb),
    .memory_rdata (memory_rdata),
    .memory_error (memory_error),
    .memory_ready (memory_ready),
    .meip (meip),
    .msip (msip),
    .mtip (mtip),
    .mtime (mtime)
  );

  bram bram_comp
  (
    .reset (reset),
    .clock (clock),
    .bram_valid (bram_valid),
    .bram_instr (bram_instr),
    .bram_addr (bram_addr),
    .bram_wdata (bram_wdata),
    .bram_wstrb (bram_wstrb),
    .bram_rdata (bram_rdata),
    .bram_ready (bram_ready)
  );

  print print_comp
  (
    .reset (reset),
    .clock (clock),
    .print_valid (print_valid),
    .print_instr (print_instr),
    .print_addr (print_addr),
    .print_wdata (print_wdata),
    .print_wstrb (print_wstrb),
    .print_rdata (print_rdata),
    .print_ready (print_ready)
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

  clic clic_comp
  (
    .reset (reset),
    .clock (clock),
    .clock_irpt (clock_irpt),
    .clic_valid (clic_valid),
    .clic_instr (clic_instr),
    .clic_addr (clic_addr),
    .clic_wdata (clic_wdata),
    .clic_wstrb (clic_wstrb),
    .clic_rdata (clic_rdata),
    .clic_ready (clic_ready),
    .clic_meip (meip),
    .clic_meid (meid),
    .clic_irpt (irpt)
  );

endmodule
