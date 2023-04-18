import configure::*;

module wb
(
  input  logic reset,
  input  logic clock,
  /////////////////////////////////
  input  logic [0  : 0] wb_valid,
  input  logic [0  : 0] wb_instr,
  input  logic [31 : 0] wb_addr,
  input  logic [31 : 0] wb_wdata,
  input  logic [3  : 0] wb_wstrb,
  output logic [31 : 0] wb_rdata,
  output logic [0  : 0] wb_ready,
  /////////////////////////////////
  output logic [31 : 0] m_wb_addr_o,
  output logic [31 : 0] m_wb_dat_o,
  output logic [3  : 0] m_wb_sel_o,
  output logic [0  : 0] m_wb_we_o,
  output logic [0  : 0] m_wb_cyc_o,
  output logic [0  : 0] m_wb_stb_o,
  output logic [0  : 0] m_wb_lock_o,
  /////////////////////////////////
  input  logic [31 : 0] m_wb_dat_i,
  input  logic [0  : 0] m_wb_ack_i,
  input  logic [0  : 0] m_wb_err_i,
  input  logic [0  : 0] m_wb_rty_i,
  input  logic [0  : 0] m_wb_stall_i
  /////////////////////////////////
);
  timeunit 1ns;
  timeprecision 1ps;

  localparam [1:0] idle = 0;
  localparam [1:0] load = 1;
  localparam [1:0] store = 2;

  logic [1 :0] state;
  logic [1 :0] state_reg;

  logic [31:0] addr;
  logic [31:0] addr_reg;
  logic [31:0] dat;
  logic [31:0] dat_reg;
  logic [3 :0] sel;
  logic [3 :0] sel_reg;
  logic [0 :0] we;
  logic [0 :0] we_reg;
  logic [0 :0] cyc;
  logic [0 :0] cyc_reg;
  logic [0 :0] stb;
  logic [0 :0] stb_reg;

  logic [31:0] rdata;
  logic [31:0] rdata_reg;
  logic [0 :0] ready;
  logic [0 :0] ready_reg;

  always_comb begin
    state = state_reg;
    addr = 0;
    dat = 0;
    sel = 0;
    we = 0;
    cyc = 0;
    stb = 0;
    rdata = 0;
    ready = 0;
    case (state)
      idle : begin
        if (wb_valid == 1) begin
          if (|wb_wstrb == 0) begin
            state = load;
            addr = {wb_addr[31:2],2'b0};
            sel = 4'hF;
            cyc = 1;
            stb = 1;
          end else if (|wb_wstrb == 1) begin
            state = store;
            addr = {wb_addr[31:2],2'b0};
            dat = wb_wdata;
            sel = wb_wstrb;
            we = 1;
            cyc = 1;
            stb = 1;
          end
        end
      end
      load : begin
        if (m_wb_ack_i == 1) begin
          state = idle;
          rdata = m_wb_dat_i;
          ready = 1;
        end else if (m_wb_stall_i == 1) begin
          addr = addr_reg;
          sel = sel_reg;
          cyc = cyc_reg;
          stb = stb_reg;
        end
      end
      store : begin
        if (m_wb_ack_i == 1) begin
          state = idle;
          ready = 1;
        end else if (m_wb_stall_i == 1) begin
          addr = addr_reg;
          dat = dat_reg;
          sel = sel_reg;
          we = we_reg;
          cyc = cyc_reg;
          stb = stb_reg;
        end
      end
      default : begin
      end
    endcase
  end

  assign m_wb_addr_o = addr_reg;
  assign m_wb_dat_o = dat_reg;
  assign m_wb_sel_o = sel_reg;
  assign m_wb_we_o = we_reg;
  assign m_wb_cyc_o = cyc_reg;
  assign m_wb_stb_o = stb_reg;

  assign m_wb_lock_o = 1'b0;

  assign wb_rdata = rdata_reg;
  assign wb_ready = ready_reg;

  always_ff @(posedge clock) begin

    if (reset == 0) begin
      state_reg <= 0;
      addr_reg <= 0;
      dat_reg <= 0;
      sel_reg <= 0;
      we_reg <= 0;
      cyc_reg <= 0;
      stb_reg <= 0;
      rdata_reg <= 0;
      ready_reg <= 0;
    end else begin
      state_reg <= state;
      addr_reg <= addr;
      dat_reg <= dat;
      sel_reg <= sel;
      we_reg <= we;
      cyc_reg <= cyc;
      stb_reg <= stb;
      rdata_reg <= rdata;
      ready_reg <= ready;
    end

  end

endmodule
