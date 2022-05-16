`ifndef SIMPLE_SPI
	`define SIMPLE_SPI 1

// CS 0 mode Tx only
module simple_spi_master 
	#(parameter DIVISOR=2, // odd divisors are equivalent to DIVISOR+1
	WIDTH=8)  
	(
	input clk,
	input i_reset,
	input [WIDTH-1:0] i_data,  // data to transmit, sampled on i_load_enable rising edge
	input i_load_enable,  // i_load_enable
	output o_sclk,
	output o_mosi,
	output o_output_valid
);

	enum {IDLE, WRITE} state, next_state;
	localparam [$clog2(2*WIDTH - 1):0] SCLK_CNT_MAX = (2*WIDTH - 1);
	localparam [1:0] LOW=2'b00, RISING=2'b01, FALLING=2'b10, HIGH=2'b11;
	localparam [$clog2(DIVISOR-1) : 0] SCLK_I_MAX = ((DIVISOR-1) >> 1);
	reg sclk_prev;
	reg data_buffered, data_loaded;
	reg [1:0] sclk_edge;

	reg [$clog2(DIVISOR-1) : 0] sclk_i;
	reg [$clog2(2*WIDTH - 1):0] sclk_cnt;
	reg sclk, next_sclk;

	reg [WIDTH-1:0] data, load_buf;
	reg mosi;


	// state machine
	always @*
		unique case (state)
			IDLE: next_state <= i_load_enable ? WRITE : IDLE;
			WRITE: next_state <= ((sclk_cnt >= SCLK_CNT_MAX && sclk_i >= SCLK_I_MAX) && !data_buffered && !i_load_enable) ? IDLE : WRITE;
		endcase

	// state transitions
	always @(posedge clk)
		if (i_reset)
			state <= IDLE;
		else
			state <= next_state;

	// loading circuit
	always @(posedge clk) begin
		if (i_reset) begin
			data <= '0;
			load_buf <= '0;
			data_loaded <= '0;
			data_buffered <= '0;
		end else if (state == IDLE) begin
			// load data
			if (i_load_enable) begin
				data <= i_data;
				data_loaded <= '1;
			end
		end else begin // state == WRITE
			if (sclk_cnt == SCLK_CNT_MAX) begin
				data_loaded <= '1;
				load_buf <= '0;
				data_buffered <= '0;
				if (i_load_enable) begin
					data <= i_data;
				end else if (data_buffered) begin
					data <= load_buf;
				end
			end else if ((sclk_cnt >= SCLK_CNT_MAX/2) & i_load_enable) begin
				load_buf <= i_data;
				data_buffered <= '1;
			end
		end
	end

	// data shifting
	always @(posedge clk) begin
		if (!i_reset) begin
			if (data_loaded && sclk_edge == FALLING)
				if (!(sclk_cnt == SCLK_CNT_MAX && (i_load_enable || data_buffered)))
					data <= data << 1'b1;
		end
	end

	// sclk generation
	always_comb
		next_sclk <= (sclk_i >= SCLK_I_MAX) ? ~sclk : sclk;

	assign sclk_edge = {sclk, next_sclk};
	always @(posedge clk) begin
		sclk <= '0;
		sclk_i <= '0;
		sclk_prev <= sclk;
		sclk_cnt <= '0;		
		if (i_reset) begin
			sclk_prev <= '0;
		end else if (state == WRITE) begin
			sclk <= next_sclk;
			if (sclk_i >= SCLK_I_MAX) begin
				sclk_i <= '0;
				sclk_cnt <= (sclk_cnt >= SCLK_CNT_MAX) ? 0 : sclk_cnt + 1'b1;
			end else begin
				sclk_i <= sclk_i + 1'b1;
				sclk_cnt <= sclk_cnt;
			end
		end
	end

	assign o_sclk = sclk;
	assign o_mosi = data[WIDTH-1];
	assign o_output_valid = (state == WRITE);

endmodule


module simple_spi_slave 
	#(WIDTH=8)
	(
	input i_sclk,
	input i_areset,  // asynchronous reset, since sclk is not always available
	input i_mosi,
	input i_cs,  // chip select
	output [WIDTH-1:0] o_data,  // data to transmit, sampled on i_load_enable rising edge
	output o_output_valid,	// pulse high when new data word available
	output o_cs_desync  // high if received invalid number of sclk cycles
);

	logic [WIDTH-2:0] sr;
	logic [WIDTH-1:0] data;
	logic [$clog2(WIDTH)-1:0] cnt;
	logic ov;

	always @(posedge i_sclk or posedge i_areset) begin
		if (i_areset) begin
			data <= '0;
			sr <= '0;
			cnt <= '0;
			ov <= '0;
		end else if (i_cs) begin
			sr <= {sr[WIDTH-2:0], i_mosi};
			cnt <= cnt + 1'b1;
			ov <= '0;
			if (cnt >= WIDTH-1) begin
				cnt <= '0;
				data <= {sr, i_mosi};
				ov <= '1;
			end
		end else begin
			sr <= sr;
			data <= data;
			cnt <= cnt;
			ov <= ov;
		end
	end

	assign o_data = data;
	assign o_output_valid = ov;
	assign o_cs_desync = !i_cs && (cnt != '0);
endmodule

`endif
