`include "../fifo/fifo.sv"
`include "../simple_spi/simple_spi.sv"
`include "../simple_uart/simple_uart_rx.sv"

module uart_spi_dataflow 
	#(WIDTH=8,
		DEPTH=128,
		LEVEL=16,
		DIVISOR=2)
	(
	input clk,    // Clock
	input reset, 
	input i_rx,  // serial rx line
	input i_r_en, // fifo read enable
	output [WIDTH-1 : 0] o_r_data, // fifo read data
	output o_full, // fifo full flag
	output o_a_full, // fifo almost full flag
	output o_empty, // fifo empty flag
	output o_a_empty // fifo almost empty flag
);

	logic [WIDTH-1 : 0] udata, sdata, r_data;
	logic udv, sclk, mosi, ov, sov, pov, w_en, full, desync;

	pulse u_pulse (
		.clk(clk),
		.reset(reset),
		.x(sov),
		.y(pov));

	assign w_en =  pov && !full;

	simple_uart_rx u_uart_rx (
		.clk(clk),
		.reset     (reset),
		.rx        (i_rx),
		.q         (udata),
		.data_valid(udv));

	simple_spi_master #(
		.DIVISOR(DIVISOR),
		.WIDTH  (WIDTH)) 
	u_spi_master (
	.clk           (clk),
	.i_reset       (reset),
	.i_data        (udata),
	.i_load_enable (udv),
	.o_sclk        (sclk),
	.o_mosi        (mosi),
	.o_output_valid(ov));

	simple_spi_slave #(
		.WIDTH(WIDTH))
	u_spi_slave (
		.i_sclk        (sclk),
		.i_areset 	   (reset),
		.i_mosi        (mosi),
		.i_cs          (ov),
		.o_data        (sdata),
		.o_output_valid(sov),
		.o_cs_desync   (desync));

	fifo #(
		.WORD_WIDTH(WIDTH),
		.DEPTH     (DEPTH),
		.LEVEL     (LEVEL))
	u_fifo (
		.clk     (clk),
		.reset   (reset),
		.i_w_en  (w_en),
		.i_w_data(sdata),
		.i_r_en  (i_r_en),
		.o_r_data(r_data),
		.o_afull (o_a_full),
		.o_full  (full),
		.o_aempty(o_a_empty),
		.o_empty (o_empty));

	assign o_r_data = r_data;
endmodule