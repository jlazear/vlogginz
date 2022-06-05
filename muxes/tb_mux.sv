`timescale 1ns/1ns


module tb_mux;

localparam period = 10;
localparam WIDTH = 8;
localparam N_STATES = 4;

logic clk;
logic [WIDTH-1:0] values [N_STATES-1:0];
logic [WIDTH-1:0] o_value;
logic [1:0] select;

mux #(
	.WIDTH   (WIDTH),
	.N_STATES(N_STATES)
	) dut (
	.clk     (clk),
	.i_x     (values),
	.o_x     (o_value), 
	.i_select(select)
	);

initial begin
	values[0] <= '0;
	values[1] <= '1;
	values[2] <= 8'haa;
	values[3] <= 8'h23;

	select = '0;

	@(posedge clk) select <= '0;
	@(posedge clk) select <= 2'h1;
	@(posedge clk) select <= 2'h2;
	@(posedge clk) select <= 2'h3;
	@(posedge clk);

	$stop;
end


initial begin
	clk <= 0;
	forever #(period/2) clk <= !clk;
end

endmodule : tb_mux