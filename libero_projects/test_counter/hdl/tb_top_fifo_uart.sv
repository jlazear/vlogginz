`timescale 1ns/1ns

module testbench_top_fifo_uart;

localparam period = 1000;  // 1 MHz clock
localparam BAUDRATE = 115200;  // Hz
localparam DIVISOR = (10**9/(BAUDRATE * period) / 2) * 2;  // unitless, uart dclk divisor, force to be even
localparam WIDTH = 8;  // word width in bits
localparam N_SAMPLES = 8;  // number of samples to send in test
localparam VERBOSE = 1;
localparam TXPERIOD = period*DIVISOR; // 
localparam TXPHASE = 2;  // not relevant to dut, but sync manually generated txclk w/ dclk

logic clk, reset, txclk;
logic enable, tx, dv;
logic [WIDTH-1 : 0] data;
enum {START, DONE} tb_state;


top_fifo_uart #(
	.COUNTER_WIDTH(11  ),
	.COUNTER_VALUE(1200)
) dut (
	.clk     (clk   ),
	.i_reset (reset ),
	.i_enable(enable),
	.o_tx    (tx    )
);

uart_rx #(
	.DIVISOR     (DIVISOR),
	.SAMPLE_PHASE(DIVISOR/2)
	) u_uart_rx (
	.clk         (clk),
	.i_reset     (reset),
	.i_rx        (tx),
	.o_data      (data),
	.o_data_valid(dv));


initial begin
	tb_state <= START;
	reset <= '0;
	enable <= '0;

	@(posedge clk) reset <= '1;
	@(posedge clk) reset <= '0;
	@(posedge clk) enable <= '1;

	repeat (2000)
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

endmodule : testbench_top_fifo_uart