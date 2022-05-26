`timescale 1ns/1ns

module testbench;

localparam period = 10;

logic clk, reset;
logic [7:0] data, w_addr;
logic [31:0] w_data;
logic dv, w_en;
enum {START, CMD, ADDR, VALUE, DONE} tb_state;


command_controller #(.PULSE_W_EN_MAX_LEN(1)) dut (
	.clk     (clk),
	.i_reset (reset),
	.i_data  (data),
	.i_dv    (dv),
	.o_w_addr(w_addr),
	.o_w_data(w_data),
	.o_w_en  (w_en));

initial begin
	tb_state <= START;
	reset <= '0;
	data <= '0;
	dv <= '0;

	@(posedge clk) reset <= '1;
	@(posedge clk) reset <= '0;

	// command
	@(posedge clk);
	tb_state <= CMD;
	data <= 8'h01;
	dv <= '1;
	@(posedge clk);
	dv <= '0;

	repeat(10)
		@(posedge clk);

	// address
	@(posedge clk);
	tb_state <= ADDR;
	data <= 8'h12;
	dv <= '1;
	@(posedge clk);
	dv <= '0;

	repeat(10)
		@(posedge clk);

	// value
	tb_state <= VALUE;
	@(posedge clk);
	data <= 8'h01;
	dv <= '1;
	@(posedge clk);
	dv <= '0;

	repeat(10)
		@(posedge clk);

	@(posedge clk);
	data <= 8'h23;
	dv <= '1;
	@(posedge clk);
	dv <= '0;

	repeat(10)
		@(posedge clk);

	@(posedge clk);
	data <= 8'h34;
	dv <= '1;
	@(posedge clk);
	dv <= '0;

	repeat(10)
		@(posedge clk);

	@(posedge clk);
	data <= 8'h56;
	dv <= '1;
	@(posedge clk);
	dv <= '0;

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