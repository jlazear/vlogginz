`ifndef REGISTER_BLOCK
	`define REGISTER_BLOCK 1

module register_block 
	#(
		parameter WIDTH=16,
		parameter DEPTH=32
		)
	(
	input clk,    // Clock
	input reset,  // likely remove for real systems...
	input i_w_en,
	input [$clog2(DEPTH)-1 : 0] i_w_addr,
	input [WIDTH-1 : 0] i_w_value,
	input i_r_en,
	input [$clog2(DEPTH)-1 : 0] i_r_addr,
	output [WIDTH-1 : 0] o_r_value,
	output o_r_valid,
	output [WIDTH-1 : 0] o_mem [DEPTH-1 : 0]
);

	logic [WIDTH-1 : 0] mem [DEPTH-1 : 0];
	logic [WIDTH-1 : 0] read_value;
	logic r_valid;

	always @(posedge clk)
		if (reset) begin
			for (int i=0; i < DEPTH; i++) begin
				mem[i] <= '0;
			end
			mem[0] <= 'hb00;
		end else
			mem <= mem;

	// read circuit
	always @(posedge clk) begin
		r_valid <= '0;
		if (reset) begin
			read_value <= '0;
		end else if (i_r_en) begin
			read_value <= mem[i_r_addr];
			r_valid <= '1;
		end else
			read_value <= read_value;
	end

	// write circuit
	always @(posedge clk) begin
		if (!reset && i_w_en) begin
			mem[i_w_addr] <= i_w_value;
			if (i_w_addr == 0) 
				mem[i_w_addr] <= 'hb00;
		end
	end

	assign o_r_value = read_value;
	assign o_r_valid = r_valid;
	assign o_mem = mem;

endmodule

`endif