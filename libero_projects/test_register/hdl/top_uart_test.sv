module top_uart_test #(
	parameter WORD_WIDTH = 8,
	parameter DIVISOR = 100,
	parameter SAMPLE_PHASE = 49,
	parameter FIFO_DEPTH = 128,
	parameter FIFO_LEVEL = 16,
	parameter REG_DEPTH = 16,
	parameter REG_WIDTH = 4,  // in words
	parameter LITTLE_ENDIAN = 0,
	parameter DEADZONE_WIDTH = 1024
	) (
	input clk,    // Clock
	input i_reset,
	input i_rx,
	input i_tx_en,
	output o_tx,
	output o_full,
	output o_afull,
	output o_aempty,
	output o_empty
);

	logic [WORD_WIDTH-1:0] data, r_data;
	logic [WORD_WIDTH*REG_WIDTH-1 : 0] p_data, pr_data;
	logic dv, dv_pulse, p_dv, pr_dv, p_dv_ser;
	logic [3:0] delayed;
	logic r_valid, d2_pulse, d3_pulse, tx_en;

	uart_rx #(
		.WIDTH       (WORD_WIDTH),
		.DIVISOR     (DIVISOR),
		.SAMPLE_PHASE(SAMPLE_PHASE),
		.LITTLE_ENDIAN(LITTLE_ENDIAN)
		) u_uart_rx (
		.clk         (clk),
		.i_reset     (i_reset),
		.i_rx        (i_rx),
		.o_data      (data),
		.o_data_valid(dv)
		);

	pulse u_pulse_deser (
		.clk    (clk),
		.i_reset(i_reset),
		.i_x    (dv),
		.o_x    (p_dv_ser)
		);

	deserializer #(
		.WIDTH        (WORD_WIDTH),
		.NUM_WORDS    (REG_WIDTH),
		.LITTLE_ENDIAN(LITTLE_ENDIAN)
		) u_deserializer (
		.clk    (clk),
		.i_reset(i_reset),
		.i_data (data),
		.i_dv   (p_dv_ser),
		.o_data (p_data),
		.o_dv   (p_dv)
		);

	pulse #(
		.WIDTH(1)
		) u_pulse (
		.clk    (clk),
		.i_reset(i_reset),
		.i_x    (p_dv),
		.o_x    (dv_pulse)
		);

	register_block #(
		.WIDTH(REG_WIDTH*WORD_WIDTH),
		.DEPTH(REG_DEPTH)
		) u_register_block (
		.clk      (clk),
		.reset    (i_reset),
		.i_w_en   (dv_pulse),
		.i_w_addr ('0),
		.i_w_value(p_data),
		.i_r_en   (d2_pulse),
		.i_r_addr ('0),
		.o_r_value(pr_data),
		.o_r_valid(pr_valid)
		);

	debouncer #(
		.DEADZONE_WIDTH(DEADZONE_WIDTH)
		) u_debouncer (
		.clk    (clk),
		.i_reset(i_reset),
		.i_in   (i_tx_en),
		.o_out  (tx_en)
		);

	shift_register #(
		.WIDTH          (4),
		.FILL_MSB_TO_LSB(0)
		) u_sr (
		.clk    (clk),
		.i_reset(i_reset),
		.i_in   (tx_en),
		.o_out  (delayed)
		);

	pulse #(
		.WIDTH(1)
		) u_pulse2 (
		.clk    (clk),
		.i_reset(i_reset),
		.i_x    (delayed[2]),
		.o_x    (d2_pulse)
		);

	pulse #(
		.WIDTH(1)
		) u_pulse3 (
		.clk    (clk),
		.i_reset(i_reset),
		.i_x    (delayed[3]),
		.o_x    (d3_pulse)
		);

	serializer #(
		.WIDTH        (WORD_WIDTH),
		.NUM_WORDS    (REG_WIDTH),
		.LITTLE_ENDIAN(LITTLE_ENDIAN)
		) u_serializer (
		.clk    (clk),
		.i_reset(i_reset),
		.i_data (pr_data),
		.i_dv   (pr_valid),
		.o_data (r_data),
		.o_dv   (r_valid)
		);

	fifo_uart #(
		.WIDTH  (WORD_WIDTH),
		.DEPTH  (FIFO_DEPTH),
		.DIVISOR(DIVISOR),
		.LEVEL  (FIFO_LEVEL),
		.LITTLE_ENDIAN(LITTLE_ENDIAN)
		) u_fifo_uart (
		.clk          (clk),
		.i_reset      (i_reset),
		.i_fifo_enable('1),
		.i_tx_enable  ('1),
		.i_w_en       (r_valid),
		.i_w_data     (r_data),
		.o_tx         (o_tx),
		.o_full       (o_full),
		.o_afull      (o_afull),
		.o_empty      (o_empty),
		.o_aempty     (o_aempty)
		);



endmodule