module counter_n
	#(parameter WIDTH=32)
	(
	input clk,    // Clock
	input reset,  
	input enable,
	output [WIDTH-1 : 0] cnt,
	output rollover
);

	logic [WIDTH-1 : 0] _cnt;
	logic _rollover;

	always @(posedge clk)
		if (reset) begin
			_cnt <= '0;
			_rollover <= '0;
		end else if (enable) begin
			_rollover <= (_cnt == 2**WIDTH - 1);
			_cnt <= (_cnt == 2**WIDTH - 1) ? 0 : _cnt + 1'b1;
		end else
			_rollover <= _rollover;
			_cnt <= _cnt;

	assign cnt = _cnt;
	assign rollover = _rollover;
endmodule


module counter_2n
	#(parameter WIDTH=64)
	(
		input clk,
		input reset,
		input enable,
		input rollover_mode,
		output [WIDTH-1 : 0] cnt,
		output rollover // indicates rollover or saturate
		);

	logic [WIDTH-1 : 0] _cnt;
	logic [WIDTH/2 - 1 : 0] _cnt_low, _cnt_high;
	logic _rollover, _low_rollover, _enable;

	always @(*) begin
		if (rollover_mode)
			_enable = enable;
		else
			_enable = enable && (cnt < 2**WIDTH - 1);
	end

	counter_n #(.WIDTH(WIDTH/2)) c_low (clk, reset, enable, _cnt_low, _low_rollover);
	counter_n #(.WIDTH(WIDTH/2)) c_high (clk, reset, _low_rollover, _cnt_high, _rollover);

	assign cnt = {_cnt_high, _cnt_low};
	always @@ begin
		if (rollover_mode)
			rollover = _rollover;
		else
			rollover = (cnt == 2**WIDTH - 1);
	end
endmodule
