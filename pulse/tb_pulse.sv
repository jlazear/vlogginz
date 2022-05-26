`timescale 1ns/1ns

module testbench;

localparam period = 10;

logic clk, reset;
logic x, ox1, ox4;
enum {START, DONE} tb_state;


pulse #(.WIDTH(1)) dut1 (
	.clk    (clk),
	.i_reset(reset),
	.i_x    (x),
	.o_x    (ox1));

pulse #(.WIDTH(4)) dut4 (
	.clk    (clk),
	.i_reset(reset),
	.i_x    (x),
	.o_x    (ox4));


initial begin
	tb_state <= START;
	reset <= '0;
	x <= '0;

	@(posedge clk) reset <= '1;
	@(posedge clk) reset <= '0;

	@(posedge clk);
	x <= '1;

	repeat(10)
		@(posedge clk);

	x <= '0;

	repeat(5)
		@(posedge clk);

	x <= '1;

	repeat(10)
		@(posedge clk);

	x <= '0;

	@(posedge clk) x <= '1;
	@(posedge clk) x <= '0;

	repeat(10)
		@(posedge clk);

	tb_state <= DONE;
	#(10*period) $stop;
end

// clk block
initial begin
	clk <= '1;
	forever #(period/2) clk <= ~clk;
end

endmodule : testbench