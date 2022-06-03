`timescale 1ns/1ns

module testbench;

localparam period = 10;
localparam WIDTH = 8;
localparam CMUX_N_STATES = 4;
localparam DEADZONE_WIDTH = 3;
localparam MUX_DEADZONE_WIDTH = 5;



logic clk, reset, o_reset;
logic [1:0] i_buttons, o_buttons;
logic [WIDTH-1:0] i_cmux_in [CMUX_N_STATES-1:0];
logic [WIDTH-1:0] o_cmux_out;
enum {START, RESET, MUX, DONE} tb_state;


debug #(
	.WIDTH             (WIDTH),
	.CMUX_N_STATES     (CMUX_N_STATES),
	.DEADZONE_WIDTH    (DEADZONE_WIDTH),
	.MUX_DEADZONE_WIDTH(MUX_DEADZONE_WIDTH)
	) dut (
	.clk       (clk),
	.i_reset   (reset),
	.i_buttons (i_buttons),
	.o_buttons (o_buttons),
	.i_cmux_in (i_cmux_in),
	.o_cmux_out(o_cmux_out),
	.o_reset   (o_reset)
	);

initial begin
	tb_state <= START;
	reset <= '0;
	i_buttons <= '0;
	i_cmux_in[0] <= 8'h00;
	i_cmux_in[1] <= 8'h11;
	i_cmux_in[2] <= 8'h22;
	i_cmux_in[3] <= 8'h33;
	@(posedge clk);

	@(posedge clk) reset <= '1;
	@(posedge clk) reset <= '0;

	@(posedge clk);
	tb_state <= RESET;
	i_buttons <= '1;

	repeat(5)
		@(posedge clk);
	i_buttons <= '0;

	repeat(50)
		@(posedge clk);


	@(posedge clk);
	tb_state <= MUX;
	i_buttons[1] <= '1;
	@(posedge clk);
	i_buttons[1] <= '0;

	repeat(50)
		@(posedge clk);

	i_buttons[1] <= '1;
	@(posedge clk);
	i_buttons[1] <= '0;

	repeat(50)
		@(posedge clk);
	i_buttons[1] <= '1;
	@(posedge clk);
	i_buttons[1] <= '0;

	repeat(50)
		@(posedge clk);
	i_buttons[1] <= '1;
	@(posedge clk);
	i_buttons[1] <= '0;

	repeat(50)
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