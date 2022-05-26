module pulse_extender #(
	parameter WIDTH=2
	) (
	input clk,    // Clock
	input i_reset,
	input i_x,
	output o_x
);

	logic [$clog2(WIDTH)-1 : 0] cnt;

	enum {IDLE, PULSE} state, next_state;

	always_comb begin
		unique case (state)
			IDLE: next_state = i_x ? PULSE : IDLE;
			PULSE: next_state = (cnt >= WIDTH - 1) ? IDLE : PULSE;
		endcase
	end

	always_ff @(posedge clk)
		if (i_reset)
			state <= IDLE;
		else
			state <= next_state;

	always_ff @(posedge clk) begin
		cnt <= '0;
		if (state == PULSE) begin
			cnt <= cnt + 1'b1;
		end
	end

	assign o_x = (state == PULSE);

endmodule