/* format:
	CAVV[...V]

	where each char corresponds to `WORD_WIDTH` bits, C = command, A = address, and V=value.
	Each of C and A are one word wide. V will be `VALUE_WORDS` words (default 4) wide. 

	command table:
		0x00 = read
		0xaa = write
*/
module command_controller #(
	parameter WORD_WIDTH = 8,
	parameter VALUE_WORDS = 4,
	parameter PULSE_W_EN_MAX_LEN = 1,
	parameter PULSE_R_EN_MAX_LEN = 1	
	) (
	input clk,    // Clock
	input i_reset,
	input [WORD_WIDTH-1 : 0] i_data,
	input i_dv,
	output [WORD_WIDTH - 1 : 0] o_w_addr,
	output [VALUE_WORDS*WORD_WIDTH - 1 : 0] o_w_data,
	output o_w_en,
	output [WORD_WIDTH - 1 : 0] o_r_addr,
	output o_r_en
);

	logic [WORD_WIDTH - 1 : 0] cmd, addr;
	logic [VALUE_WORDS*WORD_WIDTH - 1 : 0] w_data;

	enum {P_CMD, P_ADDR, P_VALUE, WRITE, READ, NOTIMPLEMENTED} state, next_state;
	logic prev_dv, loaded, w_en, r_en;
	logic [1:0] dv_edge;
	localparam [1:0] LOW=2'b00, HIGH=2'b11, RISING=2'b01, FALLING=2'b10;

	logic [$clog2(VALUE_WORDS) : 0] value_cnt;
	logic [$clog2(PULSE_W_EN_MAX_LEN+1) : 0] w_en_cnt;
	logic [$clog2(PULSE_R_EN_MAX_LEN+1) : 0] r_en_cnt;

	assign dv_edge = {prev_dv, i_dv};


	always_comb
		unique case (state)
			P_CMD: next_state = (dv_edge == FALLING) ? P_ADDR : P_CMD;
			P_ADDR: next_state = (dv_edge == FALLING) ? P_VALUE : P_ADDR;
			P_VALUE: begin 
							if (!i_dv && value_cnt >= VALUE_WORDS) begin
								if (cmd == '0) begin
									next_state = READ;
								end else if (cmd == 'haa) begin
									next_state = WRITE;
								end else begin
									next_state = NOTIMPLEMENTED;
								end
							end else begin
								next_state = P_VALUE;
							end
						end
			WRITE: next_state = (!i_dv && w_en_cnt >= PULSE_W_EN_MAX_LEN) ? P_CMD : WRITE;
			READ: next_state = (!i_dv && r_en_cnt >= PULSE_R_EN_MAX_LEN) ? P_CMD : READ;
			NOTIMPLEMENTED: next_state = P_CMD;
		endcase

	always_ff @(posedge clk)
		if (i_reset)
			state <= P_CMD;
		else
			state <= next_state;

	always_ff @(posedge clk) begin
		value_cnt <= '0;
		cmd <= cmd;
		addr <= addr;
		w_data <= w_data;
		prev_dv <= i_dv;
		loaded <= loaded;
		w_en <= '0;
		w_en_cnt <= '0;
		r_en <= '0;
		r_en_cnt <= '0;
		if (i_reset) begin
			addr <= '0;
			w_data <= '0;
			cmd <= 'h81;
			prev_dv <= '0;
			loaded <= '0;
		end else if (state == P_CMD) begin
			cmd <= loaded ? cmd : i_data;
			loaded <= '1;
			if (dv_edge == RISING) begin
				loaded <= '0;
			end
		end else if (state == P_ADDR) begin
			addr <= loaded ? addr : i_data;
			loaded <= '1;
			if (dv_edge == RISING) begin
				loaded <= '0;
			end
		end else if (state == P_VALUE) begin
			w_data <= loaded ? w_data : {w_data, i_data};
			value_cnt <= loaded ? value_cnt : value_cnt + 1'b1;
			loaded <= '1;
			if (dv_edge == RISING) begin
				loaded <= '0;
			end
		end else if (state == WRITE) begin
			w_en <= (w_en_cnt < PULSE_W_EN_MAX_LEN);
			w_en_cnt <= (w_en_cnt < PULSE_W_EN_MAX_LEN) ? w_en_cnt + 1'b1 : w_en_cnt;
		end else if (state == READ) begin
			r_en <= (r_en_cnt < PULSE_R_EN_MAX_LEN);
			r_en_cnt <= (r_en_cnt < PULSE_R_EN_MAX_LEN) ? r_en_cnt + 1'b1 : r_en_cnt;
		end
	end

	assign o_w_addr = addr;
	assign o_r_addr = addr;
	assign o_w_data = w_data;
	assign o_w_en = w_en;
	assign o_r_en = r_en;

endmodule