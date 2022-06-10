module top (
	input clk,    // Clock

	// uart
	input i_rx,
	output o_tx,

	// controls
	input [1:0] i_buttons,

	// leds
	output [7:0] o_leds,

	// vsc8541 mdio
	output o_mdc,
	inout io_mdio
);

	localparam WORD_WIDTH = 8;
	localparam DIVISOR = 434;  // suitable for 50 MHz clk and 115200 baud
	localparam SAMPLE_PHASE = 217;
	localparam FIFO_DEPTH = 128;
	localparam FIFO_LEVEL = 16;
	localparam REG_DEPTH = 16;
	localparam REG_WIDTH = 4;  // in words
	localparam UART_LITTLE_ENDIAN = 1;
	localparam LITTLE_ENDIAN = 0;
	localparam REG_DEPTH_RO = 16;
	localparam MDC_DIVISOR = 50;

	// COMMAND PARSER PROTOTYPES
	logic w_en, r_en, r_valid, wro_en;
	logic [WORD_WIDTH-1:0] w_addr, r_addr;
	logic [WORD_WIDTH*REG_WIDTH-1:0] w_data, r_data;
	logic [WORD_WIDTH*REG_WIDTH-1 : 0] mem [REG_DEPTH-1 : 0];
	logic [WORD_WIDTH*REG_WIDTH-1 : 0] mem_ro [REG_DEPTH_RO-1 : 0];
	logic reset;  // #DELME debug
	logic [WORD_WIDTH-1:0] cmux_out; // #DELME debug


	// vsc8541 SMI PROTOTYPES
	logic o_reset;
	logic mdio_en;


	// vsc8541 SMI
	// addr 4 - bit 0 - mode (1 = write, 0 = read)
	// addr 4 - bits 5:1 - phy addr (5-bit)
	// addr 4 - bits 10:6 - reg addr (5-bit)
	// addr 4 - bits 26:11 - input data (16-bit)
	// addr 5 - bit 0 - smio enable (pulse 1 to initiate transaction)
	// addr 16 - bits 0:15 - SMIO response
	vsc8541_smi_mdc_gen #(
		.DIVISOR(MDC_DIVISOR)
		) u_mdc_gen (
		.clk    (clk),
		.i_reset(o_reset),
		.o_mdc  (o_mdc)
		);

	localparam MDC_CNT_WIDTH = 23;
	logic [MDC_CNT_WIDTH-1:0] mdc_cnt;
	logic mdc_rollover, mdio_o_dv;
	logic [15:0] mdio_o_data;
	counter #(
		.WIDTH         (MDC_CNT_WIDTH),
		.MAX_VALUE     (2**MDC_CNT_WIDTH - 1)
		) u_counter_mdc (
		.clk     (o_mdc),
		.reset   (reset),
		.enable  ('1),
		.cnt     (mdc_cnt),
		.rollover(mdc_rollover)
		);

	pulse #(
		.WIDTH(1)
		) u_smio_pulse (
		.clk    (clk),
		.i_reset(reset),
		.i_x    (mem_ro[5][0]),
		.o_x    (mdio_en)
		);

	vsc8541_smi_mdio u_smi_mdio (
		.clk       (clk),
		.i_reset   (reset),
		.i_mdc     (o_mdc),
		.i_mode    (mem[4][0]),
		.i_en      (mdio_en),
		.i_phy_addr(mem[4][5:1]),
		.i_reg_addr(mem[4][10:6]),
		.i_data    (mem[4][26:11]),
		.o_dv      (mdio_o_dv),
		.o_data    (mdio_o_data),
		.io_mdio   (io_mdio)
		);

	assign mem_ro[0][15:0] = mdio_o_data;
	assign wro_en = mdio_o_dv;

	// COMMAND PARSER
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
		.i_mem_ro (mem_ro),
		.i_wro_en (wro_en)
	);


// addr0: bit0 -- enable
// addr1: bits 7:0 -- mux select
//						-- 0 = normal counter
//						-- 1 = gray counter

	localparam COUNTER_WIDTH = 29; // $clog2(10*50*1000000);
	logic [COUNTER_WIDTH-1 : 0] cnt;

	localparam N_STATES = 4;
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
	assign mux_input[3] = mdc_cnt[MDC_CNT_WIDTH-1 -: 8];

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

	assign o_leds = ~mux_output;

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

