`timescale 1ns/1ns

module testbench_serializer;

localparam period = 10;

logic clk, reset;
logic i_dv, o_dv_le, o_dv_be;
logic [31:0] i_data;
logic [7:0] o_data_le, o_data_be;
enum {START, DONE} tb_state;


serializer #(
	.WIDTH        (8),
	.NUM_WORDS    (4),
	.LITTLE_ENDIAN(1)
	) dut_le (
	.clk   (clk),
	.i_reset(reset),
	.i_data (i_data),
	.i_dv   (i_dv),
	.o_data (o_data_le),
	.o_dv   (o_dv_le));

serializer #(
	.WIDTH        (8),
	.NUM_WORDS    (4),
	.LITTLE_ENDIAN(0)
	) dut_be (
	.clk   (clk),
	.i_reset(reset),
	.i_data (i_data),
	.i_dv   (i_dv),
	.o_data (o_data_be),
	.o_dv   (o_dv_be));


initial begin
	tb_state <= START;
	reset <= '0;
	i_dv <= '0;

	@(posedge clk) reset <= '1;
	@(posedge clk) reset <= '0;

	@(posedge clk);
	i_data <= 32'h12345678;
	i_dv <= '1;

	@(posedge clk);
	i_dv <= '0;

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

endmodule : testbench_serializer