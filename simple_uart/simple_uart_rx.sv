`ifndef SIMPLE_UART_RX
	`define SIMPLE_UART_RX 1

module simple_uart_rx
	#()
	(
		input clk,
		input reset,
		input rx,
		output [7:0] q, 
		output data_valid);

	reg [8:0] _data;
	reg [3:0] cnt;
	wire start_bit, end_bit;

	enum {D, S, W} state, next_state;

	assign start_bit = _data[8];
	assign end_bit = rx;

	always @*
		case (state)
			D: next_state = (~start_bit & end_bit) ? S : D;
			S: next_state = W;
			W: begin
				if (cnt < 8)
					next_state = W;
				else
					next_state = (~start_bit & end_bit) ? S : D;
			end
			default : next_state = D;
	endcase

	always @(posedge clk)
		if (reset) begin
			state <= D;
			_data <= '1;
		end else begin
			_data <= {_data[7:0], rx};
			cnt <= 0;
			state <= next_state;
			if (state == W)
				cnt <= cnt + 4'b1;
		end

	assign data_valid = (state == S);
	assign q = data_valid ? _data[8:1] : '0;

endmodule : simple_uart_rx

`endif