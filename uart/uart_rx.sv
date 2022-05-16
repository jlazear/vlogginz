`ifndef UART_RX
	`define UART_RX 1

`include "../counter/counter.sv"
`include "../synchronizer/synchronizer.sv"

module uart_rx
	#(
		WIDTH=8,
		DIVISOR=100,
		SAMPLE_PHASE=49)
	(
	input clk,
	input i_reset,
	input i_rx, 
	output [WIDTH-1:0] o_data,
	output o_data_valid
);

	localparam DCLK_SUBCNT_WIDTH = $clog2(DIVISOR);

	logic [WIDTH:0] mem;
	logic [WIDTH-1:0] data;
	logic [DCLK_SUBCNT_WIDTH-1 : 0] dclk_subcnt;
	logic [$clog2(WIDTH) : 0] s_cnt;
	logic sync_rx, dclk_ro, dclk, s, sampling, sampled, start_bit, end_bit;
	wire _x;  // discard wire
	enum {DESYNCED, SENDING, WAITING} state, next_state;

	assign sampling = (dclk_subcnt == SAMPLE_PHASE);

	// synchronize input
	synchronizer #(.SYNC_HIGH(1)) q_sync (clk, i_reset, i_rx, sync_rx);
	
	// clock divider to generate dclk
	counter #(
		.WIDTH    (DCLK_SUBCNT_WIDTH),
		.MAX_VALUE(DIVISOR-1        )
	) q_dclk_counter (
		.clk     (clk        ),
		.reset   (i_reset      ),
		.enable  ('1         ),
		.cnt     (dclk_subcnt),
		.rollover(dclk_ro    )
	);

	assign dclk = (dclk_subcnt < DIVISOR>>1);

	// sampler
	always @(posedge clk) begin
		sampled <= '0;
		if (i_reset)
			s <= '1;
		else if (sampling) begin
			s <= sync_rx;
			sampled <= '1;
		end else
			s <= s;
	end

	// sample counter
	counter #(
		.WIDTH         ($clog2(WIDTH)+1),
		.MAX_VALUE     (WIDTH))
	q_sample_counter (
		.clk     (clk),
		.reset   (state != WAITING),
		.enable  (state == WAITING && sampling),
		.cnt     (s_cnt),
		.rollover(_x));

	// memory handler
	always @(posedge clk) begin
		data <= data;
		mem <= mem;
		if (i_reset) begin
			mem <= '1;
			data <= '0;
		end else if (sampling) begin
			mem <= {mem[WIDTH-1 : 0], s};
		end else if (sampled) begin
			if (next_state == SENDING)  // >:(
				data <= mem[WIDTH-1 : 0];
		end
	end
	
	assign start_bit = mem[WIDTH];
	assign end_bit = s;

	// state machine
	always @*
		unique case (state)
			DESYNCED: next_state <= (~start_bit && end_bit) ? SENDING : DESYNCED;
			SENDING: next_state <= WAITING;
			WAITING: begin
				if (s_cnt < WIDTH)
					next_state <= WAITING;
				else
					next_state <= (~start_bit && end_bit) ? SENDING : DESYNCED;
			end
		endcase

	always @(posedge clk) begin
		if (i_reset)
			state <= DESYNCED;
		else if (sampled)
			state <= next_state;
		else
			state <= state;
	end

	// outputs
	assign o_data = o_data_valid ? data : '0;
	assign o_data_valid = (state == SENDING);

endmodule : uart_rx

`endif