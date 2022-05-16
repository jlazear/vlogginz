`ifndef FIFO
	`define FIFO 1

module fifo 
	#(parameter WORD_WIDTH=8,
		parameter DEPTH=128,
		parameter LEVEL=16)
	(
	input clk,    // Clock
	input reset,
	input i_w_en,   // write enable
	input [WORD_WIDTH-1 : 0] i_w_data, // data to write
	input i_r_en,   // read enable
	output [WORD_WIDTH-1 : 0] o_r_data, // data being read out
	output o_afull,     // almost full flag
	output o_full,      // full flag
	output o_aempty,    // almost empty flag
	output o_empty      // empty flag
);

	logic [WORD_WIDTH-1 : 0] mem [0:DEPTH-1];
	logic [WORD_WIDTH-1 : 0] out_data;
	logic [$clog2(DEPTH)-1 : 0] ptr1, ptr2, n_elem;
	logic first;  // flag on if we've written to first element in memory

	assign n_elem = (ptr2 >= ptr1) ? (ptr2 - ptr1) : (DEPTH - ptr1) + ptr2;
	assign full = (n_elem == 0) && first;
	assign empty = (n_elem == 0) && !first;
	assign almost_full = full || (n_elem >= DEPTH - LEVEL);
	assign almost_empty = empty || (n_elem <= LEVEL);

	always @(posedge clk) begin
		mem <= mem;
		ptr1 <= ptr1;
		ptr2 <= ptr2;
		first <= first;
		if (reset) begin
			ptr1 <= '0;
			ptr2 <= '0;
			first <= '0;
			out_data <= '0;
		end else begin
			if (i_w_en) begin
				if (!full || i_r_en) begin
					mem[ptr2] <= i_w_data;
					ptr2 <= (ptr2 >= DEPTH - 1) ? 0 : ptr2 + 1'b1;
					if (ptr2 == 0)
						first <= '1;
				end
			end
			if (i_r_en) begin
				if (!empty) begin
					out_data <= mem[ptr1];
					ptr1 <= (ptr1 >= DEPTH - 1) ? 0 : ptr1 + 1'b1;
					if (ptr1 == 0 && !i_w_en)  // need to check w_en so as not to stomp
						first <= '0;
				end
			end
		end
	end

	assign o_r_data = out_data;
	assign o_afull = almost_full;
	assign o_full = full;
	assign o_aempty = almost_empty;
	assign o_empty = empty;

endmodule

`endif
