`timescale 1ns/1ns

module testbench_vsc8541_register;

localparam period = 10;

logic clk, reset, read_en, dv;
wire mdio, mdc;
logic [14:0] data;
logic [4:0] register;
enum {START, DONE} tb_state;


vsc8541_register dut (
	.clk       (clk),
	.i_reset   (reset),
	.i_register(register),
	.i_read_en (read_en),
	.o_data    (data),
	.o_dv      (dv),
	.io_mdio   (mdio),
	.o_mdc     (mdc));

initial begin
	tb_state <= START;
	reset <= '0;
	read_en <= '0;
	register <= '0;

	@(posedge clk) reset <= '1;
	@(posedge clk) reset <= '0;

	repeat(10)
		@(posedge clk);

	@(posedge clk);
	register <= '1;
	read_en <= '1;

	@(posedge clk);
	@(posedge clk);
	register <= '0;
	read_en <= '0;

	repeat(60)
		@(posedge clk);


	tb_state <= DONE;
	#(10*period) $stop;
end

// clk block
initial begin
	clk <= '1;
	forever #(period/2) clk <= ~clk;
end

endmodule : testbench_vsc8541_register