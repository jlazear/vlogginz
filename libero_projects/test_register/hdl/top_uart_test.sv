module top_uart_test #(
	parameter WORD_WIDTH = 8,
	parameter DIVISOR = 100,
	parameter SAMPLE_PHASE = 49,
	parameter FIFO_DEPTH = 128,
	parameter FIFO_LEVEL = 16,
	parameter REG_DEPTH = 16,
	parameter REG_WIDTH = 4,  // in words
	parameter UART_LITTLE_ENDIAN = 1,
	parameter LITTLE_ENDIAN = 0,
	parameter DEADZONE_WIDTH = 1024
	) (
	input clk,    // Clock
	input i_reset,
	input i_rx,
	input [1:0] i_button,
	output o_tx,
	output o_full,
	output o_afull,
	output o_aempty,
	output o_empty,
	output [7:0] o_debug
);

	logic [WORD_WIDTH-1:0] data, r_data, w_addr, r_addr, cmd;
	logic [WORD_WIDTH*REG_WIDTH-1 : 0] w_data, pr_data;
	logic [WORD_WIDTH*(REG_WIDTH + 2) - 1 : 0] p_data;
	logic dv, dv_pulse, p_dv, pr_dv, p_dv_ser, w_en, r_en;
	logic [3:0] delayed;
	logic r_valid, d2_pulse, d3_pulse, tx_en;
	logic [7:0] debug;
	logic [1:0] button;
	logic reset;

	assign reset = &button;

	uart_rx #(
		.WIDTH       (WORD_WIDTH),
		.DIVISOR     (DIVISOR),
		.SAMPLE_PHASE(SAMPLE_PHASE),
		.LITTLE_ENDIAN(UART_LITTLE_ENDIAN)
		) u_uart_rx (
		.clk         (clk),
		.i_reset     (reset),
		.i_rx        (i_rx),
		.o_data      (data),
		.o_data_valid(dv)
		);

	pulse u_pulse_deser (
		.clk    (clk),
		.i_reset(reset),
		.i_x    (dv),
		.o_x    (p_dv_ser)
		);

	deserializer #(
		.WIDTH        (WORD_WIDTH),
		.NUM_WORDS    (REG_WIDTH+2),
		.LITTLE_ENDIAN(LITTLE_ENDIAN)
		) u_deserializer (
		.clk    (clk),
		.i_reset(reset),
		.i_data (data),
		.i_dv   (p_dv_ser),
		.o_data (p_data),
		.o_dv   (p_dv)
		);

	pulse #(
		.WIDTH(1)
		) u_pulse (
		.clk    (clk),
		.i_reset(reset),
		.i_x    (p_dv),
		.o_x    (dv_pulse)
		);

	command_controller #(
		.WORD_WIDTH (WORD_WIDTH),
		.VALUE_WORDS(REG_WIDTH)
		) u_cmd_controller (
		.clk     (clk),
		.i_reset (reset),
		.i_data  (p_data),
		.i_dv    (dv_pulse),
		.o_w_addr(w_addr),
		.o_w_data(w_data),
		.o_w_en  (w_en),
		.o_r_addr(r_addr),
		.o_r_en  (r_en),
		.o_cmd   (cmd)
		);

	register_block #(
		.WIDTH(REG_WIDTH*WORD_WIDTH),
		.DEPTH(REG_DEPTH)
		) u_register_block (
		.clk      (clk),
		.reset    (reset),
		.i_w_en   (scc_w_en),
		.i_w_addr (scc_addr),
		.i_w_value(scc_value),
		.i_r_en   (scc_r_en),
		.i_r_addr (scc_addr),
		.o_r_value(pr_data),
		.o_r_valid(pr_valid)
		);

	shift_register #(
		.WIDTH          (4),
		.FILL_MSB_TO_LSB(0)
		) u_sr (
		.clk    (clk),
		.i_reset(reset),
		.i_in   (tx_en),
		.o_out  (delayed)
		);

	pulse #(
		.WIDTH(1)
		) u_pulse2 (
		.clk    (clk),
		.i_reset(reset),
		.i_x    (delayed[2]),
		.o_x    (d2_pulse)
		);

	pulse #(
		.WIDTH(1)
		) u_pulse3 (
		.clk    (clk),
		.i_reset(reset),
		.i_x    (delayed[3]),
		.o_x    (d3_pulse)
		);

	serializer #(
		.WIDTH        (WORD_WIDTH),
		.NUM_WORDS    (REG_WIDTH),
		.LITTLE_ENDIAN(LITTLE_ENDIAN)
		) u_serializer (
		.clk    (clk),
		.i_reset(reset),
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
		.LITTLE_ENDIAN(UART_LITTLE_ENDIAN)
		) u_fifo_uart (
		.clk          (clk),
		.i_reset      (reset),
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

	// #DELME
	logic [WORD_WIDTH-1:0] o_cmd, scc_addr;
	logic [WORD_WIDTH*REG_WIDTH-1:0] scc_value;
	logic [1:0] o_state;
	logic scc_w_en, scc_r_en;
	simple_command_controller #(
		.WORD_WIDTH (WORD_WIDTH),
		.VALUE_WORDS(REG_WIDTH)
		) u_scmd_controller (
		.clk    (clk),
		.i_reset(reset),
		.i_data (p_data),
		.i_dv   (dv_pulse),
		.o_cmd  (o_cmd),
		.o_w_en (scc_w_en),
		.o_r_en (scc_r_en),
		.o_addr (scc_addr),
		.o_value(scc_value)
		);
	// #DELME END DELME

	// debug shit
	// #DELME END

	// debouncer #(
	// 	.DEADZONE_WIDTH(1024*1024*50)
	// 	) u_debug_debounce (
	// 	.clk    (clk),
	// 	.i_reset(reset),
	// 	.i_in   (w_en),
	// 	.o_out  (o_debug)
	// 	);
	debouncer #(
		.DEADZONE_WIDTH(DEADZONE_WIDTH)
		) u_debouncer_b0 (
		.clk    (clk),
		.i_reset(reset),
		.i_in   (i_button[0]),
		.o_out  (button[0])
		);

	assign tx_en = button[0];

	debouncer #(
		.DEADZONE_WIDTH(DEADZONE_WIDTH)
		) u_debouncer_b1 (
		.clk    (clk),
		.i_reset(reset),
		.i_in   (i_button[1]),
		.o_out  (button[1])
		);

	genvar i;
	for (i=0; i<8; i++) begin
		debouncer #(
			.DEADZONE_WIDTH(1024*1024*50)
			) u_debug_debounce (
			.clk    (clk),
			.i_reset(reset),
			.i_in   (debug[i]),
			.o_out  (o_debug[i])
			);
	end

	localparam CMUX_N_STATES = 10;
	logic [WORD_WIDTH-1:0] cmux_in [CMUX_N_STATES-1:0];
	click_mux #(
		.WIDTH   (WORD_WIDTH),
		.N_STATES(CMUX_N_STATES)
		) u_cmux (
		.clk    (clk),
		.i_reset(reset),
		.i_click(button[1]),
		.i_x    (cmux_in),
		.o_x    (debug)
		);

	assign cmux_in[0] = ~8'b10100011;  // reference state, LDLDDDLL on board
	assign cmux_in[1] = ~8'b11000101;  // reference state, LLDDDLDL on board

	assign cmux_in[2] = ~{scc_r_en, scc_r_en, scc_w_en, scc_w_en, 4'b1111};
	assign cmux_in[3] = ~{dv, p_dv_ser, p_dv, dv_pulse, r_en, r_en, w_en, w_en};
	assign cmux_in[4] = ~cmd;
	assign cmux_in[5] = ~scc_addr;
	assign cmux_in[6] = ~scc_value[3 * WORD_WIDTH +: WORD_WIDTH];
	assign cmux_in[7] = ~scc_value[2 * WORD_WIDTH +: WORD_WIDTH];
	assign cmux_in[8] = ~scc_value[1 * WORD_WIDTH +: WORD_WIDTH];
	assign cmux_in[9] = ~scc_value[0 * WORD_WIDTH +: WORD_WIDTH];
	// assign cmux_in[5] = ~w_data[REG_WIDTH*WORD_WIDTH - 1 : (REG_WIDTH-1)*WORD_WIDTH];
	// assign cmux_in[6] = ~w_data[(REG_WIDTH-1)*WORD_WIDTH - 1 : (REG_WIDTH-2)*WORD_WIDTH];
	// assign cmux_in[7] = ~w_data[(REG_WIDTH-2)*WORD_WIDTH - 1 : (REG_WIDTH-3)*WORD_WIDTH];
	// assign cmux_in[8] = ~w_data[(REG_WIDTH-3)*WORD_WIDTH - 1 : (REG_WIDTH-4)*WORD_WIDTH];

	// assign cmux_in[2] = ~{dv, p_dv_ser, p_dv, dv_pulse, r_en, r_en, w_en, w_en};
	// assign cmux_in[3] = ~p_data[5*WORD_WIDTH+:WORD_WIDTH];
	// assign cmux_in[4] = ~p_data[4*WORD_WIDTH+:WORD_WIDTH];
	// assign cmux_in[5] = ~p_data[3*WORD_WIDTH+:WORD_WIDTH];
	// assign cmux_in[6] = ~p_data[2*WORD_WIDTH+:WORD_WIDTH];
	// assign cmux_in[7] = ~p_data[1*WORD_WIDTH+:WORD_WIDTH];
	// assign cmux_in[8] = ~p_data[0*WORD_WIDTH+:WORD_WIDTH];
	// assign cmux_in[9] = ~cmd;
	// assign cmux_in[10] = ~w_addr;
	// assign cmux_in[11] = ~w_data[REG_WIDTH*WORD_WIDTH - 1 : (REG_WIDTH-1)*WORD_WIDTH];
	// assign cmux_in[12] = ~w_data[(REG_WIDTH-1)*WORD_WIDTH - 1 : (REG_WIDTH-2)*WORD_WIDTH];
	// assign cmux_in[13] = ~w_data[(REG_WIDTH-2)*WORD_WIDTH - 1 : (REG_WIDTH-3)*WORD_WIDTH];
	// assign cmux_in[14] = ~w_data[(REG_WIDTH-3)*WORD_WIDTH - 1 : (REG_WIDTH-4)*WORD_WIDTH];
	// assign cmux_in[15] = ~o_cmd;
	// assign cmux_in[16] = ~{scc_r_en, scc_r_en, scc_w_en, scc_w_en, o_state[1:0], o_state[1:0]};

	// assign cmux_in[2] = ~o_cmd;
	// assign cmux_in[3] = ~{scc_r_en, scc_r_en, scc_w_en, scc_w_en, o_state[1:0], o_state[1:0]};
	// assign cmux_in[4] = ~data[0+:WORD_WIDTH];
	// assign cmux_in[5] = ~p_data[5*WORD_WIDTH+:WORD_WIDTH];
	// assign cmux_in[6] = ~p_data[4*WORD_WIDTH+:WORD_WIDTH];
	// assign cmux_in[7] = ~p_data[3*WORD_WIDTH+:WORD_WIDTH];
	// assign cmux_in[8] = ~p_data[2*WORD_WIDTH+:WORD_WIDTH];
	// assign cmux_in[9] = ~p_data[1*WORD_WIDTH+:WORD_WIDTH];
	// assign cmux_in[10] = ~p_data[0*WORD_WIDTH+:WORD_WIDTH];

endmodule