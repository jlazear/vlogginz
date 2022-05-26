module top_fifo_uart #(
	parameter WIDTH = 8,
	parameter DIVISOR = 9,
	parameter COUNTER_WIDTH = 20,
	parameter COUNTER_VALUE = 1000000,
	parameter DEPTH = 8,
	parameter LEVEL = 2
	) (
	input clk,    // Clock
	input i_reset,
	input i_enable,
	output o_tx
);

	logic rollover, dv, w_en, full, afull, empty, aempty;
	logic [7:0] w_data;
	localparam MAX_VALUE = (COUNTER_VALUE == 0) ? 2**COUNTER_WIDTH - 1 : COUNTER_VALUE;

	counter #(
		.WIDTH(COUNTER_WIDTH),
		.MAX_VALUE     (MAX_VALUE))
	u_counter (
		.clk     (clk),
		.reset   (i_reset),
		.enable  ('1),
		.cnt     (_x),
		.rollover(rollover));

	pulse_extender #(.WIDTH(DEPTH/2)) u_pulse_extender (
		.clk(clk),
		.i_reset(i_reset),
		.i_x(rollover),
		.o_x(w_en));

	always_ff @(posedge clk) 
		if (i_reset)
			w_data <= '1;
		else
			w_data <= {w_data[WIDTH-2:0], ~w_data[WIDTH-1]};

	fifo_uart #(
		.WIDTH  (WIDTH  ),
		.DEPTH  (DEPTH  ),
		.DIVISOR(DIVISOR),
		.LEVEL  (LEVEL  )
	) u_fifo_uart (
		.clk     (clk   ),
		.i_reset (i_reset ),
		.i_enable(i_enable),
		.i_w_en  (w_en  ),
		.i_w_data(w_data),
		.o_tx    (tx    ),
		.o_full  (full  ),
		.o_afull (afull ),
		.o_empty (empty ),
		.o_aempty(aempty)
	);

	assign o_tx = tx;

endmodule