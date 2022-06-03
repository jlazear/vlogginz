`ifndef DEBUG
	`define DEBUG 1

/*
	assign i_cmux_in[0] = ~8'b10100011;  // reference state, LDLDDDLL on board
	assign i_cmux_in[1] = ~8'b11000101;  // reference state, LLDDDLDL on board
*/

module debug #(
	parameter WIDTH = 8,
	parameter CMUX_N_STATES = 4,
	parameter DEADZONE_WIDTH = 1024,
	parameter MUX_DEADZONE_WIDTH = 1024*1024*50
	) (
	input clk,    // Clock
	input i_reset,
	input [1:0] i_buttons,
	output [1:0] o_buttons,
	input [WIDTH-1 : 0] i_cmux_in [CMUX_N_STATES-1:0],
	output [WIDTH-1 : 0] o_cmux_out,
	output o_reset
);

	logic [1:0] buttons;

	debouncer #(
		.DEADZONE_WIDTH(DEADZONE_WIDTH)
		) u_debouncer_b0 (
		.clk    (clk),
		.i_reset(i_reset),
		.i_in   (i_buttons[0]),
		.o_out  (buttons[0])
		);

	debouncer #(
		.DEADZONE_WIDTH(DEADZONE_WIDTH)
		) u_debouncer_b1 (
		.clk    (clk),
		.i_reset(i_reset),
		.i_in   (i_buttons[1]),
		.o_out  (buttons[1])
		);

	assign reset = &buttons;

	logic [WIDTH-1 : 0] mux_out;

	click_mux #(
		.WIDTH   (WIDTH),
		.N_STATES(CMUX_N_STATES)
		) u_cmux (
		.clk    (clk),
		.i_reset(i_reset),
		.i_click(buttons[1]),
		.i_x    (i_cmux_in),
		.o_x    (mux_out)
		);

	genvar i;
	for (i=0; i<8; i++) begin
		debouncer #(
			.DEADZONE_WIDTH(MUX_DEADZONE_WIDTH)
			) u_debug_debounce (
			.clk    (clk),
			.i_reset(i_reset),
			.i_in   (mux_out[i]),
			.o_out  (o_cmux_out[i])
			);
	end


	assign o_buttons = {buttons[1], buttons[0]};
	assign o_reset = reset;

endmodule

`endif