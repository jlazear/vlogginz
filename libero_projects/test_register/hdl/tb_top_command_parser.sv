`timescale 1ns/1ns

module testbench_top_command_parser;

localparam period = 20;  // 50 MHz clock
localparam DIVISOR = 434;
localparam SAMPLE_PHASE = DIVISOR/2;
localparam TXPERIOD = DIVISOR*period; // period*DIVISOR; // 
localparam TXPHASE = TXPERIOD * 1/4;

localparam [7:0] WRITE_CMD = 8'haa, READ_CMD = 8'h00;

logic clk, reset, txclk;
enum {START, WRITE, READ, DONE} tb_state;

logic rx, tx;  // driven

top_command_parser #(
	.DIVISOR     (DIVISOR),
	.SAMPLE_PHASE(SAMPLE_PHASE)
	) dut (
	.clk    (clk),
	.i_reset(reset),
	.i_rx   (rx),
	.o_tx   (tx));

logic [7:0] data; // driving
logic w_en;  // driving
logic full, afull, empty, aempty; // driven
fifo_uart #(
	.WIDTH  (8),
	.DEPTH  (16),
	.DIVISOR(DIVISOR),
	.LEVEL  (2)
	) u_fifo_uart (
	.clk          (clk),
	.i_reset      (reset),
	.i_fifo_enable('1),
	.i_tx_enable  ('1),
	.i_w_en       (w_en),
	.i_w_data     (data),
	.o_tx         (rx),
	.o_full       (full),
	.o_afull      (afull),
	.o_empty      (empty),
	.o_aempty     (aempty)
	);


logic [7:0] o_data; // driven
logic o_dv; // driven
uart_rx #(
	.WIDTH       (8),
	.DIVISOR     (DIVISOR),
	.SAMPLE_PHASE(SAMPLE_PHASE)
	) u_uart_rx (
	.clk         (clk),
	.i_reset     (reset),
	.i_rx        (tx),
	.o_data      (o_data),
	.o_data_valid(o_dv)
	);

initial begin
	tb_state <= START;
	reset <= '0;

	data <= '0;
	w_en <= '0;

	@(posedge txclk) reset <= '1;
	@(posedge txclk) reset <= '0;

	tb_state <= WRITE;
	// command
	@(posedge txclk);
	data <= WRITE_CMD;
	w_en <= '1;

	// address
	@(posedge clk);
	data <= 8'h12;

	// value
	@(posedge clk);
	data <= 8'h78;
	@(posedge clk);
	data <= 8'h56;
	@(posedge clk);
	data <= 8'h34;
	@(posedge clk);
	data <= 8'h12;

	@(posedge clk);
	w_en <= '0;

	repeat(80)
		@(posedge txclk);


	tb_state <= READ;
	// command
	@(posedge txclk);
	data <= READ_CMD;
	w_en <= '1;

	// address
	@(posedge clk);
	data <= 8'h12;

	// value
	@(posedge clk);
	data <= 8'h12;
	@(posedge clk);
	data <= 8'h34;
	@(posedge clk);
	data <= 8'h56;
	@(posedge clk);
	data <= 8'h78;

	@(posedge clk);
	w_en <= '0;

	repeat(160)
		@(posedge txclk);

	tb_state <= DONE;
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
	#(TXPHASE);
	forever #(TXPERIOD/2) txclk <= ~txclk;
end

endmodule : testbench_top_command_parser