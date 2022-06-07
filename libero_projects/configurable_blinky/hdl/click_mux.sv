`ifndef CLICK_MUX
	`define CLICK_MUX 1

module click_mux #(
	parameter WIDTH = 8,
	parameter N_STATES = 4
	) (
	input clk,    // Clock
	input i_reset,
	input i_click,
	input [WIDTH-1 : 0] i_x [N_STATES-1 : 0],
	output [WIDTH-1 : 0] o_x
);

	logic [$clog2(N_STATES)-1 : 0] cnt;
	logic prev_click;
	logic [1:0] click_edge;

	assign click_edge = {prev_click, i_click};

	always_ff @(posedge clk) begin
		prev_click <= i_click;
		cnt <= cnt;
		if (i_reset) begin
			cnt <= '0;
			prev_click <= '0;
		end else if (click_edge == 2'b01) begin
			cnt <= (cnt >= N_STATES-1) ? '0 : cnt + 1'b1;
		end
	end

	assign o_x = i_x[cnt];

endmodule

`endif