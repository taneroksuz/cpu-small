module rvfi_wrapper (
	input         clock,
	input         reset,
	`RVFI_OUTPUTS
);
	(* keep *) wire                      irq_external = 0;
	(* keep *) wire                      irq_software = 0;
	(* keep *) wire                      irq_timer    = 0;
	(* keep *) wire               [63:0] reg_timer    = 0;

	(* keep *) wire                      mem_valid;
	(* keep *) wire                      mem_instr;
	(* keep *) wire               [31:0] mem_addr;
	(* keep *) wire               [31:0] mem_wdata;
	(* keep *) wire               [3 :0] mem_wstrb;
	(* keep *) `rvformal_rand_reg [31:0] mem_rdata;
	(* keep *) `rvformal_rand_reg        mem_ready;

	cpu uut (
		.rst (reset),
		.clk (clock),

		.memory_valid (mem_valid),
		.memory_instr (mem_instr),
		.memory_addr  (mem_addr),
		.memory_wdata (mem_wdata),
		.memory_wstrb (mem_wstrb),
		.memory_rdata (mem_rdata),
		.memory_ready (mem_ready),

		.meip  (irq_external),
		.msip  (irq_software),
		.mtip  (irq_timer),
		.mtime (reg_timer),

		`RVFI_CONN
	);

endmodule