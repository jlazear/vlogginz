`timescale 1ns/1ns

module testbench_fifo_uart_controller;

localparam period = 100;  // 10 MHz clock
localparam BAUDRATE = 115200;  // Hz
localparam DIVISOR = (10**9/(BAUDRATE * period) / 2) * 2;  // unitless, uart dclk divisor, force to be even
localparam WIDTH = 8;  // word width in bits
localparam N_SAMPLES = 8;  // number of samples to send in test
localparam VERBOSE = 1;
localparam TXPERIOD = period*DIVISOR; // 
localparam TXPHASE = 2;  // not relevant to dut, but sync manually generated txclk w/ dclk

logic clk, reset, txclk;
logic empty, busy, r_en, dv, tx_enable;
logic [7:0] r_data, data;
enum {START, ENABLED, DISABLED, DONE} tb_state;


fifo_uart_controller dut 
	(.clk(clk),
		.i_reset (reset),
		.i_tx_enable(tx_enable),
		.i_empty (empty),
		.i_busy  (busy),
		.i_r_data(r_data),
		.o_r_en  (r_en),
		.o_dv    (dv),
		.o_data  (data));

uart_tx #(
	.WIDTH  (WIDTH  ),
	.DIVISOR(DIVISOR)
) u_uart (
	.clk    (clk  ),
	.i_reset(reset),
	.i_data (data ),
	.i_dv   (dv   ),
	.o_tx   (tx   ),
	.o_busy (busy )
);


initial begin
	tb_state <= START;
	reset <= '0;
	busy <= '0;
	empty <= '1;
	r_data <= 8'hAA;
	tx_enable <= '0;

	$display("TX_BAUDRATE = %0d, TXPERIOD = %0d", BAUDRATE, TXPERIOD);
	$display("DCLKPERIOD = %0d", DIVISOR*period);
	$display("DIVISOR = %0d, WIDTH = %0d, N_SAMPLES = %0d", 
		DIVISOR, WIDTH, N_SAMPLES);

	@(posedge txclk) reset <= '1;
	@(posedge txclk) reset <= '0;
	@(posedge txclk);
	tb_state <= ENABLED;
	tx_enable <= '1;

	// @(posedge clk) reset <= '1;
	// @(posedge clk) reset <= '0;

	repeat (5)
		@(posedge txclk);

	@(posedge txclk);
	empty <= '0;
	@(posedge txclk);
	@(posedge txclk);
	@(posedge txclk);
	empty <= '1;

	repeat (7)
		@(posedge txclk);

	@(posedge txclk);
	// busy <= '1;

	repeat(5)
		@(posedge txclk);
	@(posedge txclk) empty <= '0;

	repeat(5)
		@(posedge txclk);

	// busy <= '0;

	repeat(40)
		@(posedge txclk);
	tx_enable <= '0;
	tb_state <= DISABLED;

	repeat(40)
		@(posedge txclk);

	tx_enable <= '1;
	tb_state <= ENABLED;

	repeat(20)
		@(posedge txclk);


	tb_state <= DONE;
	#(10*period) $stop;
end

// clk block
initial begin
	clk <= '1;
	forever #(period/2) clk <= ~clk;
end

// txclk block
initial begin
	txclk <= '1;
	#(TXPHASE);
	forever #(TXPERIOD/2) txclk <= ~txclk;
end

endmodule : testbench_fifo_uart_controller