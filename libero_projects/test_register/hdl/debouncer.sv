module debouncer #(
	DEADZONE_WIDTH = 1024
	)(
	input clk,    // Clock
	input i_reset,
	input i_in,
	output o_out
);

	logic [$clog2(DEADZONE_WIDTH) : 0] cnt;
	enum {S_LOW, S_HIGH, S_RISING, S_FALLING} state, next_state;


	always_comb
		unique case (state)
			S_LOW: next_state = i_in ? S_RISING : S_LOW;
			S_HIGH: next_state = !i_in ? S_FALLING : S_HIGH;
			S_RISING: next_state = (cnt >= DEADZONE_WIDTH-2) ? S_HIGH : S_RISING;
			S_FALLING: next_state = (cnt >= DEADZONE_WIDTH-2) ? S_LOW : S_FALLING;
		endcase

	always_ff @(posedge clk)
		if (i_reset)
			state <= S_LOW;
		else
			state <= next_state;

	always_ff @(posedge clk) begin
		cnt <= '0;
		if (i_reset) begin
		end else if (state == S_RISING || state == S_FALLING) begin
			cnt <= cnt + 1'b1;
		end
	end

	assign o_out = (state == S_HIGH || state == S_RISING);

endmodule