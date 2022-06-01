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
logic tx, w_en, r_en, busy, dv, r_valid, o_dv;
logic [WIDTH-1 : 0] data, w_addr, r_addr, temp_addr, o_data, temp_data;
logic [4*WIDTH-1 : 0] w_data, r_data;
logic [23:0] lfsr;
initial lfsr <= '0;
always @(posedge clk) lfsr <= {lfsr[22:0], ~lfsr[23]};

enum {START, COMMAND, ADDRESS, VALUE, DONE} tb_state;
localparam [7:0] READ_CMD = 8'h00, WRITE_CMD = 8'hAA;
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
	// serial lines
	.i_rx    (rx),
	.o_tx     (tx),
	// memory write signals
	.o_w_en  (w_en),
	.o_w_addr(w_addr),
	.o_w_data(w_data),
	// memory read signals
	.o_r_addr(r_addr),
	.o_r_en  (r_en),
	.i_r_data (r_data),
	.i_r_valid(r_valid));

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
		.o_r_value(r_data),
		.o_r_valid(r_valid)
	);

uart_tx #( 
	.WIDTH  (WIDTH),
	.DIVISOR(DIVISOR)
	) u_uart_tx (
	.clk    (clk),
	.i_reset(reset),
	.i_data (data),
	.i_dv   (dv),
	.o_tx   (rx),
	.o_busy (busy)
	);

uart_rx #(
	.WIDTH       (WIDTH),
	.DIVISOR     (DIVISOR),
	.SAMPLE_PHASE(DIVISOR/2)
	) u_uart_rx (
	.clk         (clk),
	.i_reset     (reset),
	.i_rx        (tx),
	.o_data      (o_data),
	.o_data_valid(o_dv)
	);

task send_command(input [7:0] cmd, input [7:0] addr, input [31:0] value);
	begin
			// command
			@(posedge txclk);
			tb_state <= COMMAND;
			data <= cmd;
			dv <= '1;
			@(posedge txclk);
			dv <= '0;

			repeat(10)
				@(posedge txclk);			// address

			@(posedge txclk);
			tb_state <= ADDRESS;
			data <= addr;
			dv <= '1;
			@(posedge txclk);
			dv <= '0;

			repeat(10)
				@(posedge txclk);

			// value
			tb_state <= VALUE;
			@(posedge txclk);
			data <= value[31:24];
			dv <= '1;
			@(posedge txclk);
			dv <= '0;

			repeat(10)
				@(posedge txclk);

			@(posedge txclk);
			data <= value[23:16];
			dv <= '1;
			@(posedge txclk);
			dv <= '0;

			repeat(10)
				@(posedge txclk);

			@(posedge txclk);
			data <= value[15:8];
			dv <= '1;
			@(posedge txclk);
			dv <= '0;

			repeat(10)
				@(posedge txclk);

			@(posedge txclk);
			data <= value[7:0];
			dv <= '1;
			@(posedge txclk);
			dv <= '0;

			repeat(10)
				@(posedge txclk);

	end
endtask : send_command


initial begin
	tb_state <= START;
	reset <= '0;
	r_en <= '0;
	r_addr <= '0;
	temp_addr <= '0;


	@(posedge clk) reset <= '1;
	@(posedge clk) reset <= '0;

	// fill the buffer
	for (int i=0; i<=2**WIDTH; i++) begin
		temp_data <= i;
		send_command(WRITE_CMD, temp_addr, {lfsr, temp_data});
		@(posedge txclk) temp_addr <= temp_addr + 1'b1;
	end

	repeat(10)
		@(posedge txclk);

	// read register
	send_command(READ_CMD, 8'hbb, '0);


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