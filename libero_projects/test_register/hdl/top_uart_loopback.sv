module top_uart_loopback #(
	parameter DIVISOR = 434,
	parameter SAMPLE_PHASE = 217,
	parameter FIFO_DEPTH = 16,
	parameter FIFO_LEVEL = 2
	) (
	input clk,    // Clock
	input i_reset,
	input i_rx,
	output o_tx
);

	logic dv, r_valid, full, afull, empty, aempty;
	logic [7:0] data, r_data;

	assign r_data = data;

	uart_rx #(
		.WIDTH       (8),
		.DIVISOR     (DIVISOR),
		.SAMPLE_PHASE(SAMPLE_PHASE)
		) u_uart_rx (
		.clk         (clk),
		.i_reset     (i_reset),
		.i_rx        (i_rx),
		.o_data      (data),
		.o_data_valid(dv));

	pulse #(
		.WIDTH(1)
		) u_pulse (
		.clk    (clk),
		.i_reset(i_reset),
		.i_x    (dv),
		.o_x    (r_valid)
		);

	fifo_uart #(
		.WIDTH  (8),
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

endmodule