`timescale 1ns/1ns

module testbench;

localparam period = 100;  // 10 MHz clock
localparam DIVISOR = 9;  // unitless, uart dclk divisor
localparam SAMPLE_PHASE = DIVISOR/2;  // sample phase in number of samples
localparam TXPERIOD = period*DIVISOR; // 
localparam TXPHASE = TXPERIOD * 1/4;

logic clk, reset, txclk;
enum {START, DONE} tb_state;


logic tx, rx; // driven
top_uart_loopback dut (
	.clk    (clk),
	.i_reset(reset),
	.i_rx   (rx),
	.o_tx   (tx)
	);

logic busy; // driven
logic i_dv;  // driving
logic [7:0] i_data;  // driving
uart_tx #(
	.DIVISOR(DIVISOR)
	) u_uart_tx (
	.clk    (clk),
	.i_reset(reset),
	.i_data (i_data),
	.i_dv   (i_dv),
	.o_tx   (rx),
	.o_busy (busy)
	);


logic o_dv;  // driven
logic [7:0] o_data;  // driven
uart_rx #(
	.DIVISOR(DIVISOR),
	.SAMPLE_PHASE(SAMPLE_PHASE)
	) u_uart_rx (
	.clk    (clk),
	.i_reset(reset),
	.i_rx        (tx),
	.o_data      (o_data),
	.o_data_valid(o_dv)
	);


initial begin
	tb_state <= START;
	reset <= '0;
	i_dv <= '0;
	i_data <= '0;

	@(posedge clk) reset <= '1;
	@(posedge clk) reset <= '0;

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

endmodule : testbench