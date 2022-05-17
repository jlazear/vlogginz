`timescale 1ns/1ns

module testbench;

localparam period = 100;  // 10 MHz clock
localparam TARGET_BAUDRATE = 115200;  // Hz
localparam FREQ_SHIFT = 0.05;  // fractional
localparam BAUDRATE = TARGET_BAUDRATE*(1 + FREQ_SHIFT);  // Hz
localparam DIVISOR = 10**9/(TARGET_BAUDRATE * period);  // unitless, uart dclk divisor
localparam SAMPLE_PHASE = DIVISOR/2;  // sample phase in number of samples
localparam WIDTH = 8;  // word width in bits
localparam N_SAMPLES = 1024;  // number of samples to send in test
localparam VERBOSE = 1;
localparam TXPERIOD = 10**9/BAUDRATE; // period*DIVISOR; // 
localparam TXPHASE = TXPERIOD * 1/4;

logic clk, reset, txclk;
logic tx, dv, _x;
logic [WIDTH-1 : 0] data, temp, temp_w, temp_d;
logic [WIDTH-1 : 0] write_buffer [$];
logic [WIDTH-1 : 0] data_buffer [$];
enum {START, WRITE, UNTASKED, DONE} tb_state;
logic [$clog2(WIDTH):0] txcnt;
int fd_tx, fd_values, n_errors=0;


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

initial begin
	tb_state <= START;
	reset <= '0;
	tx <= '1;

	$display("TARGET_BAUDRATE = %0d, TX_BAUDRATE = %0d", TARGET_BAUDRATE, BAUDRATE);
	$display("TXPHASE = %0d, TXPERIOD = %0d", TXPHASE, TXPERIOD);
	$display("DCLKPERIOD = %0d", DIVISOR*period);
	$display("DIVISOR = %0d, SAMPLE_PHASE = %0d, WIDTH = %0d, N_SAMPLES = %0d", 
		DIVISOR, SAMPLE_PHASE, WIDTH, N_SAMPLES);

	@(posedge clk) reset <= '1;
	@(posedge clk) reset <= '0;
	@(posedge clk);

	// delay during writes
	repeat (2 + (WIDTH+2)*TXPERIOD/period*(N_SAMPLES + 10))
		@(posedge clk);

	tb_state <= DONE;
	#(20*DIVISOR*period);
	if (VERBOSE) begin
		$display("i   |  write |  data  ");
		$display("-----------------");
		for (int i; i < write_buffer.size() || i < data_buffer.size(); i++) begin
			temp_w = write_buffer[i];
			temp_d = data_buffer[i];
			if (temp_w != temp_d) begin
				n_errors++;
			end
			$display(" %0d |  %h   |   %h  ", i, temp_w, temp_d);

		end
		// $displayh("write_buffer = %p", write_buffer);
		// $displayh("data_buffer = %p", data_buffer);
	end
	assert (write_buffer == data_buffer) begin
		$display("============");
		$display("    data read of %0d samples SUCCESSFUL", N_SAMPLES);
		$display("============");
	end else begin
		$display("============");
		$display("    data read of %0d samples FAILED with %0d errors", N_SAMPLES, n_errors);
		$display("============");
	end
	$stop;
end

initial begin
	fd_values = $fopen("values.txt", "r");
	while (!$feof(fd_values)) begin
		_x = $fscanf(fd_values, "%d", temp);
		write_buffer.push_back(temp);
	end
	$fclose(fd_values);

	fd_tx = $fopen("tx.txt", "r");

	repeat(10)
		@(posedge txclk);

	@(posedge txclk)
	while (!$feof(fd_tx)) begin
		@(posedge txclk);
		_x = $fscanf(fd_tx, "%b\n", tx);
	end
	$fclose(fd_tx);



end


always @(posedge dv) begin
	data_buffer.push_back(data);
end

// clk block
initial begin
	clk <= '1;
	forever #(period/2) clk <= ~clk;
end

// txclk block
initial begin
	txclk <= '1;
	txcnt <= '0;
	#(TXPHASE);
	forever #(TXPERIOD/2) txclk <= ~txclk;
end

always @(posedge txclk)
		txcnt <= (txcnt < 9) ? txcnt + 1'b1 : '0;

endmodule : testbench