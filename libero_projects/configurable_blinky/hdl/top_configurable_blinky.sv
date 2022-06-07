// addr0: bit0 -- enable
// addr1: bits 7:0 -- mux select
//						-- 0 = normal counter
//						-- 1 = gray counter

module top_configurable_blinky #(
	parameter WORD_WIDTH = 8,
	parameter DIVISOR = 434,  // suitable for 50 MHz clk and 115200 baud
	parameter SAMPLE_PHASE = 217,
	parameter FIFO_DEPTH = 128,
	parameter FIFO_LEVEL = 16,
	parameter REG_DEPTH = 16,
	parameter REG_WIDTH = 4,  // in words
	parameter UART_LITTLE_ENDIAN = 1,
	parameter LITTLE_ENDIAN = 0
	) (
	input clk,    // Clock
	input [1:0] i_buttons,
	input i_rx,
	output o_tx,
	output [WORD_WIDTH-1 : 0] o_leds
);

	logic reset;
	assign reset = &i_buttons;

	logic [WORD_WIDTH*REG_WIDTH-1 : 0] mem [REG_DEPTH-1 : 0];

	top_wombat_command_parser #(
		.WORD_WIDTH        (WORD_WIDTH        ),
		.DIVISOR           (DIVISOR           ),
		.SAMPLE_PHASE      (SAMPLE_PHASE      ),
		.FIFO_DEPTH        (FIFO_DEPTH        ),
		.FIFO_LEVEL        (FIFO_LEVEL        ),
		.REG_DEPTH         (REG_DEPTH         ),
		.REG_WIDTH         (REG_WIDTH         ),
		.UART_LITTLE_ENDIAN(UART_LITTLE_ENDIAN),
		.LITTLE_ENDIAN     (LITTLE_ENDIAN     )
	) u_wombat (
		.clk    (clk  ),
		.i_reset(reset),
		.i_rx   (i_rx ),
		.o_tx   (o_tx ),
		.o_mem  (mem  )
	);


	localparam COUNTER_WIDTH = 29; // $clog2(10*50*1000000);
	logic [COUNTER_WIDTH-1 : 0] cnt;

	localparam N_STATES = 2;
	logic [WORD_WIDTH-1 : 0] mux_input [N_STATES-1 : 0];
	logic [WORD_WIDTH-1 : 0] mux_output;

	logic counter_en, rollover;
	assign counter_en = mem[0][0];

	logic [$clog2(N_STATES)-1 : 0] mux_select;
	assign mux_select = mem[1][$clog2(N_STATES)-1 : 0];

	counter #(
		.WIDTH         (COUNTER_WIDTH),
		.MAX_VALUE     (2**COUNTER_WIDTH - 1)
		) u_counter (
		.clk     (clk),
		.reset   (reset),
		.enable  (counter_en),
		.cnt     (cnt),
		.rollover(rollover)
		);

	logic [WORD_WIDTH-1 : 0] gray_cnt; 
	gray #(
		.WIDTH(WORD_WIDTH)
		) u_gray (
		.in (cnt[COUNTER_WIDTH-1 -: WORD_WIDTH]),
		.out(gray_cnt)
		);


	assign mux_input[0] = cnt[COUNTER_WIDTH-1 -: WORD_WIDTH];
	assign mux_input[1] = gray_cnt;

	mux #(
		.WIDTH   (WORD_WIDTH),
		.N_STATES(N_STATES)
		) u_mux (
		.i_x     (mux_input),
		.i_select(mux_select),
		.o_x     (mux_output)
		);

	assign o_leds = ~mux_output;

endmodule : top_configurable_blinky