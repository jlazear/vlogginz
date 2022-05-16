`timescale 1ns/1ns

module testbench_synchronizer;

localparam period = 10;

logic clk, reset, x, y;
enum {START, DONE} tb_state;


synchronizer dut (clk, reset, x, y);

initial begin
	tb_state <= START;
	reset <= '0;
	x <= '0;

	@(posedge clk) reset <= '1;
	@(posedge clk) reset <= '0;

	@(posedge clk);
	@(posedge clk) x <= !x;
	@(posedge clk);
	@(posedge clk) x <= !x;
	@(posedge clk);
	@(posedge clk);
	@(posedge clk) x <= !x;
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk) x <= !x;

	tb_state <= DONE;
	#(10*period) $stop;
end

// clk block
initial begin
	clk <= '1;
	forever #(period/2) clk <= ~clk;
end

endmodule : testbench
