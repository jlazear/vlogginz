`timescale 1ns/1ns

module testbench_tx;

localparam period = 100;  // 10 MHz clock
localparam BAUDRATE = 115200;  // Hz
localparam DIVISOR = (10**9/(BAUDRATE * period) / 2) * 2;  // unitless, uart dclk divisor, force to be even
localparam WIDTH = 8;  // word width in bits
localparam N_SAMPLES = 8;  // number of samples to send in test
localparam VERBOSE = 1;
localparam TXPERIOD = period*DIVISOR; // 
localparam TXPHASE = 2;  // not relevant to dut, but sync manually generated txclk w/ dclk

logic clk, reset, txclk;
logic tx, dv, busy, _x;
logic [WIDTH-1 : 0] data, temp;
enum {START, WRITE, UNTASKED, DONE} tb_state;


uart_tx #(
	.WIDTH  (WIDTH  ),
	.DIVISOR(DIVISOR)
) dut (
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
	dv <= '0;
	data <= '0;

	$display("TX_BAUDRATE = %0d, TXPERIOD = %0d", BAUDRATE, TXPERIOD);
	$display("DCLKPERIOD = %0d", DIVISOR*period);
	$display("DIVISOR = %0d, WIDTH = %0d, N_SAMPLES = %0d", 
		DIVISOR, WIDTH, N_SAMPLES);

	@(posedge txclk) reset <= '1;
	@(posedge txclk) reset <= '0;
	@(posedge txclk);

	tb_state <= WRITE;
	for (int i=0; i<N_SAMPLES; i++) begin
		@(posedge txclk)
		temp = $urandom();
		data <= temp;
		dv <= '1;
		repeat (WIDTH+1) begin
			@(posedge txclk)
			dv <= '0;
		end
	end

	tb_state <= UNTASKED;
	repeat (20)
		@(posedge txclk);

	tb_state <= DONE;
	@(posedge txclk)
	$stop;
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

endmodule : testbench_tx