module counter 
	#(parameter WIDTH=8,
		parameter RESET_VALUE=0,
		parameter MAX_VALUE=255,
		parameter ROLLOVER_VALUE=0)
	(input clk,    // Clock
	input reset,  // synchronous reset
	input enable, // count while enabled
	output [WIDTH-1 : 0] cnt,  // output bus
	output rollover            // rollover flag (high on next clock after MAX_VALUE)
);

	logic [WIDTH-1 : 0] _cnt;
	logic _rollover;

	always @(posedge clk) begin
		if (reset) begin
			_cnt <= RESET_VALUE;
			_rollover <= 0;
		end else if (enable) begin
			_cnt <= (_cnt >= MAX_VALUE) ? ROLLOVER_VALUE : _cnt + 1'b1;
			_rollover <= (_cnt >= MAX_VALUE);
		end else begin
			_cnt <= _cnt;
			_rollover <= _rollover;
		end
	end

	assign cnt = _cnt;
	assign rollover = _rollover;

endmodule