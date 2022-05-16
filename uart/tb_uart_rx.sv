`timescale 1ns/1ns

module testbench;

localparam period = 100;  // 10 MHz clock
localparam baudrate = 115200;  // Hz
localparam DIVISOR = 4; // 10**9/(baudrate * period);  // unitless, uart dclk divisor
localparam SAMPLE_PHASE = DIVISOR/2;  // sample phase in number of samples
localparam WIDTH = 8;  // word width in bits
localparam N_SAMPLES = 4;  // number of samples to send in test
localparam VERBOSE = 1;
localparam txperiod = 10**9/baudrate;
localparam txphase = txperiod * 3/4;

logic clk, reset, txclk;
logic tx, dv;
logic [WIDTH-1 : 0] data, temp;
logic [WIDTH-1 : 0] write_buffer [$];
logic [WIDTH-1 : 0] data_buffer [$];
enum {START, WRITE, UNTASKED, DONE} tb_state;


uart_rx #(
	.WIDTH       (WIDTH),
	.DIVISOR     (DIVISOR),
	.SAMPLE_PHASE(SAMPLE_PHASE))
dut (
	.clk         (clk),
	.i_reset     (reset),
	.i_rx        (tx),
	.o_data      (data),
	.o_data_valid(dv));

task send_word (input int initial_delay=period,
	input logic [WIDTH-1:0] value='0, 
	input int divisor=DIVISOR,
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
			repeat (divisor)
				@(posedge clk);
			tx <= temp[WIDTH-1];
			temp <= temp << 1;
		end
		repeat (divisor)
			@(posedge clk);
		tx <= '1;
	tb_state <= UNTASKED;
	end
endtask : send_word

initial begin
	tb_state <= START;
	reset <= '0;
	tx <= '1;

	$display("DIVISOR = %0d, SAMPLE_PHASE = %0d, WIDTH = %0d, N_SAMPLES = %0d", 
		DIVISOR, SAMPLE_PHASE, WIDTH, N_SAMPLES);

	@(posedge clk) reset <= '1;
	@(posedge clk) reset <= '0;
	@(posedge clk);

	// delay during writes
	repeat (2 + (WIDTH+2)*DIVISOR*N_SAMPLES + 50)
		@(posedge clk);

	// for (int i=0; i<N_SAMPLES; i++) begin
	// 	// send_word(10 + (WIDTH+2)*period*DIVISOR*i,
	// 	send_word(0,
	// 		.verbose(VERBOSE));
	// end

	tb_state <= DONE;
	#(20*DIVISOR*period);
	$displayh("write_buffer = %p", write_buffer);
	$displayh("data_buffer = %p", data_buffer);
	assert (write_buffer == data_buffer) begin
		$display("============");
		$display("    data read of %0d samples SUCCESSFUL", N_SAMPLES);
		$display("============");
	end else begin
		$display("============");
		$display("    data read of %0d samples FAILED", N_SAMPLES);
		$display("============");
	end
	$stop;
end

genvar i;
for (i=0; i<N_SAMPLES; i++) begin
	initial begin
		repeat (i)
			temp = $urandom();
		send_word(2*period + (WIDTH+2)*period*DIVISOR*i,
			.verbose(VERBOSE));
	end
end

always @(posedge dv) begin
	data_buffer.push_back(data);
end

// clk block
initial begin
	clk <= '1;
	forever #(period/2) clk <= ~clk;
end

endmodule : testbench