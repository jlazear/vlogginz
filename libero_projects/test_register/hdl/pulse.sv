module pulse #(
	WIDTH = 1
	) (
	input clk,    // Clock
	input i_reset, 
	input i_x,
	output o_x
);

	enum {IDLE, PULSE} state, next_state;
	logic [$clog2(WIDTH+1) : 0] cnt;
	logic prev_x;
	logic [1:0] edge_x;

	assign edge_x = {prev_x, i_x};

	always_comb
		unique case (state)
			IDLE: next_state = i_x ? PULSE : IDLE;
			PULSE: next_state = (edge_x == 2'b10) ? IDLE : PULSE;	
		endcase

	always_ff @(posedge clk)
		if (i_reset)
			state <= IDLE;
		else
			state <= next_state;

	always_ff @(posedge clk) begin
		cnt <= '0;
		prev_x <= i_x;
		if (i_reset) begin
			prev_x <= '0;
		end else if (state == PULSE) begin
			cnt <= (cnt >= WIDTH) ? cnt : cnt + 1'b1;
		end
	end

	assign o_x = (state == PULSE && cnt < WIDTH);

endmodule