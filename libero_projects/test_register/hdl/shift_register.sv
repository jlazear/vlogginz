module shift_register #(
	parameter WIDTH=8,
	parameter FILL_MSB_TO_LSB=1  // 1 = data enters from MSB (left) and shifts toward LSB (right)
	) (
	input clk,    // Clock
	input i_reset,
	input i_in,
	output [WIDTH-1 : 0] o_out
);

	logic [WIDTH-1 : 0] mem;

	always @(posedge clk) begin
		if (i_reset) begin
			mem <= '0;
		end else begin
			mem <= FILL_MSB_TO_LSB ? {i_in, mem[WIDTH-1 : 1]} : {mem[WIDTH-2 : 0], i_in};
		end
	end

	assign o_out = mem;

endmodule