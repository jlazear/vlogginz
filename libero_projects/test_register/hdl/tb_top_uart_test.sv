`timescale 1ns/1ns

module testbench_top_uart_test;

localparam period = 20;  // 50 MHz
localparam DIVISOR = 434;
localparam SAMPLE_PHASE = 217;
localparam TXPERIOD = period*DIVISOR; // 
localparam TXPHASE = TXPERIOD * 1/4;

logic clk, reset, txclk;
enum {START, WRITE, TX, DONE} tb_state;
logic i_rx, i_tx_en, o_tx, o_full, o_afull, o_aempty, o_empty;
logic [7:0] w_data, ext_o_data;
logic ext_full, ext_afull, ext_empty, ext_aempty, ext_o_dv;
logic w_en;

logic [31:0] final_data;
logic final_dv;

top_uart_test #(
	.DIVISOR      (DIVISOR),
	.SAMPLE_PHASE (SAMPLE_PHASE),
	.FIFO_DEPTH   (16),
	.FIFO_LEVEL   (2),
	.REG_DEPTH    (16),
	.REG_WIDTH    (4),
	.LITTLE_ENDIAN(0)
	) dut (
	.clk     (clk),
	.i_reset (reset),
	.i_rx    (i_rx),
	.i_tx_en (i_tx_en),
	.o_tx    (o_tx),
	.o_full  (o_full),
	.o_afull (o_afull),
	.o_aempty(o_aempty),
	.o_empty (o_empty)
	);

fifo_uart #(
	.WIDTH  (8),
	.DEPTH  (16),
	.DIVISOR(DIVISOR),
	.LEVEL  (2)
	) u_fifo_uart_tx (
	.clk          (clk),
	.i_reset      (reset),
	.i_fifo_enable('1),
	.i_tx_enable  ('1),
	.i_w_en       (w_en),
	.i_w_data     (w_data),
	.o_tx         (i_rx),
	.o_full       (ext_full),
	.o_afull      (ext_afull),
	.o_empty      (ext_empty),
	.o_aempty     (ext_aempty)
	);

uart_rx #(
	.WIDTH       (8),
	.DIVISOR     (DIVISOR),
	.SAMPLE_PHASE(SAMPLE_PHASE)
	) u_fifo_rx (
	.clk         (clk),
	.i_reset     (reset),
	.i_rx        (o_tx),
	.o_data      (ext_o_data),
	.o_data_valid(ext_o_dv)
	);

deserializer #(
	.WIDTH        (8),
	.NUM_WORDS    (4),
	.LITTLE_ENDIAN(1)
	) u_deserializer (
	.clk    (txclk),
	.i_reset(reset),
	.i_data (ext_o_data),
	.i_dv   (ext_o_dv),
	.o_data (final_data),
	.o_dv   (final_dv)
	);

initial begin
	tb_state <= START;
	reset <= '0;
	i_tx_en <= '0;
	w_en <= '0;
	w_data <= '0;

	@(posedge txclk) reset <= '1;
	@(posedge txclk) reset <= '0;

	repeat(10)
		@(posedge txclk);

	tb_state <= WRITE;
	@(posedge clk);
	w_en <= '1;
	w_data <= 8'haa;
	@(posedge clk);
	w_data <= 8'hbb;
	@(posedge clk);
	w_data <= 8'hcc;
	@(posedge clk);
	w_data <= 8'hdd;

	@(posedge clk);
	w_en <= '0;

	repeat(50)
		@(posedge txclk);

	tb_state <= TX;
	repeat(20) begin
		i_tx_en <= '1;
		@(posedge txclk)
		i_tx_en <= '0;
		repeat (50)
			@(posedge txclk);

	end


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

endmodule : testbench_top_uart_test