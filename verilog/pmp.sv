import configure::*;
import constants::*;
import wires::*;

module pmp
#(
  parameter pmp_enable = 1
)
(
  input logic rst,
  input logic clk,
  input pmp_in_type pmp_in,
  output pmp_out_type pmp_out
);
  timeunit 1ns;
  timeprecision 1ps;

  localparam [1:0] OFF = 0;
  localparam [1:0] TOR = 1;
  localparam [1:0] NA4 = 2;
  localparam [1:0] NAPOT = 3;

  typedef struct packed{
    logic [7 : 7] L;
    logic [4 : 3] A;
    logic [2 : 2] X;
    logic [1 : 1] W;
    logic [0 : 0] R;
  } csr_pmpcfg_type;

  parameter csr_pmpcfg_type init_csr_pmpcfg = '{
    L : 0,
    A : 0,
    X : 0,
    W : 0,
    R : 0
  };

  csr_pmpcfg_type csr_pmpcfg [0:3];

  logic [31 : 0] csr_pmpaddr [0:3];

  logic [0  : 0] exception;
  logic [31 : 0] etval;
  logic [3  : 0] ecause;

  logic [0  : 0] execute;
  logic [0  : 0] write;
  logic [0  : 0] read;

  logic [0  : 0] pass;
  logic [0  : 0] ok;

  logic [29 : 0] shifted;
  logic [31 : 0] lowaddr;
  logic [31 : 0] highaddr;

  integer i;
  integer j;

  always_ff @(posedge clk) begin
    if (rst == 0) begin
      csr_pmpcfg <= '{default:init_csr_pmpcfg};
      csr_pmpaddr <= '{default:'0};
    end else begin
      if (pmp_in.cwren == 1) begin
        if (pmp_in.pmp_in.cwaddr == csr_pmpcfg0) begin
          if (csr_pmpcfg[3].L == 0) begin
            csr_pmpcfg[3].L <= pmp_in.cwdata[31];
            csr_pmpcfg[3].A <= pmp_in.cwdata[28:27];
            csr_pmpcfg[3].X <= pmp_in.cwdata[26];
            csr_pmpcfg[3].W <= pmp_in.cwdata[25];
            csr_pmpcfg[3].R <= pmp_in.cwdata[24];
          end
          if  (csr_pmpcfg[2].L == 0) begin
            csr_pmpcfg[2].L <= pmp_in.cwdata[23];
            csr_pmpcfg[2].A <= pmp_in.cwdata[20:19];
            csr_pmpcfg[2].X <= pmp_in.cwdata[18];
            csr_pmpcfg[2].W <= pmp_in.cwdata[17];
            csr_pmpcfg[2].R <= pmp_in.cwdata[16];
          end
          if  (csr_pmpcfg[1].L == 0) begin
            csr_pmpcfg[1].L <= pmp_in.cwdata[15];
            csr_pmpcfg[1].A <= pmp_in.cwdata[12:11];
            csr_pmpcfg[1].X <= pmp_in.cwdata[10];
            csr_pmpcfg[1].W <= pmp_in.cwdata[9];
            csr_pmpcfg[1].R <= pmp_in.cwdata[8];
          end
          if  (csr_pmpcfg[0].L == 0) begin
            csr_pmpcfg[0].L <= pmp_in.cwdata[7];
            csr_pmpcfg[0].A <= pmp_in.cwdata[4:3];
            csr_pmpcfg[0].X <= pmp_in.cwdata[2];
            csr_pmpcfg[0].W <= pmp_in.cwdata[1];
            csr_pmpcfg[0].R <= pmp_in.cwdata[0];
          end
        end else if (pmp_in.cwaddr == csr_pmpaddr0) begin
          if  (csr_pmpcfg[0].L == 0 && !(csr_pmpcfg[1].L == 1 && csr_pmpcfg[1].A == 1)) begin
            csr_pmpaddr0 <= pmp_in.cwdata;
          end
        end else if (pmp_in.cwaddr == csr_pmpaddr1) begin
          if  (csr_pmpcfg[1].L == 0 && !(csr_pmpcfg[2].L == 1 && csr_pmpcfg[2].A == 1)) begin
            csr_pmpaddr1 <= pmp_in.cwdata;
          end
        end else if (pmp_in.cwaddr == csr_pmpaddr2) begin
          if  (csr_pmpcfg[2].L == 0 && !(csr_pmpcfg[3].L == 1 && csr_pmpcfg[3].A == 1)) begin
            csr_pmpaddr2 <= pmp_in.cwdata;
          end
        end else if (pmp_in.cwaddr == csr_pmpaddr3) begin
          if  (csr_pmpcfg[3].L == 0) begin
            csr_pmpaddr3 <= pmp_in.cwdata;
          end
        end
      end
    end
  end

  always_comb begin
    pmp_out.crdata = 0;
    if (pmp_in.crden == 1) begin
      if (pmp_in.craddr == csr_pmpcfg0) begin
        pmp_out.crdata[31:24] = {csr_pmpcfg[3].L,2'b0,csr_pmpcfg[3].A,csr_pmpcfg[3].X,csr_pmpcfg[3].W.csr_pmpcfg[3].R};
        pmp_out.crdata[23:16] = {csr_pmpcfg[2].L,2'b0,csr_pmpcfg[2].A,csr_pmpcfg[2].X,csr_pmpcfg[2].W.csr_pmpcfg[2].R};
        pmp_out.crdata[15:8] = {csr_pmpcfg[1].L,2'b0,csr_pmpcfg[1].A,csr_pmpcfg[1].X,csr_pmpcfg[1].W.csr_pmpcfg[1].R};
        pmp_out.crdata[7:0] = {csr_pmpcfg[0].L,2'b0,csr_pmpcfg[0].A,csr_pmpcfg[0].X,csr_pmpcfg[0].W.csr_pmpcfg[0].R};
      end else if (pmp_in.craddr == csr_pmpaddr0) begin
        pmp_out.crdata <= csr_pmpaddr[0];
      end else if (pmp_in.craddr == csr_pmpaddr1) begin
        pmp_out.crdata <= csr_pmpaddr[1];
      end else if (pmp_in.craddr == csr_pmpaddr2) begin
        pmp_out.crdata <= csr_pmpaddr[2];
      end else if (pmp_in.craddr == csr_pmpaddr3) begin
        pmp_out.crdata <= csr_pmpaddr[3];
      end
    end
  end

  always_comb begin
    exception = 0;
    etval = 0;
    ecause = 0;
    execute = 0;
    write = 0;
    read = 0;
    pass = 0;
    ok = 0;
    shifted = 0;
    lowaddr = 0;
    highaddr = 0;
    if (pmp_in.mem_valid == 1) begin
      for (i=0; i<3; i=i+1) begin
        ok = 0;
        if (pmp_in.mem_instr == 1) begin
          execute = 1;
          if (csr_pmpcfg[i].L == 1 && csr_pmpcfg[i].X == 1) begin
            ok = 1;
          end else if (csr_pmpcfg[i].L == 0 && (csr_pmpcfg[i].X == 1 || pmp_in.priv_mode == m_mode)) begin
            ok = 1;
          end
        end else if (pmp_in.mem_instr == 0) begin
          if (|pmp_in.mem_wstrb == 1) begin
            write = 1;
            if (csr_pmpcfg[i].L == 1 && csr_pmpcfg[i].W == 1) begin
              ok = 1;
            end else if (csr_pmpcfg[i].L == 0 && (csr_pmpcfg[i].W == 1 || pmp_in.priv_mode == m_mode)) begin
              ok = 1;
            end
          end else if (|pmp_in.mem_wstrb == 0) begin
            read = 1;
            if (csr_pmpcfg[i].L == 1 && csr_pmpcfg[i].R == 1) begin
              ok = 1;
            end else if (csr_pmpcfg[i].L == 0 && (csr_pmpcfg[i].R == 1 || pmp_in.priv_mode == m_mode)) begin
              ok = 1;
            end
          end
        end
        if (ok == 1) begin
          if (csr_pmpcfg[i].A == OFF) begin
            continue;
          end if (csr_pmpcfg[i].A == TOR) begin
            if (i==0) begin
              lowaddr = 0;
              highaddr = csr_pmpaddr[0];
            end else begin
              lowaddr = csr_pmpaddr[i-1];
              highaddr = csr_pmpaddr[i];
            end
            highaddr = highaddr - 1;
          end else if (csr_pmpcfg[i].A == NA4) begin
            lowaddr = {csr_pmpaddr[i][29:0],2'h0};
            highaddr = {csr_pmpaddr[i][29:0],2'h3};
          end else if (csr_pmpcfg[i].A == NAPOT) begin
            shifted = csr_pmpaddr[i][29:0] + 1;
            lowaddr = {(csr_pmpaddr[i][29:0] & shifted),2'h0};
            highaddr = {(csr_pmpaddr[i][29:0] | shifted),2'h3};
          end
          if (lowaddr <= highaddr && pmp_in.mem_addr >= lowaddr && pmp_in.mem_addr <= highaddr) begin
            pass = 1;
            break;
          end
        end
      end
      if (pass == 0) begin
        exception = 1;
        etval = pmp_in.mem_addr;
        ecause = (execute == 1) ? except_instr_access_fault :
                 (write == 1) ? except_store_access_fault :
                 (read == 1) ? except_load_access_fault : 0;
      end
    end
    pmp_out.exception = exception;
    pmp_out.etval = etval;
    pmp_out.ecause = ecause;
  end

endmodule
