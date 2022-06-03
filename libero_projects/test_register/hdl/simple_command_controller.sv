/* format:
	CAVV[...V]

	where each char corresponds to `WORD_WIDTH` bits, C = command, A = address, and V=value.
	Each of C and A are one word wide. V will be `VALUE_WORDS` words (default 4) wide. 

	command table:
		0x00 = read
		0xaa = write
*/
module simple_command_controller #(
	parameter WORD_WIDTH = 8,
	parameter VALUE_WORDS = 4
	) (
	input clk,    // Clock
	input i_reset,
	input [(VALUE_WORDS + 2)*WORD_WIDTH-1 : 0] i_data,
	input i_dv,
	output [1:0] o_state,
	output o_w_en,
	output o_r_en,
	output [WORD_WIDTH-1:0] o_cmd,
	output [WORD_WIDTH-1:0] o_addr,
	output [WORD_WIDTH*VALUE_WORDS-1 : 0] o_value
) /* synthesis syn_preserve=1 syn_noprune=1 syn_keep=1 */ ;

	logic [1:0] cmd, addr, state_val;
	logic [VALUE_WORDS*WORD_WIDTH - 1 : 0] w_data;

	// localparam [WORD_WIDTH-1 : 0] CMD_READ = 8'haa, CMD_WRITE = 8'h00;  // #DELME #FIXME
	localparam [WORD_WIDTH-1 : 0] CMD_ON1 = 8'h01, CMD_ON2 = 8'h02, CMD_ON3 = 8'h03;  // #DELME original version

	assign cmd = i_data[(VALUE_WORDS+1)*WORD_WIDTH +: WORD_WIDTH];
	assign addr = i_data[VALUE_WORDS*WORD_WIDTH +: WORD_WIDTH];
	assign w_data = i_data[0 +: VALUE_WORDS*WORD_WIDTH];


	enum {OFF, ON1, ON2, ON3} state, next_state, cmd_state;
	logic prev_dv, w_en, r_en; /* synthesis syn_preserve = 1 */
	logic [1:0] dv_edge;
	localparam [1:0] LOW=2'b00, HIGH=2'b11, RISING=2'b01, FALLING=2'b10;

	assign dv_edge = {prev_dv, i_dv};

	always_comb begin
		if (cmd == CMD_ON1) cmd_state = ON1;
		else if (cmd == CMD_ON2) cmd_state = ON2;
		else if (cmd == CMD_ON3) cmd_state = ON3;
		else cmd_state = OFF;
	end
	always_comb
		case (state)
			OFF: next_state = (dv_edge == RISING) ? cmd_state : OFF;
			ON1: next_state = (dv_edge == RISING) ? cmd_state : OFF;
			ON2: next_state = (dv_edge == RISING) ? cmd_state : OFF;
			ON3: next_state = (dv_edge == RISING) ? cmd_state : OFF;
			default: next_state = OFF;
		endcase

	always_ff @(posedge clk)
		if (i_reset)
			state <= OFF;
		else
			state <= next_state;

	always_ff @(posedge clk) begin
	 	prev_dv <= i_dv;	
	 	state_val <= state_val;
	 	r_en <= '0;
	 	w_en <= '0;
		 if (i_reset) begin
		 	prev_dv <= '0;
		 end else if (state == ON1) begin
		 	w_en <= '1;
		 end else if (state == ON2) begin
		 	r_en <= '1;
		 end else if (state == ON3) begin
		 	r_en <= '1;
		 	w_en <= '1;
		 end
	end

	assign o_cmd = cmd;
	assign o_state = state_val;
	assign o_r_en = r_en;
	assign o_w_en = w_en;
	assign o_addr = addr;
	assign o_value = w_data;
endmodule