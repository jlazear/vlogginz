module top_module #(
	parameter INVERT_ENABLE = 1,
	parameter INVERT_OUTPUT = 1
) (
	input        clk     , // Clock
	input        i_reset ,
	input        i_enable,
	output [7:0] o_data  ,
	output       o_tx,
	output [7:0] o_txd,
	output o_tx_en
);
	localparam WIDTH = 30;

	wire [WIDTH-1 : 0] c_out;
	wire [7:0] gray_out;
	logic rollover;

	counter #(
		.WIDTH(WIDTH),
		.RESET_VALUE   (0),
		.MAX_VALUE     (2**WIDTH - 1),
		.ROLLOVER_VALUE(0))
	u_counter (
		.clk     (clk),
		.reset   (i_reset),
		.enable  (INVERT_ENABLE ? !i_enable : i_enable),
		.cnt     (c_out),
		.rollover(rollover));

	// assign gray_out = c_out[WIDTH-1 : WIDTH - 8];
	gray u_gray (
		.in (c_out[WIDTH-1 : WIDTH-8]),
		.out(gray_out));

	assign o_data = INVERT_OUTPUT ? ~gray_out : gray_out;

	// uart state machine
	localparam DIVISOR = 9;
	enum {IDLE, LOADVALUE, VALUE, NEWLINE} state, next_state;
	logic [7:0] data, uart_data;
	logic [$clog2(DIVISOR*10)-1 : 0] data_cnt;
	logic [$clog2(DIVISOR) : 0] load_cnt;
	logic changed, uart_dv, tx;
	wire _x;

	assign changed = (data != gray_out);

	always_comb begin
		unique case (state)
			IDLE: next_state = changed ? LOADVALUE : IDLE;
			LOADVALUE: next_state = (load_cnt > DIVISOR) ? VALUE : LOADVALUE;
			VALUE: next_state = (data_cnt > DIVISOR*10) ? NEWLINE : VALUE;
			NEWLINE: next_state = (load_cnt > DIVISOR) ? IDLE : NEWLINE;
		endcase
	end

	always_ff @(posedge clk) begin
		if (i_reset)
			state <= IDLE;
		else
			state <= next_state;
	end

	always_ff @(posedge clk) begin
		data <= gray_out;
		uart_data <= uart_data;
		uart_dv <= '0;
		data_cnt <= '0;
		load_cnt <= '0;
		if (i_reset) begin
			data <= '0;
			uart_data <= '0;
		end else if (state == LOADVALUE) begin
			uart_data <= data;
			uart_dv <= '1;
			load_cnt <= load_cnt + 1'b1;
		end else if (state == VALUE) begin
			data_cnt <= data_cnt + 1'b1;
		end else if (state == NEWLINE) begin
			uart_data <= 8'h0A;  // newline
			uart_dv <= '1;
			load_cnt <= load_cnt + 1'b1;
		end
	end

	assign o_tx = tx;

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

	// gmii output, sits on top of uart FSM
	gmii_tx u_gmii_tx (
		.clk    (clk),
		.i_reset(i_reset),
		.i_dv   (changed),
		.i_data (gray_out),
		.o_txd  (o_txd),
		.o_tx_en(o_tx_en));

endmodule