import configure::*;

module ahb
(
  input  logic reset,
  input  logic clock,
  /////////////////////////////////
  input  logic [0  : 0] ahb_valid,
  input  logic [0  : 0] ahb_instr,
  input  logic [31 : 0] ahb_addr,
  input  logic [31 : 0] ahb_wdata,
  input  logic [3  : 0] ahb_wstrb,
  output logic [31 : 0] ahb_rdata,
  output logic [0  : 0] ahb_ready,
  /////////////////////////////////
  output logic [31 : 0] m_ahb_haddr,
  output logic [31 : 0] m_ahb_hwdata,
  output logic [3  : 0] m_ahb_hwstrb,
  output logic [0  : 0] m_ahb_hwrite,
  output logic [2  : 0] m_ahb_hsize,
  output logic [2  : 0] m_ahb_hburst,
  output logic [3  : 0] m_ahb_hprot,
  output logic [1  : 0] m_ahb_htrans,
  output logic [0  : 0] m_ahb_hmastlock,
  /////////////////////////////////
  input  logic [31 : 0] m_ahb_hrdata,
  input  logic [0  : 0] m_ahb_hready,
  input  logic [0  : 0] m_ahb_hresp
  /////////////////////////////////
);
  timeunit 1ns;
  timeprecision 1ps;

  localparam [1:0] idle = 0;
  localparam [1:0] load = 1;
  localparam [1:0] store = 2;

  logic [1 :0] state;
  logic [1 :0] state_reg;

  logic [31:0] haddr;
  logic [31:0] haddr_reg;
  logic [31:0] hwdata;
  logic [31:0] hwdata_reg;
  logic [31:0] hwstrb;
  logic [31:0] hwstrb_reg;
  logic [0 :0] hwrite;
  logic [0 :0] hwrite_reg;

  logic [31:0] rdata;
  logic [31:0] rdata_reg;
  logic [0 :0] ready;
  logic [0 :0] ready_reg;

  always_comb begin
    state = state_reg;
    haddr = 0;
    hwdata = 0;
    hwstrb = 0;
    hwrite = 0;
    rdata = 0;
    ready = 0;
    case (state)
      idle : begin
        if (ahb_valid == 1) begin
          if (|ahb_wstrb == 0) begin
            state = load;
            haddr = {ahb_addr[31:2],2'b0};
          end else if (|ahb_wstrb == 1) begin
            state = store;
            haddr = {ahb_addr[31:2],2'b0};
            hwdata = ahb_wdata;
            hwstrb = ahb_wstrb;
            hwrite = 1;
          end
        end
      end
      load : begin
        if (m_ahb_hready == 1) begin
          state = idle;
          rdata = m_ahb_hrdata;
          ready = 1;
        end else if (m_ahb_hready == 0) begin
          haddr = haddr_reg;
        end
      end
      store : begin
        if (m_ahb_hready == 1) begin
          state = idle;
          ready = 1;
        end else if (m_ahb_hready == 0) begin
          haddr = haddr_reg;
          hwdata = hwdata_reg;
          hwstrb = hwstrb_reg;
          hwrite = hwrite_reg;
        end
      end
      default : begin
      end
    endcase
  end

  assign m_ahb_haddr = haddr_reg;
  assign m_ahb_hwdata = hwdata_reg;
  assign m_ahb_hwstrb = hwstrb_reg;
  assign m_ahb_hwrite = hwrite_reg;

  assign m_ahb_hsize = 0;
  assign m_ahb_hburst = 0;
  assign m_ahb_hprot = 0;
  assign m_ahb_htrans = 0;
  assign m_ahb_hmastlock = 0;

  assign ahb_rdata = rdata_reg;
  assign ahb_ready = ready_reg;

  always_ff @(posedge clock) begin

    if (reset == 0) begin
      state_reg <= 0;
      haddr_reg <= 0;
      hwdata_reg <= 0;
      hwstrb_reg <= 0;
      hwrite_reg <= 0;
      rdata_reg <= 0;
      ready_reg <= 0;
    end else begin
      state_reg <= state;
      haddr_reg <= haddr;
      hwdata_reg <= hwdata;
      hwstrb_reg <= hwstrb;
      hwrite_reg <= hwrite;
      rdata_reg <= rdata;
      ready_reg <= ready;
    end

  end

endmodule
