`ifndef UART_TX
	`define UART_TX 1

module uart_tx 
	#(
		WIDTH=8,
		DIVISOR=100)  // DIVISOR must be even
	(
	input clk,    // Clock
	input i_reset,
	input [WIDTH-1 : 0] i_data,
	input i_dv,
	output o_tx,
	output o_busy
);

	localparam DCLK_SUBCNT_WIDTH = $clog2(DIVISOR);

	logic [WIDTH-1:0] mem;
	logic [DCLK_SUBCNT_WIDTH-1 : 0] dclk_subcnt;
	logic [$clog2(WIDTH)-1 : 0] s_cnt;
	logic tx, dclk;
	wire _x;

	enum {IDLE, START, DATA, STOP} state, next_state;

	// clock divider to generate dclk
	counter #(
		.WIDTH    (DCLK_SUBCNT_WIDTH),
		.MAX_VALUE(DIVISOR-1        )
	) q_dclk_counter (
		.clk     (clk        ),
		.reset   (i_reset),
		.enable  ('1         ),
		.cnt     (dclk_subcnt),
		.rollover(_x    )
	);

	assign dclk = (dclk_subcnt < DIVISOR>>1);

	// memory handler
	always @(posedge clk) begin
		if (i_reset) begin
			mem <= '0;
		end else if (dclk_subcnt == DIVISOR>>1) begin
			if (state == IDLE || state == STOP) begin
				if (i_dv) mem <= i_data;
			end else if (state == DATA) begin
				mem <= mem >> 1;
			end
		end else
			mem <= mem;
	end

	// state machine
	always @*
		unique case (state)
			IDLE: next_state <= i_dv ? START : IDLE;
			START: next_state <= DATA;
			DATA: next_state <= (s_cnt >= WIDTH-1) ? STOP : DATA;
			STOP: next_state <= i_dv ? START : IDLE;
		endcase

	always @(posedge clk)
		if (i_reset)
			state <= IDLE;
		else if (dclk_subcnt == DIVISOR>>1)
			state <= next_state;
		else
			state <= state;

	always @(posedge clk) begin
		s_cnt <= '0;
		if (state == DATA)
			if (dclk_subcnt == DIVISOR>>1)
				s_cnt <= s_cnt + 1'b1;
			else
				s_cnt <= s_cnt;
	end

	// outputs
	always @* begin
		tx = '1;
		if (state == START)
			tx = '0;
		else if (state == DATA)
			tx = mem[0];
	end
	assign o_tx = tx;
	assign o_busy = (state == START || state == DATA);

endmodule

`endif