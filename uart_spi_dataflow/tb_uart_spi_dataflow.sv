`timescale 1ns/1ns

module testbench;

localparam period = 10;
localparam WIDTH = 8;  // uart has 8-bit width hard-coded, so only 8 will work
localparam DEPTH = 1024;
localparam LEVEL = 64;
localparam DIVISOR = 8;
localparam VERBOSE = 0;
localparam spi_period = DIVISOR * WIDTH * period;

logic clk, reset;
logic tx, r_en, full, a_full, empty, a_empty;
logic [WIDTH-1 : 0] read_data, temp;
logic [WIDTH-1 : 0] write_buffer [$];
logic [WIDTH-1 : 0] fifo_buffer [$];
enum {START, WRITE, UNTASKED, DONE} tb_state;


uart_spi_dataflow #(
	.WIDTH  (WIDTH),
	.DEPTH  (DEPTH),
	.LEVEL  (LEVEL),
	.DIVISOR(DIVISOR)
	)
dut (
	clk,
	reset,
	tx,
	r_en,
	read_data,
	full,
	a_full,
	empty,
	a_empty);

task send_word (input int initial_delay=period,
	input logic [WIDTH-1:0] value='0, 
	input int randomize=1,
	input int verbose=0);
 
	begin
		tb_state <= WRITE;
		#(initial_delay);
		if (randomize)
			temp = $urandom();
		else
			temp = value;

		if (verbose) $display("value = %h", temp);
		write_buffer.push_back(temp);

		@(posedge clk);
		tx <= '0;

		for (int i=0; i < WIDTH; i++) begin
			@(posedge clk);
			tx <= temp[WIDTH-1];
			temp <= temp << 1;
		end
		@(posedge clk);
		tx <= '1;
	tb_state <= UNTASKED;
	end
endtask : send_word

// main block
initial begin
	tb_state <= START;
	reset <= '0;
	tx <= '1;
	r_en <= '0;

	@(posedge clk) reset <= '1;
	@(posedge clk) reset <= '0;

	// delay during writes
	#(period + DEPTH*spi_period + 50*period);

	// read out fifo
	@(posedge clk);
	r_en <= '1;
	@(posedge clk);
	repeat (DEPTH-1) begin
		@(posedge clk);
		fifo_buffer.push_back(read_data);
	end
	r_en <= '0;
	@(posedge clk);
	fifo_buffer.push_back(read_data);
	
	repeat (10) @(posedge clk);

	// check results
	tb_state <= DONE;
	if (VERBOSE) begin
		$displayh("write_buffer = %p", write_buffer);
		$displayh("fifo_buffer = %p", fifo_buffer);
	end

	assert (write_buffer == fifo_buffer) begin
		$display("============");
		$display("    data transfer of %0d samples SUCCESSFUL", DEPTH);
		$display("============");
	end else begin
		$display("============");
		$display("    data transfer of %0d samples FAILED", DEPTH);
		$display("============");
	end
	@(posedge clk);
	$stop;
end

// transmit DEPTH words into tx
genvar i;
for (i = 0; i < DEPTH; i++) begin
	initial begin 
		repeat (i)
			temp = $urandom();

		send_word(2*period + i*spi_period,
		.verbose(VERBOSE));	end
end

// clk block
initial begin
	clk <= '1;
	forever #(period/2) clk <= ~clk;
end

endmodule : testbench