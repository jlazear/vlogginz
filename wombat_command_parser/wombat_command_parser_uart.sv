`ifndef WOMBAT_CP
	`define WOMBAT_CP 1

`include "../uart/uart_rx.sv"
`include "../pulse/pulse.sv"
`include "../serializer/serializer.sv"
`include "../serializer/deserializer.sv"
`include "../fifo_uart/fifo_uart.sv"
`include "../register_block/register_block.sv"

module wombat_command_parser_uart #(
	parameter WORD_WIDTH = 8,
	parameter DIVISOR = 100,
	parameter SAMPLE_PHASE = 49,
	parameter FIFO_DEPTH = 128,
	parameter FIFO_LEVEL = 16,
	parameter REG_DEPTH = 16,
	parameter REG_WIDTH = 4,  // in words
	parameter UART_LITTLE_ENDIAN = 1,
	parameter LITTLE_ENDIAN = 0
	) (
	input clk,    // Clock
	input i_reset,

	// serial lines
	input i_rx,
	output o_tx,

	// memory write signals
	output o_w_en,
	output [WORD_WIDTH - 1 : 0] o_w_addr,
	output [REG_WIDTH*WORD_WIDTH - 1 : 0] o_w_value,

	// memory read signals
	output o_r_en,
	output [WORD_WIDTH - 1 : 0] o_r_addr,
	input [REG_WIDTH*WORD_WIDTH - 1 : 0] i_r_value,
	input i_r_valid
);

	logic [WORD_WIDTH*(REG_WIDTH + 2) - 1 : 0] p_data;
	logic [WORD_WIDTH*REG_WIDTH-1 : 0] scc_value, pr_data;
	logic [WORD_WIDTH-1 : 0] data, scc_addr, r_data;
	logic dv, p_dv_ser, p_dv, dv_pulse, scc_w_en, scc_r_en, pr_valid, r_valid;

	uart_rx #(
		.WIDTH       (WORD_WIDTH),
		.DIVISOR     (DIVISOR),
		.SAMPLE_PHASE(SAMPLE_PHASE),
		.LITTLE_ENDIAN(UART_LITTLE_ENDIAN)
		) u_uart_rx (
		.clk         (clk),
		.i_reset     (i_reset),
		.i_rx        (i_rx),
		.o_data      (data),
		.o_data_valid(dv)
		);

	pulse u_pulse_deser (
		.clk    (clk),
		.i_reset(i_reset),
		.i_x    (dv),
		.o_x    (p_dv_ser)
		);

	deserializer #(
		.WIDTH        (WORD_WIDTH),
		.NUM_WORDS    (REG_WIDTH+2),
		.LITTLE_ENDIAN(LITTLE_ENDIAN)
		) u_deserializer (
		.clk    (clk),
		.i_reset(i_reset),
		.i_data (data),
		.i_dv   (p_dv_ser),
		.o_data (p_data),
		.o_dv   (p_dv)
		);

	pulse #(
		.WIDTH(1)
		) u_pulse (
		.clk    (clk),
		.i_reset(i_reset),
		.i_x    (p_dv),
		.o_x    (dv_pulse)
		);

	command_controller #(
		.WORD_WIDTH (WORD_WIDTH),
		.VALUE_WORDS(REG_WIDTH )
	) u_cmd_controller (
		.clk    (clk      ),
		.i_reset(i_reset  ),
		.i_data (p_data   ),
		.i_dv   (dv_pulse ),
		.o_w_en (scc_w_en ),
		.o_r_en (scc_r_en ),
		.o_addr (scc_addr ),
		.o_value(scc_value)
	);

	assign o_w_en = scc_w_en;
	assign o_w_addr = scc_addr;
	assign o_w_value = scc_value;
	assign o_r_en = scc_r_en;
	assign o_r_addr = scc_addr;
	assign pr_data = i_r_value;
	assign pr_valid = i_r_valid;

	// --- expected connections as follows ---
	// register_block #(
	// 	.WIDTH(REG_WIDTH*WORD_WIDTH),
	// 	.DEPTH(REG_DEPTH)
	// 	) u_register_block (
	// 	.clk      (clk),
	// 	.reset    (i_reset),
	// 	.i_w_en   (scc_w_en),
	// 	.i_w_addr (scc_addr),
	// 	.i_w_value(scc_value),
	// 	.i_r_en   (scc_r_en),
	// 	.i_r_addr (scc_addr),
	// 	.o_r_value(pr_data),
	// 	.o_r_valid(pr_valid)
	// 	);

	serializer #(
		.WIDTH        (WORD_WIDTH),
		.NUM_WORDS    (REG_WIDTH),
		.LITTLE_ENDIAN(LITTLE_ENDIAN)
		) u_serializer (
		.clk    (clk),
		.i_reset(i_reset),
		.i_data (pr_data),
		.i_dv   (pr_valid),
		.o_data (r_data),
		.o_dv   (r_valid)
		);

	fifo_uart #(
		.WIDTH  (WORD_WIDTH),
		.DEPTH  (FIFO_DEPTH),
		.DIVISOR(DIVISOR),
		.LEVEL  (FIFO_LEVEL),
		.LITTLE_ENDIAN(UART_LITTLE_ENDIAN)
		) u_fifo_uart (
		.clk          (clk),
		.i_reset      (i_reset),
		.i_fifo_enable('1),
		.i_tx_enable  ('1),
		.i_w_en       (r_valid),
		.i_w_data     (r_data),
		.o_tx         (o_tx),
		.o_full       (o_full),
		.o_afull      (o_afull),
		.o_empty      (o_empty),
		.o_aempty     (o_aempty)
		);

endmodule

`endif