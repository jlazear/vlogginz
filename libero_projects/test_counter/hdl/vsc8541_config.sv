module vsc8541_config (
	input clk,    // Clock
	input i_reset,
	output o_rx_clk,
	output o_rx_d4,
	output o_rx_d5,
	output o_nreset
);

	enum {RESET, IDLE} state, next_state;

	always_comb begin
		unique case (state)
			RESET: next_state = IDLE;
			IDLE: next_state = IDLE;		
		endcase
	end

	always_ff @(posedge clk) begin
		if(i_reset) begin
			state <= RESET;
		end else begin
			state <= next_state;
		end
	end

	assign o_nreset = !(state == RESET);
	assign o_rx_clk = '1;
	assign o_rx_d4 = '0;
	assign o_rx_d5 = '0;

endmodule