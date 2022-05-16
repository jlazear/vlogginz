module counter 
	#(parameter WIDTH=8,
		parameter RESET_VALUE=0,
		parameter MAX_VALUE=255,
		parameter ROLLOVER_VALUE=0)
	(input clk,    // Clock
	input reset,  // synchronous reset
	input enable, // count while enabled
	output [WIDTH-1 : 0] cnt,  // output bus
	output rollover            // rollover flag (high when MAX_VALUE)
);

	assign rollover = enable & (cnt >= MAX_VALUE);
	reg [WIDTH-1 : 0] _cnt;

	always @(posedge clk) begin : proc_cnt
		if(reset)
			_cnt <= RESET_VALUE;
		else if (enable)
			_cnt <= rollover ? ROLLOVER_VALUE : _cnt + 1'b1;
		else
			_cnt <= _cnt;
	end

	assign cnt = _cnt;

endmodule