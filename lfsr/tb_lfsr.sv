`timescale 1ns/1ns
`define TAPS_MASK 'h6
`define WIDTH $clog2(`TAPS_MASK)
`define MAX_ITER 1000
`define VERBOSE 1

module testbench;

logic clk, reset;
logic [`WIDTH - 1:0] data;
logic [`WIDTH - 1:0] values [$];

lfsr #(
	.WIDTH(`WIDTH    ),
	.TAPS (`TAPS_MASK)
) dut (
	clk,
	reset,
	data
);


initial begin
	clk = 0;
	reset = 0;
	data = '0;
end

always #5 clk = ~clk;


initial begin
	#10 reset = 1;
	#10 reset = 0;

	$display("TAPS = 0b%0b", `TAPS_MASK);
	$display ("WIDTH = %0d", `WIDTH);
	for(int i=0; i<`MAX_ITER; i++) begin
		if (`VERBOSE) $display("[display] i=%d, data1=0b%b (%h)", i, data, data);
		if (values[0] == data) begin
			$display("CYCLE COMPLETE AFTER %0d ITERATIONS", i+1);
			$display("PERIOD = %0d", values.size());
			$display("values = %p", values);
			$finish;
		end else
			values.push_back(data);
		#10;
	end

	$display("FAILED TO CYCLE AFTER %0d ITERATIONS", `MAX_ITER);
	$finish;
end

endmodule : testbench