`timescale 1ns/1ns

module testbench;

parameter period = 10;

logic clk, reset, load_enable, sclk, mosi, ov;
logic [7:0] data;

logic reset16, load_enable16, sclk16, mosi16, ov16;
logic [15:0] data16;

logic reset_d6, load_enable_d6, sclk_d6, mosi_d6, ov_d6;
logic [7:0] data_d6;

logic reset_c, load_enable_c, sclk_c, mosi_c, ov_c;
logic [7:0] data_c, temp;
logic [7:0] data_values [$];
logic [7:0] mosi_buffer [$];
logic [7:0] mosi_value;
logic [7:0] mosi_byte_read;



// logic [31:0] buffer;

// int c_fd, i;
// logic _discard;
// int n_errors = 0;

simple_spi_master dut (clk, reset, data, load_enable, sclk, mosi, ov);
simple_spi_master #(.WIDTH(16)) dut16 (clk, reset16, data16, load_enable16, sclk16, mosi16, ov16);
simple_spi_master #(.DIVISOR(6)) dut_d6 (clk, reset_d6, data_d6, load_enable_d6, sclk_d6, mosi_d6, ov_d6);
simple_spi_master dut_c (clk, reset_c, data_c, load_enable_c, sclk_c, mosi_c, ov_c);

// some timing checks
initial begin
	clk = 1;
	reset = 0;
	load_enable = 0;
	data = 0;
	// buffer = '0;

	#10 @(posedge clk) reset = 1;
	#10 @(posedge clk) reset = 0;


	#40 @(posedge clk);
	load_enable <= 1;
	data <= 8'ha3;
	#10 @(posedge clk);
	data <= 8'hff;
	#90 @(posedge clk)
	data <= 8'hee;

	#10 @(posedge clk)
	load_enable <= 0;
	
	#150;
	#60 @(posedge clk)
	load_enable <= 1;
	data <= 8'h88;

	#10 @(posedge clk)
	load_enable <= 0;

	#190;
	// $stop;
end

// cursory checking 16-bit wide
initial begin
	reset16 <= 0;
	load_enable16 <= 0;
	data16 <= 0;

	#10 @(posedge clk) reset16 <= 1;
	#10 @(posedge clk) reset16 <= 0;


	#40 @(posedge clk);
	load_enable16 <= 1;
	data16 <= 16'ha3a3;
	#10 @(posedge clk);
	data16 <= 16'hffff;

	#100 @(posedge clk)
	load_enable16 <= 0;
	#150;
end

// cursory checking 6 divisor
initial begin
	reset_d6 <= 0;
	load_enable_d6 <= 0;
	data_d6 <= 0;

	#10 @(posedge clk) reset_d6 <= 1;
	#10 @(posedge clk) reset_d6 <= 0;


	#40 @(posedge clk);
	load_enable_d6 <= 1;
	data_d6 <= 8'ha3;
	#10 @(posedge clk);
	data_d6 <= 8'hff;

	#100 @(posedge clk)
	load_enable_d6 <= 0;
	#150;
end

// checking continuous loading
initial begin
	reset_c <= '0;
	load_enable_c <= '0;
	data_c <= '0;
	mosi_value <= 'x;

	#10 @(posedge clk) reset_c <= 1;
	#10 @(posedge clk) reset_c <= 0;

	load_enable_c = '1;
	temp = $urandom();
	data_values.push_back(temp);
	data_c <= temp;

	#80;

	for (int i=0; i < 9; i++) begin
		temp = $urandom();
		data_values.push_back(temp);
		@(posedge clk)
		data_c <= temp;
		#160;
	end

	load_enable_c = '0;
	#200;
	$display("%p", data_values);
	$display("%p", mosi_buffer);
	assert(data_values == mosi_buffer) begin
		$display("============");
		$display("    continuous transfer PASSED");
		$display("============");
	end else begin
		$display("============");
		$display("    continuous transfer FAILED");
		$display("============");
	end
	$stop;
end

int j = 0;
always @(posedge sclk_c) begin
	if (ov_c) begin
		mosi_value <= {mosi_value[6:0], mosi_c};
		j <= j + 1;
		if (j >= 7) begin
			mosi_buffer.push_back({mosi_value[6:0], mosi_c});
			mosi_value <= 'x;
			mosi_byte_read <= {mosi_value[6:0], mosi_c};
			j <= 0;
		end
	end
end

always #(period/2) clk <= ~clk;

endmodule : testbench