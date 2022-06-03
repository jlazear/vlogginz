`ifndef FIFO_UART_CONTROLLER
	`define FIFO_UART_CONTROLLER 1

module fifo_uart_controller #(
	parameter WIDTH = 8
	) (
	input clk,    // Clock
	input i_reset,
	input i_tx_enable,
	input i_empty,
	input i_busy,
	input [WIDTH-1 : 0] i_r_data,
	output o_r_en,
	output o_dv,
	output [WIDTH-1 : 0] o_data
);

	logic [WIDTH-1 : 0] mem;
	logic r_en, dv, prev_busy;
	localparam [1:0] LOW=2'b00, RISING=2'b01, HIGH=2'b11, FALLING=2'b10;
	logic [1:0] busy_edge;
	assign busy_edge = {prev_busy, i_busy};

	enum {IDLE, READ, READ2, LOAD, DV, WAIT} state, next_state;

	always_comb begin
		unique case (state)
			IDLE: next_state = (!i_empty && !i_busy && i_tx_enable) ? READ : IDLE;	
			READ: next_state = READ2;
			READ2: next_state = LOAD;
			LOAD: next_state = DV;
			DV: next_state = (busy_edge == RISING) ? WAIT : DV;
			WAIT: next_state = (busy_edge == FALLING) ? IDLE : WAIT;
		endcase
	end

	always_ff @(posedge clk)
		if (i_reset)
			state <= IDLE;
		else
			state <= next_state;

	always_ff @(posedge clk) begin
		r_en <= '0;
		dv <= '0;
		mem <= mem;
		prev_busy <= i_busy;
		if (i_reset) begin
			mem <= '0;
			prev_busy <= '0;
		end else if (state == READ) begin
			r_en <= '1;
		end else if (state == LOAD) begin
			mem <= i_r_data;
		end else if (state == DV) begin
			dv <= '1;
		end
	end

	assign o_r_en = r_en;
	assign o_dv = dv;
	assign o_data = mem;

endmodule

`endif