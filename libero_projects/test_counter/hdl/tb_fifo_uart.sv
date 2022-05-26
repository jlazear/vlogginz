`timescale 1ns/1ns

module testbench_fifo_uart;

localparam period = 100;  // 10 MHz clock
localparam BAUDRATE = 115200;  // Hz
localparam DIVISOR = (10**9/(BAUDRATE * period) / 2) * 2;  // unitless, uart dclk divisor, force to be even
localparam WIDTH = 8;  // word width in bits
localparam N_SAMPLES = 8;  // number of samples to send in test
localparam VERBOSE = 1;
localparam TXPERIOD = period*DIVISOR; // 
localparam TXPHASE = 2;  // not relevant to dut, but sync manually generated txclk w/ dclk
localparam DEPTH = 16;
localparam LEVEL = 2;

logic clk, reset, txclk;
logic empty, enable, w_en;
logic [WIDTH-1:0] w_data;
enum {START, INITIAL_FILL, ENABLED, DISABLED, DONE} tb_state;


fifo_uart #(
	.WIDTH  (WIDTH  ),
	.DEPTH  (DEPTH  ),
	.DIVISOR(DIVISOR),
	.LEVEL  (LEVEL  )
) dut (
	.clk     (clk   ),
	.i_reset (reset ),
	.i_enable(enable),
	.i_w_en  (w_en  ),
	.i_w_data(w_data),
	.o_tx    (tx    ),
	.o_full  (full  ),
	.o_afull (afull ),
	.o_empty (empty ),
	.o_aempty(aempty)
);

initial w_data <= '0;
always @(posedge clk) w_data <= {w_data[WIDTH-2:0], ~w_data[WIDTH-1]};

initial begin
	tb_state <= START;
	reset <= '0;
	enable <= '0;
	w_en <= '0;

	$display("TX_BAUDRATE = %0d, TXPERIOD = %0d", BAUDRATE, TXPERIOD);
	$display("DCLKPERIOD = %0d", DIVISOR*period);
	$display("DIVISOR = %0d, WIDTH = %0d, N_SAMPLES = %0d", 
		DIVISOR, WIDTH, N_SAMPLES);

	@(posedge txclk) reset <= '1;
	@(posedge txclk) reset <= '0;

	tb_state <= INITIAL_FILL;
	for (int i=0; i < DEPTH/2; i++) begin
		@(posedge clk);
		w_en <= '1;
	end
	@(posedge clk);
	w_en <= '0;


	@(posedge txclk);
	tb_state <= ENABLED;
	enable <= '1;

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
	enable <= '0;
	tb_state <= DISABLED;

	repeat(40)
		@(posedge txclk);

	enable <= '1;
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

endmodule : testbench_fifo_uart