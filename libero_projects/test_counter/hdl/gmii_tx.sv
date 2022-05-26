module gmii_tx (
	input clk,    // Clock
	input i_reset,
	input i_dv,
	input [7:0] i_data,
	output [7:0] o_txd,
	output o_tx_en
);

	enum {IDLE, VALUE} state, next_state;
	logic [7:0] txd;
	logic tx_en;

	always_comb begin
		unique case (state)
			IDLE: next_state = i_dv ? VALUE : IDLE;
			VALUE: next_state =  i_dv ? VALUE : IDLE;
		endcase
	end

	always_ff @(posedge clk) begin
		if (i_reset)
			state <= IDLE;
		else
			state <= next_state;
	end

	always_ff @(posedge clk) begin
		txd <= '0;
		tx_en <= '0;
		if (i_reset) begin
			txd <= '0;
		end else if (state == VALUE) begin
			tx_en <= '1;
			txd <= i_data;
		end
	end

	assign o_txd = txd;
	assign o_tx_en = tx_en;


endmodule