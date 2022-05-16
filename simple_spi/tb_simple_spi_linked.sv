`timescale 1ns/1ns

module testbench_linked;

localparam period = 10;
localparam divisor = 6;

logic clk, reset, load_enable, sclk, mosi, ov_master, cs, ov_slave;
logic slave_cs_error;
logic [7:0] data_in, data_out;
logic [7:0] temp;

logic [7:0] master_values [$];
logic [7:0] slave_values [$];

enum {CONTINUOUS, CS} test_id;

always #(period/2) clk <= ~clk;


simple_spi_master #(.DIVISOR(6)) dutmaster (clk, reset, data_in, load_enable, sclk, mosi, ov_master);
simple_spi_slave dutslave (sclk, reset, mosi, cs, data_out, ov_slave, slave_cs_error);


// checking continuous loading
initial begin
	clk <= '1;
	reset <= '0;
	load_enable <= '0;
	data_in <= '0;
	cs <= '1;


	#10 @(posedge clk) reset <= 1;
	#10 @(posedge clk) reset <= 0;

	$display("testing continuous transfer...");
	test_id = CONTINUOUS;
	load_enable = '1;
	temp = $urandom();
	master_values.push_back(temp);
	data_in <= temp;

	#(40*divisor);

	for (int i=0; i < 9; i++) begin
		temp = $urandom();
		master_values.push_back(temp);
		@(posedge clk)
		data_in <= temp;
		#(80*divisor);
	end

	load_enable = '0;
	#(100*divisor);

	$display("%p", master_values);
	$display("%p", slave_values);
	assert(master_values == slave_values) begin
		$display("============");
		$display("    continuous transfer PASSED");
		$display("============");
	end else begin
		$display("============");
		$display("    continuous transfer FAILED");
		$display("============");
	end

	#10 @(posedge clk) reset <= 1;
	#10 @(posedge clk) reset <= 0;

	#(20*divisor);

	$display("testing cs continuous transfer...");
	test_id = CS;
	master_values = {};
	slave_values = {};
	cs <= '1;

	load_enable = '1;
	temp = $urandom();
	master_values.push_back(temp);
	data_in <= temp;

	#(40*divisor);

	for (int i=0; i < 9; i++) begin
		if (i >= 4)
			cs <= '0;
		temp = $urandom();
		master_values.push_back(temp);
		@(posedge clk)
		data_in <= temp;
		#(80*divisor);
	end

	load_enable = '0;
	#(100*divisor);

	$display("%p", master_values);
	$display("%p", slave_values);
	assert(master_values != slave_values && master_values[0:3] == slave_values) begin
		$display("============");
		$display("    cs continuous transfer PASSED");
		$display("============");
	end else begin
		$display("============");
		$display("    cs continuous transfer FAILED");
		$display("============");
	end

	#10 @(posedge clk) reset <= 1;
	#10 @(posedge clk) reset <= 0;

	$stop;
end

always @(posedge ov_slave) begin
	slave_values.push_back(data_out);
end

endmodule : testbench_linked

