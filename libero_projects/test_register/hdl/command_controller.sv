/* format:
	CAVV[...V]

	where each char corresponds to `WORD_WIDTH` bits, C = command, A = address, and V=value.
	Each of C and A are one word wide. V will be `VALUE_WORDS` words (default 4) wide. 

	command table:
		0x72 = 'r' = read
		0x77 = 'w' = write
*/
module command_controller #(
	parameter WORD_WIDTH = 8,
	parameter VALUE_WORDS = 4
	) (
	input clk,    // Clock
	input i_reset,
	input [(VALUE_WORDS + 2)*WORD_WIDTH-1 : 0] i_data,
	input i_dv,
	output o_w_en,
	output o_r_en,
	output [WORD_WIDTH-1:0] o_addr,
	output [WORD_WIDTH*VALUE_WORDS-1 : 0] o_value
);

	logic [WORD_WIDTH-1 : 0] cmd, addr;
	logic [VALUE_WORDS*WORD_WIDTH - 1 : 0] w_data;

	localparam [WORD_WIDTH-1 : 0] CMD_WRITE = 8'h77, CMD_READ = 8'h72;

	assign cmd = i_data[(VALUE_WORDS+1)*WORD_WIDTH +: WORD_WIDTH];
	assign addr = i_data[VALUE_WORDS*WORD_WIDTH +: WORD_WIDTH];
	assign w_data = i_data[0 +: VALUE_WORDS*WORD_WIDTH];


	enum {IDLE, WRITE, READ} state, next_state, cmd_state;
	logic            prev_dv, w_en, r_en;
	logic      [1:0] dv_edge                                                 ;
	localparam [1:0] LOW     = 2'b00, HIGH=2'b11, RISING=2'b01, FALLING=2'b10;

	assign dv_edge = {prev_dv, i_dv};

	always_comb begin
		if (cmd == CMD_WRITE) cmd_state = WRITE;
		else if (cmd == CMD_READ) cmd_state = READ;
		else cmd_state = IDLE;
	end

	always_comb
		unique case (state)
			IDLE: next_state = (dv_edge == RISING) ? cmd_state : IDLE;
			WRITE: next_state = (dv_edge == RISING) ? cmd_state : IDLE;
			READ: next_state = (dv_edge == RISING) ? cmd_state : IDLE;
			default: next_state = IDLE;
		endcase

	always_ff @(posedge clk)
		if (i_reset)
			state <= IDLE;
		else
			state <= next_state;

	always_ff @(posedge clk) begin
	 	prev_dv <= i_dv;	
	 	r_en <= '0;
	 	w_en <= '0;
		 if (i_reset) begin
		 	prev_dv <= '0;
		 end else if (state == WRITE) begin
		 	w_en <= '1;
		 end else if (state == READ) begin
		 	r_en <= '1;
		 end
	end

	assign o_r_en = r_en;
	assign o_w_en = w_en;
	assign o_addr = addr;
	assign o_value = w_data;
endmodule