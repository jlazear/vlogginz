`timescale 1ns/1ns

module testbench_command_controller;

localparam period = 10;

logic clk, reset;
logic [7:0] addr;
logic [31:0] w_data;
logic [8*6 - 1 : 0] data;
logic dv, w_en, r_en;
enum {START, READ, WRITE, INTERMISSION, DONE} tb_state;
localparam [7:0] READ_CMD = 8'h72, WRITE_CMD = 8'h77;


command_controller #(
	.WORD_WIDTH (8),
	.VALUE_WORDS(4)
	) dut (
	.clk     (clk),
	.i_reset (reset),
	.i_data  (data),
	.i_dv    (dv),
	.o_w_en  (w_en),
	.o_r_en  (r_en),
	.o_addr  (addr),
	.o_value (w_data));

task send_command(input [7:0] cmd, input [7:0] addr, input [31:0] value);
	begin
		@(posedge clk);
		data <= {cmd, addr, value};
		dv <= '1;
		@(posedge clk)
		dv <= '0;
	end
endtask : send_command

initial begin
	tb_state <= START;
	reset <= '0;
	data <= '0;
	dv <= '0;

	@(posedge clk) reset <= '1;
	@(posedge clk) reset <= '0;

	tb_state <= READ;
	send_command(READ_CMD, 8'h12, 32'h12345678);

	tb_state <= INTERMISSION;
	repeat(20)
		@(posedge clk);

	tb_state <= WRITE;
	send_command(WRITE_CMD, 8'h21, 32'h87654321);

	tb_state <= DONE;

	repeat(20)
		@(posedge clk);


	#(10*period) $stop;
end

// clk block
initial begin
	clk <= '1;
	forever #(period/2) clk <= ~clk;
end

endmodule : testbench_command_controller