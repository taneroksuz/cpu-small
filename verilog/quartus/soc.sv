import configure::*;

module soc
(
  input  logic reset,
  input  logic clock,
  input  logic rx,
  output logic tx,
  input  logic [31 : 0] irpt,
  output logic [31 : 0] m_avl_address,
  output logic [3  : 0] m_avl_byteenable,
  output logic [0  : 0] m_avl_lock,
  output logic [0  : 0] m_avl_read,
  output logic [31 : 0] m_avl_writedata,
  output logic [0  : 0] m_avl_write,
  output logic [2  : 0] m_avl_burstcount,
  input  logic [31 : 0] m_avl_readdata,
  input  logic [1  : 0] m_avl_response,
  input  logic [0  : 0] m_avl_waitrequest,
  input  logic [0  : 0] m_avl_readdatavalid,
  input  logic [0  : 0] m_avl_writeresponsevalid
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
  logic [0  : 0] memory_ready;

  logic [0  : 0] bram_valid;
  logic [0  : 0] bram_wen;
  logic [0  : 0] bram_instr;
  logic [31 : 0] bram_addr;
  logic [31 : 0] bram_wdata;
  logic [3  : 0] bram_wstrb;
  logic [31 : 0] bram_rdata;
  logic [0  : 0] bram_ready;

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

  logic [0  : 0] avl_valid;
  logic [0  : 0] avl_instr;
  logic [31 : 0] avl_addr;
  logic [31 : 0] avl_wdata;
  logic [3  : 0] avl_wstrb;
  logic [31 : 0] avl_rdata;
  logic [0  : 0] avl_ready;

  logic [0  : 0] meip;
  logic [0  : 0] msip;
  logic [0  : 0] mtip;

  logic [11 : 0] meid;
  logic [63 : 0] mtime;

  logic [31 : 0] mem_addr;

  logic [31 : 0] base_addr;

  always_comb begin

    bram_valid = 0;
    uart_valid = 0;
    clint_valid = 0;
    clic_valid = 0;
    avl_valid = 0;

    base_addr = 0;

    if (memory_valid == 1) begin
      if (memory_addr >= avl_base_addr &&
        memory_addr < avl_top_addr) begin
          bram_valid = 0;
          uart_valid = 0;
          clint_valid = 0;
          clic_valid = 0;
          avl_valid = memory_valid;
          base_addr = bram_base_addr;
      end else if (memory_addr >= clic_base_addr &&
        memory_addr < clic_top_addr) begin
          bram_valid = 0;
          uart_valid = 0;
          clint_valid = 0;
          clic_valid = memory_valid;
          avl_valid = 0;
          base_addr = clic_base_addr;
      end else if (memory_addr >= clint_base_addr &&
        memory_addr < clint_top_addr) begin
          bram_valid = 0;
          uart_valid = 0;
          clint_valid = memory_valid;
          clic_valid = 0;
          avl_valid = 0;
          base_addr = clint_base_addr;
      end else if (memory_addr >= uart_base_addr &&
        memory_addr < uart_top_addr) begin
          bram_valid = 0;
          uart_valid = memory_valid;
          clint_valid = 0;
          clic_valid = 0;
          avl_valid = 0;
          base_addr = uart_base_addr;
      end else if (memory_addr >= bram_base_addr &&
        memory_addr < bram_top_addr) begin
          bram_valid = memory_valid;
          uart_valid = 0;
          clint_valid = 0;
          clic_valid = 0;
          avl_valid = 0;
          base_addr = bram_base_addr;
      end else begin
          bram_valid = 0;
          uart_valid = 0;
          clint_valid = 0;
          clic_valid = 0;
          avl_valid = 0;
          base_addr = 0;
      end
    end

    mem_addr = memory_addr - base_addr;

    bram_instr = memory_instr;
    bram_addr = mem_addr;
    bram_wdata = memory_wdata;
    bram_wstrb = memory_wstrb;

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

    avl_instr = memory_instr;
    avl_addr = mem_addr;
    avl_wdata = memory_wdata;
    avl_wstrb = memory_wstrb;

    if (bram_ready == 1) begin
      memory_rdata = bram_rdata;
      memory_ready = bram_ready;
    end else if  (uart_ready == 1) begin
      memory_rdata = uart_rdata;
      memory_ready = uart_ready;
    end else if  (clint_ready == 1) begin
      memory_rdata = clint_rdata;
      memory_ready = clint_ready;
    end else if  (clic_ready == 1) begin
      memory_rdata = clic_rdata;
      memory_ready = clic_ready;
    end else if  (avl_ready == 1) begin
      memory_rdata = avl_rdata;
      memory_ready = avl_ready;
    end else begin
      memory_rdata = 0;
      memory_ready = 0;
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
    .uart_rx (rx),
    .uart_tx (tx)
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

  avl avl_comp
  (
    .reset (reset),
    .clock (clock),
    .avl_valid (avl_valid),
    .avl_instr (avl_instr),
    .avl_addr (avl_addr),
    .avl_wdata (avl_wdata),
    .avl_wstrb (avl_wstrb),
    .avl_rdata (avl_rdata),
    .avl_ready (avl_ready),
    .m_avl_address (m_avl_address),
    .m_avl_byteenable (m_avl_byteenable),
    .m_avl_lock (m_avl_lock),
    .m_avl_read (m_avl_read),
    .m_avl_writedata (m_avl_writedata),
    .m_avl_write (m_avl_write),
    .m_avl_burstcount (m_avl_burstcount),
    .m_avl_readdata (m_avl_readdata),
    .m_avl_response (m_avl_response),
    .m_avl_waitrequest (m_avl_waitrequest),
    .m_avl_readdatavalid (m_avl_readdatavalid),
    .m_avl_writeresponsevalid (m_avl_writeresponsevalid)
  );

endmodule
