module top_command_parser #(
	parameter DIVISOR = 434,
	parameter SAMPLE_PHASE = 217,
	parameter REG_WIDTH = 32,
	parameter REG_DEPTH = 4
	) (
	input clk,    // Clock
	input i_reset,
	input i_rx,
	output o_tx
);

	logic w_en, r_en, r_valid;
	logic [7:0] w_addr, r_addr;
	logic [31:0] w_data, r_data;

	command_parser_uart #(
		.WORD_WIDTH        (8),
		.VALUE_WORDS       (4),
		.PULSE_W_EN_MAX_LEN(1),
		.DIVISOR           (DIVISOR),
		.SAMPLE_PHASE      (SAMPLE_PHASE),
		.FIFO_DEPTH        (32),
		.FIFO_LEVEL        (2)
		) u_command_parser_uart (
		.clk      (clk),
		.i_reset  (i_reset),
		.i_rx     (i_rx),
		.o_tx     (o_tx),
		.o_w_en   (w_en),
		.o_w_addr (w_addr),
		.o_w_data (w_data),
		.o_r_en   (r_en),
		.o_r_addr (r_addr),
		.i_r_data (r_data),
		.i_r_valid(r_valid)
		);

register_block #(
		.WIDTH(REG_WIDTH),
		.DEPTH(REG_DEPTH)
	) u_register_block (
		.clk      (clk),
		.reset    (i_reset),
		.i_w_en   (w_en),
		.i_w_addr (w_addr),
		.i_w_value(w_data),
		.i_r_en   (r_en),
		.i_r_addr (r_addr),
		.o_r_value(r_data),
		.o_r_valid(r_valid)
	);

endmodule