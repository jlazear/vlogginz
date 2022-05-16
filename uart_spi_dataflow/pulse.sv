module pulse (
	input clk,    // Clock
	input reset, 
	input x,
	output y
);

	enum {WAIT, PULSE, DEAD} state, next_state;

	always_comb begin
		unique case (state)
			WAIT: next_state = x ? PULSE : WAIT;
			PULSE: next_state = DEAD;
			DEAD: next_state = x ? DEAD : WAIT;
		endcase
	end

	always @(posedge clk)
		if (reset)
			state <= WAIT;
		else
			state <= next_state;

	assign y = (state == PULSE);
endmodule