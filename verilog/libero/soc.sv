import configure::*;

module soc
(
  input  logic reset,
  input  logic clock,
  input  logic clock_irpt,
  input  logic uart_rx,
  output logic uart_tx,
  input  logic [31 : 0] irpt,
  output logic [31 : 0] m_ahb_haddr,
  output logic [31 : 0] m_ahb_hwdata,
  output logic [3  : 0] m_ahb_hwstrb,
  output logic [0  : 0] m_ahb_hwrite,
  output logic [2  : 0] m_ahb_hsize,
  output logic [2  : 0] m_ahb_hburst,
  output logic [3  : 0] m_ahb_hprot,
  output logic [1  : 0] m_ahb_htrans,
  output logic [0  : 0] m_ahb_hmastlock,
  input  logic [31 : 0] m_ahb_hrdata,
  input  logic [0  : 0] m_ahb_hready,
  input  logic [0  : 0] m_ahb_hresp
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

  logic [0  : 0] uart_valid;
  logic [0  : 0] uart_instr;
  logic [31 : 0] uart_addr;
  logic [31 : 0] uart_wdata;
  logic [3  : 0] uart_wstrb;
  logic [31 : 0] uart_rdata;
  logic [0  : 0] uart_ready;

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

  logic [0  : 0] ahb_valid;
  logic [0  : 0] ahb_instr;
  logic [31 : 0] ahb_addr;
  logic [31 : 0] ahb_wdata;
  logic [3  : 0] ahb_wstrb;
  logic [31 : 0] ahb_rdata;
  logic [0  : 0] ahb_ready;

  logic [0  : 0] meip;
  logic [0  : 0] msip;
  logic [0  : 0] mtip;

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
    ahb_valid = 0;

    base_addr = 0;

    if (memory_valid == 1) begin
      if (memory_addr >= ahb_base_addr &&
        memory_addr < ahb_top_addr) begin
          mem_error = 0;
          rom_valid = 0;
          uart_valid = 0;
          clint_valid = 0;
          clic_valid = 0;
          ahb_valid = memory_valid;
          base_addr = ahb_base_addr;
      end else if (memory_addr >= clic_base_addr &&
        memory_addr < clic_top_addr) begin
          mem_error = 0;
          rom_valid = 0;
          uart_valid = 0;
          clint_valid = 0;
          clic_valid = memory_valid;
          ahb_valid = 0;
          base_addr = clic_base_addr;
      end else if (memory_addr >= clint_base_addr &&
        memory_addr < clint_top_addr) begin
          mem_error = 0;
          rom_valid = 0;
          uart_valid = 0;
          clint_valid = memory_valid;
          clic_valid = 0;
          ahb_valid = 0;
          base_addr = clint_base_addr;
      end else if (memory_addr >= uart_base_addr &&
        memory_addr < uart_top_addr) begin
          mem_error = 0;
          rom_valid = 0;
          uart_valid = memory_valid;
          clint_valid = 0;
          clic_valid = 0;
          ahb_valid = 0;
          base_addr = uart_base_addr;
      end else if (memory_addr >= rom_base_addr &&
        memory_addr < rom_top_addr) begin
          mem_error = 0;
          rom_valid = memory_valid;
          uart_valid = 0;
          clint_valid = 0;
          clic_valid = 0;
          ahb_valid = 0;
          base_addr = rom_base_addr;
      end else begin
          mem_error = 1;
          rom_valid = 0;
          uart_valid = 0;
          clint_valid = 0;
          clic_valid = 0;
          ahb_valid = 0;
          base_addr = 0;
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

    ahb_instr = memory_instr;
    ahb_addr = mem_addr;
    ahb_wdata = memory_wdata;
    ahb_wstrb = memory_wstrb;

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
    end else if (ahb_ready == 1) begin
      memory_rdata = ahb_rdata;
      memory_error = 0;
      memory_ready = ahb_ready;
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

  uart uart_comp
  (
    .reset (reset),
    .clock (clock),
    .uart_valid (uart_valid),
    .uart_instr (uart_instr),
    .uart_addr (uart_addr),
    .uart_wdata (uart_wdata),
    .uart_wstrb (uart_wstrb),
    .uart_rdata (uart_rdata),
    .uart_ready (uart_ready),
    .uart_rx (uart_rx),
    .uart_tx (uart_tx)
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

  ahb ahb_comp
  (
    .reset (reset),
    .clock (clock),
    .ahb_valid (ahb_valid),
    .ahb_instr (ahb_instr),
    .ahb_addr (ahb_addr),
    .ahb_wdata (ahb_wdata),
    .ahb_wstrb (ahb_wstrb),
    .ahb_rdata (ahb_rdata),
    .ahb_ready (ahb_ready),
    .m_ahb_haddr (m_ahb_haddr),
    .m_ahb_hwdata (m_ahb_hwdata),
    .m_ahb_hwstrb (m_ahb_hwstrb),
    .m_ahb_hwrite (m_ahb_hwrite),
    .m_ahb_hsize (m_ahb_hsize),
    .m_ahb_hburst (m_ahb_hburst),
    .m_ahb_hprot (m_ahb_hprot),
    .m_ahb_htrans (m_ahb_htrans),
    .m_ahb_hmastlock (m_ahb_hmastlock),
    .m_ahb_hrdata (m_ahb_hrdata),
    .m_ahb_hready (m_ahb_hready),
    .m_ahb_hresp (m_ahb_hresp)
  );

endmodule
