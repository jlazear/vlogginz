`ifndef MUX
	`define MUX 1

module mux #(
	parameter WIDTH = 8,
	parameter N_STATES = 2
	)(
	input [$clog2(N_STATES)-1 : 0] i_select,
	input [WIDTH-1 : 0] i_x [N_STATES-1 : 0],
	output [WIDTH-1 : 0] o_x
);

	assign o_x = i_x[i_select];

endmodule : mux

`endif