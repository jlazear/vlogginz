module vsc_register_read #(
	parameter DIVISOR = 9,
	parameter COUNTER_WIDTH = 20,
	parameter COUNTER_VALUE = 0
	) (
	input clk,    // Clock
	input i_reset,
	input [4:0] i_reg_addr,
	output o_tx,
	output o_busy,
	inout io_mdio,
	output o_mdc
);

	wire _x;
	logic rollover, dv, read_en;
	logic [14:0] data, mem;
	localparam MAX_VALUE = (COUNTER_VALUE == 0) ? 2**COUNTER_WIDTH - 1 : COUNTER_VALUE;

	counter #(
		.WIDTH(COUNTER_WIDTH),
		.MAX_VALUE     (MAX_VALUE))
	u_counter (
		.clk     (clk),
		.reset   (i_reset),
		.enable  ('1),
		.cnt     (_x),
		.rollover(rollover));

	pulse_extender u_pulse_extender (
		.clk(clk),
		.i_reset(i_reset),
		.i_x(rollover),
		.o_x(read_en));

	vsc8541_register u_vsc (
		.clk       (clk),
		.i_reset   (i_reset),
		.i_register(i_reg_addr),
		.i_read_en (read_en),
		.o_data    (data),
		.o_dv      (dv),
		.io_mdio   (io_mdio),
		.o_mdc     (o_mdc));

	// uart and shifting state machine
	enum {IDLE, LOAD, LOAD_TX1, TX1, LOAD_TX2, TX2, NEWLINE} state, next_state;
	logic [7:0] uart_data;
	logic uart_dv;
	logic [$clog2(10*DIVISOR) : 0] tx_cnt;
	logic [$clog2(DIVISOR) : 0] load_cnt;

	always_comb begin
		unique case (state)
			IDLE: next_state = dv ? LOAD : IDLE;
			LOAD: next_state = LOAD_TX1;
			LOAD_TX1: next_state = (load_cnt > DIVISOR) ? TX1 : LOAD_TX1;
			TX1: next_state = (tx_cnt > DIVISOR*10) ? LOAD_TX2 : TX1;
			LOAD_TX2: next_state = (load_cnt > DIVISOR) ? TX2 : LOAD_TX2;
			TX2: next_state = (tx_cnt > DIVISOR*10) ? NEWLINE : TX2;
			NEWLINE: next_state = (load_cnt > DIVISOR) ? IDLE : NEWLINE;
		endcase
	end

	always_ff @(posedge clk)
		if (i_reset)
			state <= IDLE;
		else
			state <= next_state;

	always_ff @(posedge clk) begin
		mem <= mem;
		uart_data <= uart_data;
		uart_dv <= '0;
		load_cnt <= '0;
		tx_cnt <= '0;
		if (i_reset) begin
			mem <= '0;
			uart_data <= '0;
		end else if (state == LOAD && dv) begin
			mem <= data;
		end else if (state == LOAD_TX1) begin
			uart_data <= data[7:0];
			uart_dv <= '1;
			load_cnt <= load_cnt + 1'b1;
		end else if (state == TX1) begin
			tx_cnt <= tx_cnt + 1'b1;
		end else if (state == LOAD_TX2) begin
			uart_data <= data[14:8];
			uart_dv <= '1;
			load_cnt <= load_cnt + 1'b1;
		end else if (state == TX2) begin
			tx_cnt <= tx_cnt + 1'b1;
		end else if (state == NEWLINE) begin
			uart_data <= 8'h0A;  // newline
			uart_dv <= '1;
			load_cnt <= load_cnt + 1'b1;
		end
	end

	uart_tx #(
		.WIDTH(8),
		.DIVISOR(DIVISOR))
	u_uart_tx (
		.clk    (clk),
		.i_reset(i_reset),
		.i_data (uart_data),
		.i_dv   (uart_dv),
		.o_tx   (tx),
		.o_busy (_x));

	assign o_tx = tx;


endmodule