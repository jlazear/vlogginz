`timescale 1ns/1ns

module testbench;

localparam period = 10;
localparam WIDTH = 16;
localparam DEPTH = 16;

logic clk, reset;
logic w_en, r_en;
logic [$clog2(DEPTH)-1 : 0] w_addr, r_addr;
logic [WIDTH-1 : 0] w_value, r_value;
logic [WIDTH-1 : 0] temp;
logic [WIDTH-1 : 0] w_values [$];
logic [WIDTH-1 : 0] r_values [$];

enum {START, WRITE, READ, DONE} tb_state;

register_block #(
	.WIDTH(WIDTH),
	.DEPTH(DEPTH))
dut
	(clk,
	reset,
	w_en,
	w_addr,
	w_value,
	r_en,
	r_addr,
	r_value);

initial begin
	tb_state <= START;
	reset <= '0;

	@(posedge clk) reset <= '1;
	@(posedge clk) reset <= '0;

	// test writing
	tb_state <= WRITE;
	for (int i=0; i < DEPTH; i++) begin
		@(posedge clk);
		temp = $urandom();
		w_values.push_back(temp);
		w_value <= temp;
		w_en <= '1;
		w_addr <= i;
	end
	@(posedge clk);
	w_en <= '0;
	@(posedge clk);


	// test reading
	tb_state <= READ;
	@(posedge clk);
	r_en <= '1;
	r_addr <= '0;
	@(posedge clk);
	for (int i=1; i < DEPTH; i++) begin
		r_en <= '1;
		r_addr <= i;
		@(posedge clk);
		r_values.push_back(r_value);
	end
	r_en <= '0;
	@(posedge clk);
	r_values.push_back(r_value);
	@(posedge clk);

	$display("write values = %p", w_values);
	$display("read values = %p", r_values);
	assert (w_values == r_values) begin
		$display("============");
		$display("    tests PASSED");
		$display("============");
	end else begin
		$display("============");
		$display("    tests FAILED");
		$display("============");
	end

	// done
	tb_state <= DONE;
	#(10*period);
	$stop;
end

initial begin
	clk <= '1;
	forever #(period/2) clk <= ~clk;
end

endmodule : testbench