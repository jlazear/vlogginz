`timescale 1us/100ns

module testbench;

localparam real period = 1;

logic clk, reset, tx, enable;
logic [7:0] data;
enum {START, DONE} tb_state;


top_module dut (
	.clk(clk),
	.i_reset (reset),
	.i_enable(!enable),
	.o_data  (data),
	.o_tx    (tx));

initial begin
	tb_state <= START;
	reset <= '0;
	enable <= '0;

	@(posedge clk) reset <= '1;
	@(posedge clk) reset <= '0;
	enable <= '1;

	repeat (1000000) begin
		@(posedge clk);
	end

	tb_state <= DONE;
	#(10*period) $stop;
end

// clk block
initial begin
	clk <= '1;
	forever #(period/2) clk <= ~clk;
end

endmodule : testbench