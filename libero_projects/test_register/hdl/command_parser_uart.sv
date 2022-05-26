module command_parser_uart #(
	parameter WORD_WIDTH = 8,
	parameter VALUE_WORDS = 4,
	parameter PULSE_W_EN_MAX_LEN = 1,
	parameter DIVISOR = 100,
	parameter SAMPLE_PHASE = 49
	) (
	input clk,    // Clock
	input i_reset,
	input i_rx, 
	output [WORD_WIDTH - 1 : 0] o_w_addr,
	output [VALUE_WORDS*WORD_WIDTH - 1 : 0] o_w_data,
	output o_w_en
);

	logic [WORD_WIDTH-1 : 0] data;
	logic dv;

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
		.o_w_en  (o_w_en));

endmodule