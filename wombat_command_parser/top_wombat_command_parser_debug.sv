`ifndef TOP_WOMBAT_COMMAND_PARSER_DEBUG
	`define TOP_WOMBAT_COMMAND_PARSER_DEBUG 1

module top_wombat_command_parser_debug #(
	parameter WORD_WIDTH = 8,
	parameter DIVISOR = 434,  // suitable for 50 MHz clk and 115200 baud
	parameter SAMPLE_PHASE = 217,
	parameter FIFO_DEPTH = 128,
	parameter FIFO_LEVEL = 16,
	parameter REG_DEPTH = 16,
	parameter REG_WIDTH = 4,  // in words
	parameter UART_LITTLE_ENDIAN = 1,
	parameter LITTLE_ENDIAN = 0
	) (
	input clk,    // Clock
	input i_reset,
	input i_rx,
	output o_tx,
	output [WORD_WIDTH*REG_WIDTH-1 : 0] o_mem [REG_DEPTH-1 : 0],

	// #DELME debug
	input [1:0] i_buttons,
	output [7:0] o_cmux_out
);

	logic w_en, r_en, r_valid;
	logic [WORD_WIDTH-1:0] w_addr, r_addr;
	logic [WORD_WIDTH*REG_WIDTH-1:0] w_data, r_data;
	logic o_reset;  // #DELME debug

	wombat_command_parser_uart #(
		.WORD_WIDTH        (WORD_WIDTH),
		.DIVISOR           (DIVISOR),
		.SAMPLE_PHASE      (SAMPLE_PHASE),
		.FIFO_DEPTH        (FIFO_DEPTH),
		.FIFO_LEVEL        (FIFO_LEVEL),
		.REG_DEPTH         (REG_DEPTH),
		.REG_WIDTH         (REG_WIDTH),
		.UART_LITTLE_ENDIAN(UART_LITTLE_ENDIAN),
		.LITTLE_ENDIAN     (LITTLE_ENDIAN)
		) u_command_parser_uart (
		.clk      (clk),
		.i_reset  (o_reset),
		.i_rx     (i_rx),
		.o_tx     (o_tx),
		.o_w_en   (w_en),
		.o_w_addr (w_addr),
		.o_w_value (w_data),
		.o_r_en   (r_en),
		.o_r_addr (r_addr),
		.i_r_value (r_data),
		.i_r_valid(r_valid)
		);

	register_block #(
		.WIDTH(REG_WIDTH*WORD_WIDTH),
		.DEPTH(REG_DEPTH)
	) u_register_block (
		.clk      (clk    ),
		.reset    (o_reset),
		.i_w_en   (w_en   ),
		.i_w_addr (w_addr ),
		.i_w_value(w_data ),
		.i_r_en   (r_en   ),
		.i_r_addr (r_addr ),
		.o_r_value(r_data ),
		.o_r_valid(r_valid),
		.o_mem(o_mem)
	);

	// #DELME debug
	localparam CMUX_N_STATES = 13;
	logic [WORD_WIDTH-1:0] i_cmux_in [CMUX_N_STATES-1:0];
	logic [1:0] o_buttons;
	debug #(
		.WIDTH             (WORD_WIDTH),
		.CMUX_N_STATES     (CMUX_N_STATES),
		.DEADZONE_WIDTH    (1024),
		.MUX_DEADZONE_WIDTH(1024*1024*50)
		) u_debug (
		.clk       (clk),
		.i_reset   (o_reset),
		.i_buttons (i_buttons),
		.o_buttons (o_buttons),
		.i_cmux_in (i_cmux_in),
		.o_cmux_out(o_cmux_out),
		.o_reset   (o_reset)
		);

	// #DELME debug
	// driving active-low LEDs
	assign i_cmux_in[0] = ~8'b10100011;  // reference state, LDLDDDLL on board
	assign i_cmux_in[1] = ~8'b11000101;  // reference state, LLDDDLDL on board
	assign i_cmux_in[2] = ~{w_en, w_en, r_en, r_en, r_valid, r_valid, r_valid, r_valid};
	assign i_cmux_in[3] = ~w_addr;
	assign i_cmux_in[4] = ~w_data[3 * WORD_WIDTH +: WORD_WIDTH];
	assign i_cmux_in[5] = ~w_data[2 * WORD_WIDTH +: WORD_WIDTH];
	assign i_cmux_in[6] = ~w_data[1 * WORD_WIDTH +: WORD_WIDTH];
	assign i_cmux_in[7] = ~w_data[0 * WORD_WIDTH +: WORD_WIDTH];
	assign i_cmux_in[8] = ~r_addr;
	assign i_cmux_in[9] = ~r_data[3 * WORD_WIDTH +: WORD_WIDTH];
	assign i_cmux_in[10] = ~r_data[2 * WORD_WIDTH +: WORD_WIDTH];
	assign i_cmux_in[11] = ~r_data[1 * WORD_WIDTH +: WORD_WIDTH];
	assign i_cmux_in[12] = ~r_data[0 * WORD_WIDTH +: WORD_WIDTH];

endmodule

`endif