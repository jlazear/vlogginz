module command_parser_uart #(
	parameter WORD_WIDTH = 8,
	parameter VALUE_WORDS = 4,
	parameter PULSE_W_EN_MAX_LEN = 1,
	parameter DIVISOR = 100,
	parameter SAMPLE_PHASE = 49,
	parameter FIFO_DEPTH = 128,
	parameter FIFO_LEVEL = 16
	) (
	input clk,    // Clock
	input i_reset,

	// serial lines
	input i_rx,
	output o_tx,

	// memory write signals
	output o_w_en,
	output [WORD_WIDTH - 1 : 0] o_w_addr,
	output [VALUE_WORDS*WORD_WIDTH - 1 : 0] o_w_data,

	// memory read signals
	output o_r_en,
	output [WORD_WIDTH - 1 : 0] o_r_addr,
	input [VALUE_WORDS*WORD_WIDTH - 1 : 0] i_r_data,
	input i_r_valid
);

	logic [WORD_WIDTH-1 : 0] data, r_data;
	logic dv, r_valid, full, afull, empty, aempty;

	uart_rx #(
		.WIDTH       (WORD_WIDTH),
		.DIVISOR     (DIVISOR),
		.SAMPLE_PHASE(SAMPLE_PHASE)
		) u_uart_rx (
		.clk         (clk),
		.i_reset     (i_reset),
		.i_rx        (i_rx),
		.o_data      (data),
		.o_data_valid(dv));

	serializer #(
		.NUM_WORDS    (VALUE_WORDS),
		.LITTLE_ENDIAN(1)
		) u_serializer (
		.clk    (clk),
		.i_reset(i_reset),
		.i_data (i_r_data),
		.i_dv   (i_r_valid),
		.o_data (r_data),
		.o_dv   (r_valid)
		);

	fifo_uart #(
		.WIDTH  (WORD_WIDTH),
		.DIVISOR(DIVISOR),
		.DEPTH  (FIFO_DEPTH),
		.LEVEL  (FIFO_LEVEL)
		) u_fifo_uart (
		.clk          (clk),
		.i_reset      (i_reset),
		.i_fifo_enable('1),
		.i_tx_enable  ('1),
		.i_w_en       (r_valid),
		.i_w_data     (r_data),
		.o_tx         (o_tx),
		.o_full       (full),
		.o_afull      (afull),
		.o_empty      (empty),
		.o_aempty     (aempty)
		);

	command_controller #(
		.WORD_WIDTH        (WORD_WIDTH),
		.VALUE_WORDS       (VALUE_WORDS),
		.PULSE_W_EN_MAX_LEN(PULSE_W_EN_MAX_LEN)
		) u_command_controller (
		.clk     (clk),
		.i_reset (i_reset),
		.i_data  (data),
		.i_dv    (dv),
		.o_w_addr(o_w_addr),
		.o_w_data(o_w_data),
		.o_w_en  (o_w_en),
		.o_r_addr(o_r_addr),
		.o_r_en  (o_r_en));

endmodule