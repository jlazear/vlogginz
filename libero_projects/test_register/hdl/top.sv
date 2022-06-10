module top (
	input clk,    // Clock

	// uart
	input i_rx,
	output o_tx,

	// controls
	input [1:0] i_buttons,

	// leds
	output [7:0] o_leds
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

	logic [WORD_WIDTH*REG_WIDTH-1 : 0] mem [REG_DEPTH-1 : 0];
	// logic [WORD_WIDTH*REG_WIDTH-1 : 0] mem_ro [REG_DEPTH_RO-1 : 0];
	logic o_reset, o_mdc;

	top_wombat_command_parser #(
		.WORD_WIDTH        (WORD_WIDTH),
		.DIVISOR           (DIVISOR),
		.SAMPLE_PHASE      (SAMPLE_PHASE),
		.FIFO_DEPTH        (FIFO_DEPTH),
		.FIFO_LEVEL        (FIFO_LEVEL),
		.REG_DEPTH         (REG_DEPTH),
		.REG_WIDTH         (REG_WIDTH),
		.UART_LITTLE_ENDIAN(UART_LITTLE_ENDIAN),
		.LITTLE_ENDIAN     (LITTLE_ENDIAN)
		) u_wombat (
		.clk    (clk),
		.i_reset('0),
		.i_rx   (i_rx),
		.o_tx   (o_tx),
		.o_mem  (mem),
		.i_mem_ro	('0),
		.i_wro_en	('0),
		.i_buttons	(i_buttons),
		.o_cmux_out	(o_leds),
		.o_reset	(o_reset)
		);


	vsc8541_smi_mdc_gen #(
		.DIVISOR(MDC_DIVISOR)
		) u_mdc_gen (
		.clk    (clk),
		.i_reset(o_reset),
		.o_mdc  (o_mdc)
		);

	

endmodule

