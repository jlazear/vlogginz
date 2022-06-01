module deserializer #(
	parameter WIDTH = 8,
	parameter NUM_WORDS = 4,
	parameter LITTLE_ENDIAN = 1  // LE = shift in LSW first, BE shift in MSW first
	)(
	input clk,    // Clock
	input i_reset,
	input [WIDTH-1 : 0] i_data,
	input i_dv,
	output [NUM_WORDS*WIDTH - 1 : 0] o_data,
	output o_dv
);

	logic [$clog2(NUM_WORDS) : 0] cnt;
	logic [NUM_WORDS*WIDTH - 1 : 0] data;
	logic dv;

	always_ff @(posedge clk) begin
		cnt <= cnt;
		data <= data;
		dv <= '0;
		if (i_reset) begin
			data <= '0;
			cnt <= '0;
		end else if (i_dv) begin
			cnt <= (cnt >= NUM_WORDS-1) ? 0 : cnt + 1'b1;
			data <= LITTLE_ENDIAN ? {i_data, data[NUM_WORDS*WIDTH - 1 : WIDTH]} : {data[(NUM_WORDS-1)*WIDTH - 1 : 0], i_data};
			dv <= (cnt == NUM_WORDS-1);
		end
	end

	assign o_data = data;
	assign o_dv = dv;

endmodule