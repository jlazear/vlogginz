`timescale 1ns/1ns

module testbench;

localparam period = 10;

logic clk, reset;
enum {START, DONE} tb_state;
logic x, y;

debouncer #(
	.DEADZONE_WIDTH(4)
	) dut (
	.clk  (clk),
	.i_reset(reset),
	.i_in (x),
	.o_out(y)
	);

initial begin
	tb_state <= START;
	reset <= '0;
	x <= '0;

	@(posedge clk) reset <= '1;
	@(posedge clk) reset <= '0;

	@(posedge clk) x <= '1;

	repeat(2)
		@(posedge clk);

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