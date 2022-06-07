`timescale 1ns/1ns

module testbench_wombat_command_parser;

localparam period       = 20                          ; // 50 MHz clock
localparam BAUDRATE     = 115200                      ; // Hz
localparam DIVISOR      = 10**9/(BAUDRATE * period); // unitless, uart dclk divisor
localparam SAMPLE_PHASE = DIVISOR/2                   ; // sample phase in number of samples
localparam WIDTH        = 8                           ; // word width in bits
localparam REG_WIDTH    = 4                           ;
localparam REG_DEPTH    = 16                          ;
localparam N_SAMPLES    = 1024                        ; // number of samples to send in test
localparam VERBOSE      = 1                           ;
localparam TXPERIOD     = period*DIVISOR; //
localparam TXPHASE      = TXPERIOD * 1/4              ;

logic clk, i_reset, txclk;
logic tx, rx, i_w_en;

logic [7:0] o_leds;
logic [1:0] i_buttons;

logic [WIDTH-1 : 0] i_w_data, o_data;
logic full, afull, empty, aempty, o_dv;

enum {START, COMMAND, ADDRESS, VALUE, DONE} tb_state;
localparam [7:0] READ_CMD = 8'h72, WRITE_CMD = 8'h77;


top_configurable_blinky #(
	) dut (
	.clk     (clk),
	
	// serial lines
	.i_rx    (rx),
	.o_tx     (tx),
	
	// buttons/leds
	.i_buttons(i_buttons),
	.o_leds   (o_leds)
	);

fifo_uart #(
	.WIDTH        (WIDTH),
	.DIVISOR      (DIVISOR),
	.LITTLE_ENDIAN(1),
	.DEPTH        (16),
	.LEVEL        (2)
	) u_ext_uart_tx (
	.clk          (clk),
	.o_tx         (rx),
	.i_reset      (i_reset),
	.i_w_en       (i_w_en),
	.i_w_data     (i_w_data)
	.o_full       (full),
	.o_afull      (afull),
	.o_empty      (empty),
	.o_aempty     (aempty),
	.i_tx_enable  ('1),
	.i_fifo_enable('1)
	);

uart_rx #(
	.WIDTH        (WIDTH),
	.DIVISOR      (DIVISOR),
	.LITTLE_ENDIAN(1),
	.SAMPLE_PHASE (SAMPLE_PHASE)
	) u_ext_uart_rx (
	.clk         (clk),
	.i_reset     (i_reset),
	.i_rx        (tx),
	.o_data      (o_data),
	.o_data_valid(o_dv)
	);

task send_command(input [7:0] cmd, input [7:0] addr, input [31:0] value);
	begin
			// command
			@(posedge txclk);
			tb_state <= COMMAND;
			i_w_data <= cmd;
			i_w_en <= '1;
			@(posedge txclk);
			i_w_en <= '0;

			repeat(10)
				@(posedge txclk);			// address

			@(posedge txclk);
			tb_state <= ADDRESS;
			i_w_data <= addr;
			i_w_en <= '1;
			@(posedge txclk);
			i_w_en <= '0;

			repeat(10)
				@(posedge txclk);

			// value
			tb_state <= VALUE;
			@(posedge txclk);
			i_w_data <= value[31:24];
			i_w_en <= '1;
			@(posedge txclk);
			i_w_en <= '0;

			repeat(10)
				@(posedge txclk);

			@(posedge txclk);
			i_w_data <= value[23:16];
			i_w_en <= '1;
			@(posedge txclk);
			i_w_en <= '0;

			repeat(10)
				@(posedge txclk);

			@(posedge txclk);
			i_w_data <= value[15:8];
			i_w_en <= '1;
			@(posedge txclk);
			i_w_en <= '0;

			repeat(10)
				@(posedge txclk);

			@(posedge txclk);
			i_w_data <= value[7:0];
			i_w_en <= '1;
			@(posedge txclk);
			i_w_en <= '0;

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
	for (int i=0; i<=REG_DEPTH; i++) begin
		temp_data <= i;
		send_command(WRITE_CMD, temp_addr, {lfsr, temp_data});
		@(posedge txclk) temp_addr <= temp_addr + 1'b1;
	end

	repeat(10)
		@(posedge txclk);

	// read register
	send_command(READ_CMD, 8'h0a, '0);


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

endmodule : testbench_wombat_command_parser