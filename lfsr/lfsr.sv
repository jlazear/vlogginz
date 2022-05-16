module lfsr #(
	parameter         WIDTH = 4  ,
	parameter integer TAPS  = 'h6
) (
	input              clk  , // Clock
	input              reset, // reset
	output [WIDTH-1:0] data
);

	reg [WIDTH-1 : 0] _data;
	wire last;

	assign last = _data[0];

	always @(posedge clk)
		if (reset) begin
			_data <= 1'b1 << (WIDTH-1);
		end else begin
			_data[WIDTH-1] <= last;
			for (int i=0; i < WIDTH-1; i++)
				if ((TAPS >> i) & 1'b1)
					_data[i] <= _data[i+1] ^ last;
				else
					_data[i] <= _data[i+1];
			end

	assign data = _data;

endmodule