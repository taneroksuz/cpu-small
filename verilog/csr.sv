import constants::*;
import wires::*;

module csr
(
  input logic rst,
  input logic clk,
  input csr_in_type csr_in,
  output csr_out_type csr_out,
  input logic [0:0] meip,
  input logic [0:0] msip,
  input logic [0:0] mtip,
  input logic [63:0] mtime
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [31:0] csr_reg_file [0:4095] = '{default:'0,769:32'h40001104};

  logic [0 :0] exception;
  logic [0 :0] mret;
  logic [31:0] mtvec;

  logic [63:0] mcycle;
  logic [63:0] minstret;

  logic [31:0] crdata;

  logic [0 :0] cwren;
  logic [11:0] cwaddr;
  logic [31:0] cwdata;

  assign mcycle = {csr_reg_file[csr_mcycleh],csr_reg_file[csr_mcycle]} + 1;
  assign minstret = {csr_reg_file[csr_minstreth],csr_reg_file[csr_minstret]} + {63'h0,csr_in.valid};

  assign csr_out.exception = exception;
  assign csr_out.mtvec = mtvec;

  assign csr_out.mret = mret;
  assign csr_out.mepc = csr_reg_file[csr_mepc];

  always_ff @(posedge clk) begin

    csr_reg_file[csr_mcycle] <= mcycle[31:0];
    csr_reg_file[csr_mcycleh] <= mcycle[63:32];
    csr_reg_file[csr_minstret] <= minstret[31:0];
    csr_reg_file[csr_minstreth] <= minstret[63:32];

    if (cwren == 1) begin
      csr_reg_file[cwaddr] <= cwdata;
    end

    if (meip == 1) begin
      csr_reg_file[csr_mip][11:11] <= 1;
    end else begin
      csr_reg_file[csr_mip][11:11] <= 0;
    end

    if (mtip == 1) begin
      csr_reg_file[csr_mip][7:7] <= 1;
    end else begin
      csr_reg_file[csr_mip][7:7] <= 0;
    end

    if (msip == 1) begin
      csr_reg_file[csr_mip][3:3] <= 1;
    end else begin
      csr_reg_file[csr_mip][3:3] <= 0;
    end

    if (csr_in.exception == 1) begin
      csr_reg_file[csr_mstatus][7:7] <= csr_reg_file[csr_mstatus][3:3];
      csr_reg_file[csr_mstatus][3:3] <= 0;
      csr_reg_file[csr_mepc] <= csr_in.epc;
      csr_reg_file[csr_mtval] <= csr_in.etval;
      csr_reg_file[csr_mcause] <= {28'b0,csr_in.ecause};
      exception <= 1;
    end else if (csr_reg_file[csr_mstatus][3:3] == 1 &&
                 csr_reg_file[csr_mie][11:11] == 1 &&
                 csr_reg_file[csr_mip][11:11] == 1 &&
                 csr_in.valid == 1) begin
      csr_reg_file[csr_mstatus][7:7] <= csr_reg_file[csr_mstatus][3:3];
      csr_reg_file[csr_mstatus][3:3] <= 0;
      csr_reg_file[csr_mepc] <= csr_in.epc;
      csr_reg_file[csr_mtval] <= csr_in.etval;
      csr_reg_file[csr_mcause] <= {1'b1,27'b0,interrupt_mach_extern};
      exception <= 1;
    end else if (csr_reg_file[csr_mstatus][3:3] == 1 &&
                 csr_reg_file[csr_mie][7:7] == 1 &&
                 csr_reg_file[csr_mip][7:7] == 1 &&
                 csr_in.valid == 1) begin
      csr_reg_file[csr_mstatus][7:7] <= csr_reg_file[csr_mstatus][3:3];
      csr_reg_file[csr_mstatus][3:3] <= 0;
      csr_reg_file[csr_mepc] <= csr_in.epc;
      csr_reg_file[csr_mtval] <= csr_in.etval;
      csr_reg_file[csr_mcause] <= {1'b1,27'b0,interrupt_mach_timer};
      exception <= 1;
    end else if (csr_reg_file[csr_mstatus][3:3] == 1 &&
                 csr_reg_file[csr_mie][3:3] == 1 &&
                 csr_reg_file[csr_mip][3:3] == 1 &&
                 csr_in.valid == 1) begin
      csr_reg_file[csr_mstatus][7:7] <= csr_reg_file[csr_mstatus][3:3];
      csr_reg_file[csr_mstatus][3:3] <= 0;
      csr_reg_file[csr_mepc] <= csr_in.epc;
      csr_reg_file[csr_mtval] <= csr_in.etval;
      csr_reg_file[csr_mcause] <= {1'b1,27'b0,interrupt_mach_soft};
      exception <= 1;
    end else begin
      exception <= 0;
    end

    if (csr_in.mret == 1) begin
      csr_reg_file[csr_mstatus][3:3] <= csr_reg_file[csr_mstatus][7:7];
      csr_reg_file[csr_mstatus][7:7] <= 0;
      mret <= 1;
    end else begin
      mret <= 0;
    end

  end

  assign crdata = csr_reg_file[csr_in.craddr];

  always_comb begin
    if (csr_in.crden == 1) begin
      case (csr_in.craddr)
        csr_mstatus : csr_out.cdata = {crdata[31:31],
                                       8'h0,
                                       crdata[22:22],
                                       crdata[21:21],
                                       crdata[20:20],
                                       crdata[19:19],
                                       crdata[18:18],
                                       crdata[17:17],
                                       crdata[16:15],
                                       crdata[14:13],
                                       crdata[12:11],
                                       2'h0,
                                       crdata[8:8],
                                       crdata[7:7],
                                       1'h0,
                                       crdata[5:5],
                                       crdata[4:4],
                                       crdata[3:3],
                                       1'h0,
                                       crdata[1:1],
                                       crdata[0:0]};
        csr_misa : csr_out.cdata = {crdata[31:30],
                                    4'h0,
                                    crdata[25:25],
                                    crdata[24:24],
                                    crdata[23:23],
                                    crdata[22:22],
                                    crdata[21:21],
                                    crdata[20:20],
                                    crdata[19:19],
                                    crdata[18:18],
                                    crdata[17:17],
                                    crdata[16:16],
                                    crdata[15:15],
                                    crdata[14:14],
                                    crdata[13:13],
                                    crdata[12:12],
                                    crdata[11:11],
                                    crdata[10:10],
                                    crdata[9:9],
                                    crdata[8:8],
                                    crdata[7:7],
                                    crdata[6:6],
                                    crdata[5:5],
                                    crdata[4:4],
                                    crdata[3:3],
                                    crdata[2:2],
                                    crdata[1:1],
                                    crdata[0:0]};
        csr_mie : csr_out.cdata = {20'h0,
                                   crdata[11:11],
                                   1'h0,
                                   crdata[9:9],
                                   crdata[8:8],
                                   crdata[7:7],
                                   1'h0,
                                   crdata[5:5],
                                   crdata[4:4],
                                   crdata[3:3],
                                   1'h0,
                                   crdata[1:1],
                                   crdata[0:0]};
        csr_mip : csr_out.cdata = {20'h0,
                                   crdata[11:11],
                                   1'h0,
                                   crdata[9:9],
                                   crdata[8:8],
                                   crdata[7:7],
                                   1'h0,
                                   crdata[5:5],
                                   crdata[4:4],
                                   crdata[3:3],
                                   1'h0,
                                   crdata[1:1],
                                   crdata[0:0]};
        default : csr_out.cdata = crdata;
      endcase
    end else begin
      csr_out.cdata = 0;
    end
  end 

  always_comb begin
    cwren = 0;
    cwaddr = 0;
    cwdata = 0;
    if (csr_in.cwren == 1) begin
      case (csr_in.cwaddr)
        csr_mstatus : begin
          cwren = 1;
          cwaddr = csr_in.cwaddr;
          cwdata[31:31] = csr_in.cdata[31:31];
          cwdata[22:22] = csr_in.cdata[22:22];
          cwdata[21:21] = csr_in.cdata[21:21];
          cwdata[20:20] = csr_in.cdata[20:20];
          cwdata[19:19] = csr_in.cdata[19:19];
          cwdata[18:18] = csr_in.cdata[18:18];
          cwdata[17:17] = csr_in.cdata[17:17];
          cwdata[16:15] = csr_in.cdata[16:15];
          cwdata[14:13] = csr_in.cdata[14:13];
          cwdata[12:11] = csr_in.cdata[12:11];
          cwdata[8:8] = csr_in.cdata[8:8];
          cwdata[7:7] = csr_in.cdata[7:7];
          cwdata[5:5] = csr_in.cdata[5:5];
          cwdata[4:4] = csr_in.cdata[4:4];
          cwdata[3:3] = csr_in.cdata[3:3];
          cwdata[1:1] = csr_in.cdata[1:1];
          cwdata[0:0] = csr_in.cdata[0:0];
        end
        csr_mie : begin
          cwren = 1;
          cwaddr = csr_in.cwaddr;
          cwdata[11:11] = csr_in.cdata[11:11];
          cwdata[9:9] = csr_in.cdata[9:9];
          cwdata[8:8] = csr_in.cdata[8:8];
          cwdata[7:7] = csr_in.cdata[7:7];
          cwdata[5:5] = csr_in.cdata[5:5];
          cwdata[4:4] = csr_in.cdata[4:4];
          cwdata[3:3] = csr_in.cdata[3:3];
          cwdata[1:1] = csr_in.cdata[1:1];
          cwdata[0:0] = csr_in.cdata[0:0];
        end
        csr_mip : begin
          cwren = 1;
          cwaddr = csr_in.cwaddr;
          cwdata[9:9] = csr_in.cdata[9:9];
          cwdata[8:8] = csr_in.cdata[8:8];
          cwdata[5:5] = csr_in.cdata[5:5];
          cwdata[4:4] = csr_in.cdata[4:4];
          cwdata[1:1] = csr_in.cdata[1:1];
          cwdata[0:0] = csr_in.cdata[0:0];
        end
        csr_mtvec : begin
          cwren = 1;
          cwaddr = csr_in.cwaddr;
          cwdata = csr_in.cdata;
        end
        csr_mscratch : begin
          cwren = 1;
          cwaddr = csr_in.cwaddr;
          cwdata = csr_in.cdata;
        end
        csr_mepc : begin
          cwren = 1;
          cwaddr = csr_in.cwaddr;
          cwdata = csr_in.cdata;
        end
        csr_mcause : begin
          cwren = 1;
          cwaddr = csr_in.cwaddr;
          cwdata = csr_in.cdata;
        end
        csr_mtval : begin
          cwren = 1;
          cwaddr = csr_in.cwaddr;
          cwdata = csr_in.cdata;
        end
        csr_mcycle : begin
          cwren = 1;
          cwaddr = csr_in.cwaddr;
          cwdata = csr_in.cdata;
        end
        csr_mcycleh : begin
          cwren = 1;
          cwaddr = csr_in.cwaddr;
          cwdata = csr_in.cdata;
        end
        csr_minstret : begin
          cwren = 1;
          cwaddr = csr_in.cwaddr;
          cwdata = csr_in.cdata;
        end
        csr_minstreth : begin
          cwren = 1;
          cwaddr = csr_in.cwaddr;
          cwdata = csr_in.cdata;
        end
        default :;
      endcase
    end
  end

  always_comb begin
    if (csr_reg_file[csr_mtvec][1:0] == 1) begin
      mtvec = {(csr_reg_file[csr_mtvec][31:2] + {26'b0,csr_reg_file[csr_mtvec][3:0]}),2'b0};
    end else begin
      mtvec = {csr_reg_file[csr_mtvec][31:2],2'b0};
    end
  end

endmodule
