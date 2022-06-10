module top_wombat_command_parser #(
	parameter WORD_WIDTH = 8,
	parameter DIVISOR = 434,  // suitable for 50 MHz clk and 115200 baud
	parameter SAMPLE_PHASE = 217,
	parameter FIFO_DEPTH = 128,
	parameter FIFO_LEVEL = 16,
	parameter REG_DEPTH = 16,
	parameter REG_WIDTH = 4,  // in words
	parameter UART_LITTLE_ENDIAN = 1,
	parameter LITTLE_ENDIAN = 0,
	parameter REG_DEPTH_RO = 16
	) (
	input clk,    // Clock
	input i_reset,
	input i_rx,
	output o_tx,
	output [WORD_WIDTH*REG_WIDTH-1 : 0] o_mem [REG_DEPTH-1 : 0],
	input [WORD_WIDTH*REG_WIDTH-1 : 0] i_mem_ro [REG_DEPTH_RO-1 : 0],
	input i_wro_en,

	// #DELME debug
	input [1:0] i_buttons,
	output [7:0] o_cmux_out,
	output o_reset
);

	logic w_en, r_en, r_valid;
	logic [WORD_WIDTH-1:0] w_addr, r_addr;
	logic [WORD_WIDTH*REG_WIDTH-1:0] w_data, r_data;
	logic [WORD_WIDTH*REG_WIDTH-1 : 0] mem [REG_DEPTH-1 : 0];
	logic reset;  // #DELME debug
	logic [WORD_WIDTH-1:0] cmux_out; // #DELME debug

	wombat_command_parser_uart #(
		.WORD_WIDTH        (WORD_WIDTH),
		.DIVISOR           (DIVISOR),
		.SAMPLE_PHASE      (SAMPLE_PHASE),
		.FIFO_DEPTH        (FIFO_DEPTH),
		.FIFO_LEVEL        (FIFO_LEVEL),
		.REG_DEPTH         (REG_DEPTH),
		.REG_WIDTH         (REG_WIDTH),
		.UART_LITTLE_ENDIAN(UART_LITTLE_ENDIAN),
		.LITTLE_ENDIAN     (LITTLE_ENDIAN)
		) u_command_parser_uart (
		.clk      (clk),
		.i_reset  (reset),
		.i_rx     (i_rx),
		.o_tx     (o_tx),
		.o_w_en   (w_en),
		.o_w_addr (w_addr),
		.o_w_value (w_data),
		.o_r_en   (r_en),
		.o_r_addr (r_addr),
		.i_r_value (r_data),
		.i_r_valid(r_valid)
		);

	register_block_w_ro #(
		.WIDTH(REG_WIDTH*WORD_WIDTH),
		.DEPTH(REG_DEPTH),
		.DEPTH_RO(REG_DEPTH_RO)
	) u_register_block (
		.clk      (clk    ),
		.reset    (reset),
		.i_w_en   (w_en   ),
		.i_w_addr (w_addr ),
		.i_w_value(w_data ),
		.i_r_en   (r_en   ),
		.i_r_addr (r_addr ),
		.o_r_value(r_data ),
		.o_r_valid(r_valid),
		.o_mem(mem),
		.i_mem_ro (i_mem_ro),
		.i_wro_en (i_wro_en)
	);

	assign o_mem = mem;

// addr0: bit0 -- enable
// addr1: bits 7:0 -- mux select
//						-- 0 = normal counter
//						-- 1 = gray counter

	localparam COUNTER_WIDTH = 29; // $clog2(10*50*1000000);
	logic [COUNTER_WIDTH-1 : 0] cnt;

	localparam N_STATES = 3;
	logic [WORD_WIDTH-1 : 0] mux_input [N_STATES-1 : 0];
	logic [WORD_WIDTH-1 : 0] mux_output;

	logic counter_en, rollover;
	assign counter_en = ~mem[0][0];

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
	assign mux_input[2] = ~cmux_out;

	mux #(
		.WIDTH   (WORD_WIDTH),
		.N_STATES(N_STATES)
		) u_mux (
		.i_x     (mux_input),
		.i_select(mux_select),
		.o_x     (mux_output)
		);


	// #DELME debug
	localparam CMUX_N_STATES = 3;
	logic [WORD_WIDTH-1:0] i_cmux_in [CMUX_N_STATES-1:0];
	logic [1:0] o_buttons;
	debug #(
		.WIDTH             (WORD_WIDTH),
		.CMUX_N_STATES     (CMUX_N_STATES),
		.DEADZONE_WIDTH    (1024),
		.MUX_DEADZONE_WIDTH(1024*1024*50)
		) u_debug (
		.clk       (clk),
		.i_reset   (reset),
		.i_buttons (i_buttons),
		.o_buttons (o_buttons),
		.i_cmux_in (i_cmux_in),
		.o_cmux_out(cmux_out),
		.o_reset   (reset)
		);

	assign o_reset = reset;
	assign o_cmux_out = ~mux_output;

	// #DELME debug
	// driving active-low LEDs
	assign i_cmux_in[0] = ~8'b10100011;  // reference state, LDLDDDLL on board
	assign i_cmux_in[1] = ~8'b11000101;  // reference state, LLDDDLDL on board
	assign i_cmux_in[2] = ~{w_en, w_en, r_en, r_en, r_valid, r_valid, r_valid, r_valid};


	// assign i_cmux_in[3] = ~w_addr;
	// assign i_cmux_in[4] = ~w_data[3 * WORD_WIDTH +: WORD_WIDTH];
	// assign i_cmux_in[5] = ~w_data[2 * WORD_WIDTH +: WORD_WIDTH];
	// assign i_cmux_in[6] = ~w_data[1 * WORD_WIDTH +: WORD_WIDTH];
	// assign i_cmux_in[7] = ~w_data[0 * WORD_WIDTH +: WORD_WIDTH];
	// assign i_cmux_in[8] = ~r_addr;
	// assign i_cmux_in[9] = ~r_data[3 * WORD_WIDTH +: WORD_WIDTH];
	// assign i_cmux_in[10] = ~r_data[2 * WORD_WIDTH +: WORD_WIDTH];
	// assign i_cmux_in[11] = ~r_data[1 * WORD_WIDTH +: WORD_WIDTH];
	// assign i_cmux_in[12] = ~r_data[0 * WORD_WIDTH +: WORD_WIDTH];

endmodule