import configure::*;

module soc (
    input  logic reset,
    input  logic clock,
    input  logic clock_per,
    input  logic rx,
    output logic tx
);

  timeunit 1ns; timeprecision 1ps;

  logic [0 : 0] rvfi_valid;
  logic [63 : 0] rvfi_order;
  logic [31 : 0] rvfi_insn;
  logic [0 : 0] rvfi_trap;
  logic [0 : 0] rvfi_halt;
  logic [0 : 0] rvfi_intr;
  logic [1 : 0] rvfi_mode;
  logic [1 : 0] rvfi_ixl;
  logic [4 : 0] rvfi_rs1_addr;
  logic [4 : 0] rvfi_rs2_addr;
  logic [31 : 0] rvfi_rs1_rdata;
  logic [31 : 0] rvfi_rs2_rdata;
  logic [4 : 0] rvfi_rd_addr;
  logic [31 : 0] rvfi_rd_wdata;
  logic [31 : 0] rvfi_pc_rdata;
  logic [31 : 0] rvfi_pc_wdata;
  logic [31 : 0] rvfi_mem_addr;
  logic [3 : 0] rvfi_mem_rmask;
  logic [3 : 0] rvfi_mem_wmask;
  logic [31 : 0] rvfi_mem_rdata;
  logic [31 : 0] rvfi_mem_wdata;

  mem_in_type memory_in;
  mem_in_type imemory_in;
  mem_in_type dmemory_in;

  mem_out_type memory_out;
  mem_out_type imemory_out;
  mem_out_type dmemory_out;

  mem_in_type rom_in;
  mem_in_type ram_in;
  mem_in_type tim_in;
  mem_in_type clint_in;
  mem_in_type error_in;
  mem_in_type uart_rx_in;
  mem_in_type uart_tx_in;

  mem_out_type rom_out;
  mem_out_type ram_out;
  mem_out_type tim_out;
  mem_out_type clint_out;
  mem_out_type error_out;
  mem_out_type uart_rx_out;
  mem_out_type uart_tx_out;

  mem_in_type ram_slow_in;

  mem_out_type ram_slow_out;

  logic [0 : 0] meip;
  logic [0 : 0] msip;
  logic [0 : 0] mtip;
  logic [0 : 0] irpt;

  logic [63 : 0] mtime;

  logic [31 : 0] mem_addr;
  logic [31 : 0] base_addr;

  always_comb begin

    rom_in = init_mem_in;
    ram_in = init_mem_in;
    tim_in = init_mem_in;
    clint_in = init_mem_in;
    error_in = init_mem_in;
    uart_rx_in = init_mem_in;
    uart_tx_in = init_mem_in;

    base_addr = 0;

    if (memory_in.mem_valid == 1) begin
      if (memory_in.mem_addr >= rom_base_addr && memory_in.mem_addr < rom_top_addr) begin
        rom_in = memory_in;
        base_addr = rom_base_addr;
      end else if (memory_in.mem_addr >= ram_base_addr && memory_in.mem_addr < ram_top_addr) begin
        ram_in = memory_in;
        base_addr = ram_base_addr;
      end else if (memory_in.mem_addr >= tim_base_addr && memory_in.mem_addr < tim_top_addr) begin
        tim_in = memory_in;
        base_addr = tim_base_addr;
      end else if (memory_in.mem_addr >= clint_base_addr && memory_in.mem_addr < clint_top_addr) begin
        clint_in  = memory_in;
        base_addr = clint_base_addr;
      end else if (memory_in.mem_addr >= uart_rx_base_addr && memory_in.mem_addr < uart_rx_top_addr) begin
        uart_rx_in = memory_in;
        base_addr  = uart_rx_base_addr;
      end else if (memory_in.mem_addr >= uart_tx_base_addr && memory_in.mem_addr < uart_tx_top_addr) begin
        uart_tx_in = memory_in;
        base_addr  = uart_tx_base_addr;
      end else begin
        error_in.mem_valid = 1;
      end
    end

    mem_addr = memory_in.mem_addr - base_addr;

    rom_in.mem_addr = mem_addr;
    ram_in.mem_addr = mem_addr;
    tim_in.mem_addr = mem_addr;
    clint_in.mem_addr = mem_addr;
    uart_rx_in.mem_addr = mem_addr;
    uart_tx_in.mem_addr = mem_addr;

    memory_out = init_mem_out;

    if (rom_out.mem_ready == 1) begin
      memory_out = rom_out;
    end else if (ram_out.mem_ready == 1) begin
      memory_out = ram_out;
    end else if (tim_out.mem_ready == 1) begin
      memory_out = tim_out;
    end else if (clint_out.mem_ready == 1) begin
      memory_out = clint_out;
    end else if (error_out.mem_ready == 1) begin
      memory_out = error_out;
    end else if (uart_rx_out.mem_ready == 1) begin
      memory_out = uart_rx_out;
    end else if (uart_tx_out.mem_ready == 1) begin
      memory_out = uart_tx_out;
    end

  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      error_out <= init_mem_out;
    end else begin
      if (error_in.mem_valid == 1) begin
        error_out.mem_rdata <= 0;
        error_out.mem_error <= 1;
        error_out.mem_ready <= 1;
      end else begin
        error_out <= init_mem_out;
      end
    end
  end

  cpu cpu_comp (
      .reset(reset),
      .clock(clock),
      .rvfi_valid(rvfi_valid),
      .rvfi_order(rvfi_order),
      .rvfi_insn(rvfi_insn),
      .rvfi_trap(rvfi_trap),
      .rvfi_halt(rvfi_halt),
      .rvfi_intr(rvfi_intr),
      .rvfi_mode(rvfi_mode),
      .rvfi_ixl(rvfi_ixl),
      .rvfi_rs1_addr(rvfi_rs1_addr),
      .rvfi_rs2_addr(rvfi_rs2_addr),
      .rvfi_rs1_rdata(rvfi_rs1_rdata),
      .rvfi_rs2_rdata(rvfi_rs2_rdata),
      .rvfi_rd_addr(rvfi_rd_addr),
      .rvfi_rd_wdata(rvfi_rd_wdata),
      .rvfi_pc_rdata(rvfi_pc_rdata),
      .rvfi_pc_wdata(rvfi_pc_wdata),
      .rvfi_mem_addr(rvfi_mem_addr),
      .rvfi_mem_rmask(rvfi_mem_rmask),
      .rvfi_mem_wmask(rvfi_mem_wmask),
      .rvfi_mem_rdata(rvfi_mem_rdata),
      .rvfi_mem_wdata(rvfi_mem_wdata),
      .imemory_in(imemory_in),
      .imemory_out(imemory_out),
      .dmemory_in(dmemory_in),
      .dmemory_out(dmemory_out),
      .meip(meip),
      .msip(msip),
      .mtip(mtip),
      .irpt(irpt),
      .mtime(mtime)
  );

  arbiter arbiter_comp (
      .reset(reset),
      .clock(clock),
      .imem_in(imemory_in),
      .imem_out(imemory_out),
      .dmem_in(dmemory_in),
      .dmem_out(dmemory_out),
      .mem_in(memory_in),
      .mem_out(memory_out)
  );

  tim tim_comp (
      .reset  (reset),
      .clock  (clock),
      .tim_in (tim_in),
      .tim_out(tim_out)
  );

  rom rom_comp (
      .reset  (reset),
      .clock  (clock),
      .rom_in (rom_in),
      .rom_out(rom_out)
  );

  clint #(
      .clock_rate(clk_divider_rtc)
  ) clint_comp (
      .reset(reset),
      .clock(clock),
      .clint_in(clint_in),
      .clint_out(clint_out),
      .clint_msip(msip),
      .clint_mtip(mtip),
      .clint_mtime(mtime)
  );

  ccd #(
      .clock_rate(clk_divider_per)
  ) ccd_ram_comp (
      .reset(reset),
      .clock(clock),
      .clock_per(clock_per),
      .mem_in(ram_in),
      .mem_out(ram_out),
      .mem_slow_in(ram_slow_in),
      .mem_slow_out(ram_slow_out)
  );

  ram ram_comp (
      .reset  (reset),
      .clock  (clock_per),
      .ram_in (ram_slow_in),
      .ram_out(ram_slow_out)
  );

  uart_rx #(
      .clock_rate(clk_divider_bit)
  ) uart_rx_comp (
      .reset(reset),
      .clock(clock),
      .uart_in(uart_rx_in),
      .uart_out(uart_rx_out),
      .irpt(irpt),
      .rx(rx)
  );

  uart_tx #(
      .clock_rate(clk_divider_bit)
  ) uart_tx_comp (
      .reset(reset),
      .clock(clock),
      .uart_in(uart_tx_in),
      .uart_out(uart_tx_out),
      .tx(tx)
  );

endmodule
