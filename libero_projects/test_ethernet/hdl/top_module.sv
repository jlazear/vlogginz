module top_module 
	#(parameter INVERT_ENABLE=1,
		parameter INVERT_OUTPUT=1
		)
	(
	input clk,    // Clock
	input i_reset,
	input i_enable,
	output [7:0] o_data,
	output [7:0] o_txd,
	output o_tx_en
);

	localparam WIDTH = 30;

	wire [WIDTH-1 : 0] c_out;
	wire [7:0] data_out;
	logic rollover;

	counter #(
		.WIDTH(WIDTH),
		.RESET_VALUE   (0),
		.MAX_VALUE     (2**WIDTH - 1),
		.ROLLOVER_VALUE(0))
	u_counter (
		.clk     (clk),
		.reset   (i_reset),
		.enable  (INVERT_ENABLE ? !i_enable : i_enable),
		.cnt     (c_out),
		.rollover(rollover));

	assign data_out = c_out[WIDTH-1 : WIDTH-8];

	assign changed = (data != data_out);


endmodule