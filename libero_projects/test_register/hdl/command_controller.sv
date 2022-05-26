module command_controller #(
	parameter WORD_WIDTH = 8,
	parameter VALUE_WORDS = 4,
	parameter PULSE_W_EN_MAX_LEN = 1
	) (
	input clk,    // Clock
	input i_reset,
	input [WORD_WIDTH-1 : 0] i_data,
	input i_dv,
	output [WORD_WIDTH - 1 : 0] o_w_addr,
	output [VALUE_WORDS*WORD_WIDTH - 1 : 0] o_w_data,
	output o_w_en
);

	logic [WORD_WIDTH - 1 : 0] cmd, w_addr;
	logic [VALUE_WORDS*WORD_WIDTH - 1 : 0] w_data;

	enum {RESET, PARSE_CMD, PARSE_ADDR, PARSE_VALUE, WRITE} state, next_state;
	logic prev_dv, loaded, w_en;
	logic [1:0] dv_edge;
	localparam [1:0] LOW=2'b00, HIGH=2'b11, RISING=2'b01, FALLING=2'b10;

	logic [$clog2(VALUE_WORDS) : 0] value_cnt;
	logic [$clog2(PULSE_W_EN_MAX_LEN+1) : 0] w_en_cnt;

	assign dv_edge = {prev_dv, i_dv};


	always_comb
		unique case (state)
			RESET: next_state = (dv_edge == RISING) ? PARSE_CMD : RESET;
			PARSE_CMD: next_state = (dv_edge == FALLING) ? PARSE_ADDR : PARSE_CMD;
			PARSE_ADDR: next_state = (dv_edge == FALLING) ? PARSE_VALUE : PARSE_ADDR;
			PARSE_VALUE: next_state = (dv_edge == FALLING && value_cnt >= VALUE_WORDS) ? WRITE : PARSE_VALUE;
			WRITE: next_state = (!i_dv && w_en_cnt >= PULSE_W_EN_MAX_LEN) ? RESET : WRITE;
		endcase

	always_ff @(posedge clk)
		if (i_reset)
			state <= RESET;
		else
			state <= next_state;

	always_ff @(posedge clk) begin
		value_cnt <= '0;
		cmd <= cmd;
		w_addr <= w_addr;
		w_data <= w_data;
		prev_dv <= i_dv;
		loaded <= loaded;
		w_en <= '0;
		w_en_cnt <= '0;
		if (i_reset) begin
			w_addr <= '0;
			w_data <= '0;
			cmd <= '0;
			prev_dv <= '0;
			loaded <= '0;
		end else if (state == PARSE_CMD) begin
			cmd <= loaded ? cmd : i_data;
			loaded <= '1;
			if (dv_edge == RISING) begin
				loaded <= '0;
			end
		end else if (state == PARSE_ADDR) begin
			w_addr <= loaded ? w_addr : i_data;
			loaded <= '1;
			if (dv_edge == RISING) begin
				loaded <= '0;
			end
		end else if (state == PARSE_VALUE) begin
			w_data <= loaded ? w_data : {w_data, i_data};
			value_cnt <= loaded ? value_cnt : value_cnt + 1'b1;
			loaded <= '1;
			if (dv_edge == RISING) begin
				loaded <= '0;
			end
		end else if (state == WRITE) begin
			w_en <= (w_en_cnt < PULSE_W_EN_MAX_LEN);
			w_en_cnt <= (w_en_cnt < PULSE_W_EN_MAX_LEN) ? w_en_cnt + 1'b1 : w_en_cnt;
		end
	end

	assign o_w_addr = w_addr;
	assign o_w_data = w_data;
	assign o_w_en = w_en;

endmodule