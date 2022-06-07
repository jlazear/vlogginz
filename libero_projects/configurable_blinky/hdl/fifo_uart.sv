`ifndef FIFO_UART
	`define FIFO_UART 1

module fifo_uart #(
	parameter WIDTH=8,
	parameter DEPTH=128,
	parameter DIVISOR=100,
	parameter LEVEL=16,
	parameter LITTLE_ENDIAN=0
	)(
	input clk,    // Clock
	input i_reset,
	input i_fifo_enable,
	input i_tx_enable,
	input i_w_en,
	input [WIDTH-1 : 0] i_w_data,
	output o_tx,
	output o_full,
	output o_afull,
	output o_empty,
	output o_aempty
);

	logic [WIDTH-1: 0] r_data, data;
	logic r_en, empty, busy, dv, tx;

	fifo #(
		.WORD_WIDTH(WIDTH),
		.DEPTH     (DEPTH),
		.LEVEL     (LEVEL)
	) u_fifo (
		.clk     (clk                    ),
		.reset   (i_reset                ),
		.i_w_en  (i_w_en && i_fifo_enable),
		.i_w_data(i_w_data               ),
		.i_r_en  (r_en                   ),
		.o_r_data(r_data                 ),
		.o_afull (o_afull                ),
		.o_full  (o_full                 ),
		.o_aempty(o_aempty               ),
		.o_empty (empty                  )
	);

	fifo_uart_controller #(.WIDTH(WIDTH)) u_controller (
		.clk     (clk   ),
		.i_reset (i_reset ),
		.i_tx_enable(i_tx_enable),
		.i_empty (empty ),
		.i_busy  (busy  ),
		.i_r_data(r_data),
		.o_r_en  (r_en  ),
		.o_dv    (dv    ),
		.o_data  (data  )
	);

	uart_tx #(
		.WIDTH  (WIDTH  ),
		.DIVISOR(DIVISOR),
		.LITTLE_ENDIAN(LITTLE_ENDIAN)
	) u_uart (
		.clk    (clk  ),
		.i_reset(i_reset),
		.i_data (data ),
		.i_dv   (dv   ),
		.o_tx   (tx   ),
		.o_busy (busy )
	);

	assign o_tx = tx;
	assign o_empty = empty;

endmodule

`endif