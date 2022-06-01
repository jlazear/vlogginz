module serializer #( 
	parameter WIDTH = 8,
	parameter NUM_WORDS = 4,
	parameter LITTLE_ENDIAN = 1  // LE = shift out LSW first, BE shift out MSW first
	)(
	input clk,    // Clock
	input i_reset,
	input [NUM_WORDS*WIDTH - 1 : 0] i_data,
	input i_dv,
	output [WIDTH-1 : 0] o_data,
	output o_dv
);

	logic [$clog2(NUM_WORDS) : 0] cnt;
	logic [NUM_WORDS*WIDTH - 1 : 0] data;
	logic prev_dv;
	logic [1:0] dv_edge;

	assign dv_edge = {prev_dv, i_dv};

	always_ff @(posedge clk) begin
		prev_dv <= i_dv;
		cnt <= (cnt == '0) ? cnt : cnt - 1'b1;
		data <= LITTLE_ENDIAN ? data >> WIDTH : data << WIDTH;
		if (i_reset) begin
			prev_dv <= '0;
			data <= '0;
			cnt <= '0;
		end else if (dv_edge == 2'b01) begin
			cnt <= NUM_WORDS;
			data <= i_data;
		end
	end

	assign o_data = LITTLE_ENDIAN ? data[WIDTH-1 : 0] : data[NUM_WORDS*WIDTH-1 : (NUM_WORDS-1)*WIDTH];
	assign o_dv = (cnt > '0);

endmodule