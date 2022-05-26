`timescale 1ns/1ns

module testbench_command_parser_uart;

localparam period = 1000;  // 1 MHz clock
localparam BAUDRATE = 115200;  // Hz
localparam DIVISOR = 10**9/(BAUDRATE * period);  // unitless, uart dclk divisor
localparam SAMPLE_PHASE = DIVISOR/2;  // sample phase in number of samples
localparam WIDTH = 8;  // word width in bits
localparam VALUE_WORDS = 4;
localparam N_SAMPLES = 1024;  // number of samples to send in test
localparam VERBOSE = 1;
localparam TXPERIOD = 10**9/BAUDRATE; // period*DIVISOR; // 
localparam TXPHASE = TXPERIOD * 1/4;

logic clk, reset, txclk;
logic tx, w_en, r_en, busy, dv;
logic [WIDTH-1 : 0] data, w_addr, r_addr, temp_addr;
logic [4*WIDTH-1 : 0] w_data, r_data;

enum {START, COMMAND, ADDRESS, VALUE, DONE} tb_state;
logic [$clog2(WIDTH):0] txcnt;


command_parser_uart #(
	.WORD_WIDTH        (WIDTH),
	.VALUE_WORDS       (VALUE_WORDS),
	.PULSE_W_EN_MAX_LEN(1),
	.DIVISOR           (DIVISOR),
	.SAMPLE_PHASE      (SAMPLE_PHASE)
	) dut (
	.clk     (clk),
	.i_reset (reset),
	.i_rx    (tx),
	.o_w_addr(w_addr),
	.o_w_data(w_data),
	.o_w_en  (w_en));

register_block #(
		.WIDTH(4*WIDTH),
		.DEPTH(2**WIDTH)
	) u_register_block (
		.clk      (clk),
		.reset    (reset),
		.i_w_en   (w_en),
		.i_w_addr (w_addr),
		.i_w_value(w_data),
		.i_r_en   (r_en),
		.i_r_addr (r_addr),
		.o_r_value(r_data)
	);

uart_tx #( 
	.WIDTH  (WIDTH),
	.DIVISOR(DIVISOR)
	) u_uart_tx (
	.clk    (clk),
	.i_reset(reset),
	.i_data (data),
	.i_dv   (dv),
	.o_tx   (tx),
	.o_busy (busy)
	);

task write_value(input logic [WIDTH-1 : 0] addr, input logic [4*WIDTH-1 : 0] value);
	begin
		@(posedge txclk);
		// send command
		@(posedge txclk);
		tb_state <= COMMAND;
		data <= 'h01;
		dv <= '1;
		@(posedge txclk)
		dv <= '0;

		repeat(WIDTH)
			@(posedge txclk)

		// send addr
		@(posedge txclk);
		tb_state <= ADDRESS;
		data <= addr;
		dv <= '1;
		@(posedge txclk)
		dv <= '0;

		repeat(WIDTH)
			@(posedge txclk)

		// send value
		@(posedge txclk);
		tb_state <= VALUE;
		data <= value[31:24];  // byte 1
		dv <= '1;
		@(posedge txclk)
		dv <= '0;

		repeat(WIDTH)
			@(posedge txclk)

		@(posedge txclk);
		data <= value[23:16];  // byte 2
		dv <= '1;
		@(posedge txclk)
		dv <= '0;

		repeat(WIDTH)
			@(posedge txclk)

		@(posedge txclk);
		data <= value[15:8];  // byte 3
		dv <= '1;
		@(posedge txclk)
		dv <= '0;

		repeat(WIDTH)
			@(posedge txclk)

		@(posedge txclk);
		data <= value[7:0];  // byte 4
		dv <= '1;
		@(posedge txclk)
		dv <= '0;

		repeat(WIDTH)
			@(posedge txclk);
		@(posedge txclk);
	end
endtask : write_value

initial begin
	tb_state <= START;
	reset <= '0;
	r_en <= '0;
	r_addr <= '0;
	temp_addr <= '0;


	@(posedge clk) reset <= '1;
	@(posedge clk) reset <= '0;

	for (int i=0; i<=2**WIDTH; i++) begin
		write_value(.addr(temp_addr), .value(32'hbbb00b00));
		@(posedge txclk) temp_addr <= temp_addr + 1'b1;
	end

	// // send command
	// @(posedge txclk);
	// tb_state <= COMMAND;
	// data <= 'h01;
	// dv <= '1;
	// @(posedge txclk)
	// dv <= '0;

	// repeat(WIDTH)
	// 	@(posedge txclk)

	// // send addr
	// @(posedge txclk);
	// tb_state <= ADDRESS;
	// data <= 'h12;
	// dv <= '1;
	// @(posedge txclk)
	// dv <= '0;

	// repeat(WIDTH)
	// 	@(posedge txclk)

	// // send value
	// @(posedge txclk);
	// tb_state <= ADDRESS;
	// data <= 'h34;  // byte 1
	// dv <= '1;
	// @(posedge txclk)
	// dv <= '0;

	// repeat(WIDTH)
	// 	@(posedge txclk)

	// @(posedge txclk);
	// data <= 'h56;  // byte 2
	// dv <= '1;
	// @(posedge txclk)
	// dv <= '0;

	// repeat(WIDTH)
	// 	@(posedge txclk)

	// @(posedge txclk);
	// data <= 'h78;  // byte 3
	// dv <= '1;
	// @(posedge txclk)
	// dv <= '0;

	// repeat(WIDTH)
	// 	@(posedge txclk)

	// @(posedge txclk);
	// data <= 'h9a;  // byte 4
	// dv <= '1;
	// @(posedge txclk)
	// dv <= '0;

	// repeat(WIDTH)
	// 	@(posedge txclk)


	tb_state <= DONE;
	repeat(20)
		@(posedge txclk)

	repeat(10)
		@(posedge txclk);
	#(10*period) $stop;
end

// clk block
initial begin
	clk <= '1;
	forever #(period/2) clk <= ~clk;
end

// txclk block
initial begin
	txclk <= '1;
	txcnt <= '0;
	#(TXPHASE);
	forever #(TXPERIOD/2) txclk <= ~txclk;
end

always @(posedge txclk)
		txcnt <= (txcnt < 9) ? txcnt + 1'b1 : '0;

endmodule : testbench_command_parser_uart