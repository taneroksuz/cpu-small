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

  csr_machine_reg_type csr_machine_reg;

  logic [1:0] mode = m_mode;

  logic [0:0] exception = 0;
  logic [0:0] interrupt = 0;
  logic [0:0] mret = 0;

  always_comb begin
    if (csr_in.crden == 1) begin
      case (csr_in.craddr)
        csr_misa : csr_out.crdata = 32'h40001104;
        csr_mvendorid : csr_out.crdata = 32'h00000000;
        csr_marchid : csr_out.crdata = 32'h00000000;
        csr_mimpid : csr_out.crdata = 32'h00000000;
        csr_mhartid : csr_out.crdata = 32'h00000000;
        csr_mstatus : csr_out.crdata = {csr_machine_reg.mstatus.sd,
                                       8'h0,
                                       csr_machine_reg.mstatus.tsr,
                                       csr_machine_reg.mstatus.tw,
                                       csr_machine_reg.mstatus.tvm,
                                       csr_machine_reg.mstatus.mxr,
                                       csr_machine_reg.mstatus.sum,
                                       csr_machine_reg.mstatus.mprv,
                                       csr_machine_reg.mstatus.xs,
                                       csr_machine_reg.mstatus.fs,
                                       csr_machine_reg.mstatus.mpp,
                                       2'h0,
                                       csr_machine_reg.mstatus.spp,
                                       csr_machine_reg.mstatus.mpie,
                                       1'h0,
                                       csr_machine_reg.mstatus.spie,
                                       csr_machine_reg.mstatus.upie,
                                       csr_machine_reg.mstatus.mie,
                                       1'h0,
                                       csr_machine_reg.mstatus.sie,
                                       csr_machine_reg.mstatus.uie};
        csr_mie : csr_out.crdata = {20'h0,
                                   csr_machine_reg.mie.meie,
                                   1'h0,
                                   csr_machine_reg.mie.seie,
                                   csr_machine_reg.mie.ueie,
                                   csr_machine_reg.mie.mtie,
                                   1'h0,
                                   csr_machine_reg.mie.stie,
                                   csr_machine_reg.mie.utie,
                                   csr_machine_reg.mie.msie,
                                   1'h0,
                                   csr_machine_reg.mie.ssie,
                                   csr_machine_reg.mie.usie};
        csr_mtvec : csr_out.crdata = csr_machine_reg.mtvec;
        csr_mscratch : csr_out.crdata = csr_machine_reg.mscratch;
        csr_mepc : csr_out.crdata = csr_machine_reg.mepc;
        csr_mcause : csr_out.crdata = csr_machine_reg.mcause;
        csr_mtval : csr_out.crdata = csr_machine_reg.mtval;
        csr_mip : csr_out.crdata = {20'h0,
                                   csr_machine_reg.mip.meip,
                                   1'h0,
                                   csr_machine_reg.mip.seip,
                                   csr_machine_reg.mip.ueip,
                                   csr_machine_reg.mip.mtip,
                                   1'h0,
                                   csr_machine_reg.mip.stip,
                                   csr_machine_reg.mip.utip,
                                   csr_machine_reg.mip.msip,
                                   1'h0,
                                   csr_machine_reg.mip.ssip,
                                   csr_machine_reg.mip.usip};
        csr_mcycle : csr_out.crdata = csr_machine_reg.mcycle[31:0];
        csr_mcycleh : csr_out.crdata = csr_machine_reg.mcycle[63:32];
        csr_minstret : csr_out.crdata = csr_machine_reg.minstret[31:0];
        csr_minstreth : csr_out.crdata = csr_machine_reg.minstret[63:32];
        csr_mcounteren : csr_out.crdata = csr_machine_reg.mcounteren;
        csr_mcountinhibit: csr_out.crdata = csr_machine_reg.mcountinhibit;
        default : csr_out.crdata = 0;
      endcase
    end else begin
      csr_out.crdata = 0;
    end

    csr_out.trap = exception | interrupt;
    csr_out.mret = mret;
    csr_out.mode = mode;
    csr_out.minstret = csr_machine_reg.minstret;
    csr_out.mepc = csr_machine_reg.mepc;
    csr_out.mcounteren = csr_machine_reg.mcounteren;
    if (csr_machine_reg.mtvec[1:0] == 1 && interrupt == 1) begin
      csr_out.mtvec = {(csr_machine_reg.mtvec[31:2] + {26'b0,csr_machine_reg.mcause[3:0]}),2'b0};
    end else begin
      csr_out.mtvec = {csr_machine_reg.mtvec[31:2],2'b0};
    end

  end

  always_ff @(posedge clk) begin

    if (rst == 0) begin
      csr_machine_reg <= init_csr_machine_reg;
      mode <= m_mode;
      exception <= 0;
      interrupt <= 0;
      mret <= 0;
    end else begin
      if (csr_in.cwren == 1) begin
        case (csr_in.cwaddr)
          csr_mstatus : begin
            csr_machine_reg.mstatus.sd <= csr_in.cwdata[31];
            csr_machine_reg.mstatus.tsr <= csr_in.cwdata[22];
            csr_machine_reg.mstatus.tw <= csr_in.cwdata[21];
            csr_machine_reg.mstatus.tvm <= csr_in.cwdata[20];
            csr_machine_reg.mstatus.mxr <= csr_in.cwdata[19];
            csr_machine_reg.mstatus.sum <= csr_in.cwdata[18];
            csr_machine_reg.mstatus.mprv <= csr_in.cwdata[17];
            csr_machine_reg.mstatus.xs <= csr_in.cwdata[16:15];
            csr_machine_reg.mstatus.fs <= csr_in.cwdata[14:13];
            if (csr_in.cwdata[12:11] == m_mode || csr_in.cwdata[12:11] == u_mode) begin
              csr_machine_reg.mstatus.mpp <= csr_in.cwdata[12:11];
            end
            csr_machine_reg.mstatus.spp <= csr_in.cwdata[8];
            csr_machine_reg.mstatus.mpie <= csr_in.cwdata[7];
            csr_machine_reg.mstatus.spie <= csr_in.cwdata[5];
            csr_machine_reg.mstatus.upie <= csr_in.cwdata[4];
            csr_machine_reg.mstatus.mie <= csr_in.cwdata[3];
            csr_machine_reg.mstatus.sie <= csr_in.cwdata[1];
            csr_machine_reg.mstatus.uie <= csr_in.cwdata[0];
          end
          csr_mtvec : csr_machine_reg.mtvec <= csr_in.cwdata;
          csr_mscratch : csr_machine_reg.mscratch <= csr_in.cwdata;
          csr_mepc : csr_machine_reg.mepc <= csr_in.cwdata;
          csr_mcause : csr_machine_reg.mcause <= csr_in.cwdata;
          csr_mtval : csr_machine_reg.mtval <= csr_in.cwdata;
          csr_mie : begin
            csr_machine_reg.mie.meie <= csr_in.cwdata[11];
            csr_machine_reg.mie.seie <= csr_in.cwdata[9];
            csr_machine_reg.mie.ueie <= csr_in.cwdata[8];
            csr_machine_reg.mie.mtie <= csr_in.cwdata[7];
            csr_machine_reg.mie.stie <= csr_in.cwdata[5];
            csr_machine_reg.mie.ueie <= csr_in.cwdata[4];
            csr_machine_reg.mie.msie <= csr_in.cwdata[3];
            csr_machine_reg.mie.ssie <= csr_in.cwdata[1];
            csr_machine_reg.mie.usie <= csr_in.cwdata[0];
          end
          csr_mip : begin
            csr_machine_reg.mip.seip <= csr_in.cwdata[9];
            csr_machine_reg.mip.ueip <= csr_in.cwdata[8];
            csr_machine_reg.mip.stip <= csr_in.cwdata[5];
            csr_machine_reg.mip.ueip <= csr_in.cwdata[4];
            csr_machine_reg.mip.ssip <= csr_in.cwdata[1];
            csr_machine_reg.mip.usip <= csr_in.cwdata[0];
          end
          csr_mcycle : csr_machine_reg.mcycle[31:0] <= csr_in.cwdata;
          csr_mcycleh : csr_machine_reg.mcycle[63:32] <= csr_in.cwdata;
          csr_minstret : csr_machine_reg.minstret[31:0] <= csr_in.cwdata;
          csr_minstreth : csr_machine_reg.minstret[63:32] <= csr_in.cwdata;
          csr_mcounteren : csr_machine_reg.mcounteren <= csr_in.cwdata;
          csr_mcountinhibit: csr_machine_reg.mcountinhibit <= csr_in.cwdata;
          default :;
        endcase
      end

      if (csr_machine_reg.mcountinhibit[0] == 0) begin
        csr_machine_reg.mcycle <= csr_machine_reg.mcycle + 1;
      end

      if (csr_in.valid == 1 && csr_machine_reg.mcountinhibit[2] == 0) begin
        csr_machine_reg.minstret <= csr_machine_reg.minstret + 1;
      end

      if (meip == 1) begin
        csr_machine_reg.mip.meip <= 1;
      end else begin
        csr_machine_reg.mip.meip <= 0;
      end

      if (mtip == 1) begin
        csr_machine_reg.mip.mtip <= 1;
      end else begin
        csr_machine_reg.mip.mtip <= 0;
      end

      if (msip == 1) begin
        csr_machine_reg.mip.msip <= 1;
      end else begin
        csr_machine_reg.mip.msip <= 0;
      end

      exception <= 0;
      interrupt <= 0;

      if (csr_in.exception == 1) begin
        csr_machine_reg.mstatus.mpie <= csr_machine_reg.mstatus.mie;
        csr_machine_reg.mstatus.mie <= 0;
        csr_machine_reg.mstatus.mpp <= mode;
        mode <= m_mode;
        csr_machine_reg.mepc <= csr_in.epc;
        csr_machine_reg.mtval <= csr_in.etval;
        csr_machine_reg.mcause <= {28'b0,csr_in.ecause};
        exception <= 1;
      end else if (csr_machine_reg.mstatus.mie == 1 &&
                   csr_machine_reg.mie.meie == 1 &&
                   csr_machine_reg.mip.meip == 1 &&
                   csr_in.valid == 1) begin
        csr_machine_reg.mstatus.mpie <= csr_machine_reg.mstatus.mie;
        csr_machine_reg.mstatus.mie <= 0;
        csr_machine_reg.mstatus.mpp <= mode;
        mode <= m_mode;
        csr_machine_reg.mepc <= csr_in.epc;
        csr_machine_reg.mtval <= csr_in.etval;
        csr_machine_reg.mcause <= {1'b1,27'b0,interrupt_mach_extern};
        interrupt <= 1;
      end else if (csr_machine_reg.mstatus.mie == 1 &&
                   csr_machine_reg.mie.mtie == 1 &&
                   csr_machine_reg.mip.mtip == 1 &&
                   csr_in.valid == 1) begin
        csr_machine_reg.mstatus.mpie <= csr_machine_reg.mstatus.mie;
        csr_machine_reg.mstatus.mie <= 0;
        csr_machine_reg.mstatus.mpp <= mode;
        mode <= m_mode;
        csr_machine_reg.mepc <= csr_in.epc;
        csr_machine_reg.mtval <= csr_in.etval;
        csr_machine_reg.mcause <= {1'b1,27'b0,interrupt_mach_timer};
        interrupt <= 1;
      end else if (csr_machine_reg.mstatus.mie == 1 &&
                   csr_machine_reg.mie.msie == 1 &&
                   csr_machine_reg.mip.msip == 1 &&
                   csr_in.valid == 1) begin
        csr_machine_reg.mstatus.mpie <= csr_machine_reg.mstatus.mie;
        csr_machine_reg.mstatus.mie <= 0;
        csr_machine_reg.mstatus.mpp <= mode;
        mode <= m_mode;
        csr_machine_reg.mepc <= csr_in.epc;
        csr_machine_reg.mtval <= csr_in.etval;
        csr_machine_reg.mcause <= {1'b1,27'b0,interrupt_mach_soft};
        interrupt <= 1;
      end

      mret <= 0;

      if (csr_in.mret == 1) begin
        csr_machine_reg.mstatus.mie <= csr_machine_reg.mstatus.mpie;
        csr_machine_reg.mstatus.mpie <= 1;
        mode <= csr_machine_reg.mstatus.mpp;
        csr_machine_reg.mstatus.mpp <= u_mode;
        mret <= 1;
      end

    end

  end

endmodule
