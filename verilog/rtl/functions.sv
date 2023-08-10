package functions;
	timeunit 1ns;
	timeprecision 1ps;

  function [31:0] multiplexer;
    input [31:0] data0;
    input [31:0] data1;
    input [0:0] sel;
    begin
      if (sel == 0)
        multiplexer = data0;
      else
        multiplexer = data1;
    end
  endfunction

  function [31:0] store_data;
    input [31:0] sdata;
    input [0:0] sb;
    input [0:0] sh;
    input [0:0] sw;
    begin
      if (sb == 1)
        store_data = {sdata[7:0],sdata[7:0],sdata[7:0],sdata[7:0]};
      else if (sh == 1)
        store_data = {sdata[15:0],sdata[15:0]};
      else if (sw == 1)
        store_data = sdata;
      else
        store_data = 0;
    end
  endfunction

endpackage
