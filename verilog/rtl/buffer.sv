import configure::*;
import constants::*;
import wires::*;

module buffer
(
  input logic reset,
  input logic clock,
  input buffer_in_type buffer_in,
  output buffer_out_type buffer_out
);
  timeunit 1ns;
  timeprecision 1ps;

  localparam depth = $clog2(buffer_depth-1);
  localparam total = buffer_depth-2;

  localparam [depth-1:0] one = 1;

  logic [48 : 0] buffer [0:buffer_depth-1];
  logic [48 : 0] buffer_reg [0:buffer_depth-1];

  typedef struct packed{
    logic [depth-1 : 0] wid;
    logic [depth-1 : 0] rid;
    logic [depth-1 : 0] diff;
    logic [depth : 0] count;
    logic [depth : 0] align;
    logic [48 : 0] data0;
    logic [48 : 0] data1;
    logic [31 : 0] pc;
    logic [31 : 0] instr;
    logic [0 : 0] miss;
    logic [0 : 0] comp;
    logic [0 : 0] done;
    logic [0 : 0] stall;
  } reg_type;

  parameter reg_type init_reg = '{
    wid : 0,
    rid : 0,
    diff : 0,
    count : 0,
    align : 0,
    data0 : 0,
    data1 : 0,
    pc : 0,
    instr : 0,
    miss : 0,
    comp : 0,
    done : 0,
    stall : 0
  };

  reg_type r, rin, v;

  always_comb begin

    buffer = buffer_reg;

    v = r;

    if (buffer_in.clear == 1) begin
      v.count = 0;
      v.wid = 0;
      v.rid = buffer_in.align ? 1 : 0;
      v.align = buffer_in.align ? 1 : 0;
    end else if (r.stall == 0) begin
      if (buffer_in.ready == 1) begin
        buffer[v.wid] = {buffer_in.pc,buffer_in.error,buffer_in.rdata[15:0]};
        v.wid = v.wid + 1;
        buffer[v.wid] = {buffer_in.pc+2,buffer_in.error,buffer_in.rdata[31:16]};
        v.wid = v.wid + 1;
        v.count = v.count + 2;
      end
    end

    v.data0 = buffer[v.rid];
    v.data1 = buffer[v.rid+one];

    v.pc = 0;

    v.instr = 0;

    v.comp = 0;

    v.miss = 0;

    v.done = 0;

    v.diff = 0;

    if (v.count > v.align) begin
      v.pc = v.data0[48:17];
      v.instr[15:0] = v.data0[15:0];
      v.comp = ~(&v.data0[1:0]);
      v.miss = v.data0[16];
      v.done = v.comp;
      v.diff = v.comp ? 1 : 0;
    end
    if (v.count > v.align+1) begin
      if (v.comp == 0) begin
        v.instr[31:16] = v.data1[15:0];
        v.miss = v.data1[16];
        v.done = 1;
        v.diff = 2;
      end
    end

    if (buffer_in.stall == 1) begin
      v.miss = 0;
      v.done = 0;
      v.diff = 0;
    end

    v.count = v.count - v.diff;
    v.rid = v.rid + v.diff;

    v.stall = 0;

    if (v.count > total) begin
      v.stall = 1;
    end

    buffer_out.pc = v.done ? v.pc : 0;
    buffer_out.instr = v.done ? v.instr : nop_instr;
    buffer_out.miss = v.done ? v.miss : 0;
    buffer_out.done = v.done;
    buffer_out.stall = v.stall;

    rin = v;

  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      buffer_reg <= '{default:0};
      r <= init_reg;
    end else begin
      buffer_reg <= buffer;
      r <= rin;
    end
  end

endmodule
