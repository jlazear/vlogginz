`timescale 1ns/1ns

module testbench_vsc_register_read;

localparam period = 10;

logic clk, reset;
logic tx, mdc, busy;
wire mdio;
enum {START, DONE} tb_state;


vsc_register_read #(
	.COUNTER_WIDTH(10))
dut (
	.clk       (clk),
	.i_reset   (reset),
	.i_reg_addr('0),
	.o_tx      (tx),
	.o_busy    (busy),
	.io_mdio   (mdio),
	.o_mdc     (mdc));

initial begin
	tb_state <= START;
	reset <= '0;

	@(posedge clk) reset <= '1;
	@(posedge clk) reset <= '0;


	repeat(10000)
		@(posedge clk);

	tb_state <= DONE;
	#(10*period) $stop;
end

// clk block
initial begin
	clk <= '1;
	forever #(period/2) clk <= ~clk;
end

endmodule : testbench_vsc_register_read