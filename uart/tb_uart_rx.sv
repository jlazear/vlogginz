`timescale 1ns/1ns

module testbench;

localparam period = 100;  // 10 MHz clock
localparam TARGET_BAUDRATE = 115200;  // Hz
localparam FREQ_SHIFT = 0.05;  // fractional
localparam BAUDRATE = $rtoi(TARGET_BAUDRATE*(1.0 + FREQ_SHIFT));  // Hz
localparam DIVISOR = 10**9/(TARGET_BAUDRATE * period);  // unitless, uart dclk divisor
localparam SAMPLE_PHASE = DIVISOR/2;  // sample phase in number of samples
localparam WIDTH = 8;  // word width in bits
localparam N_SAMPLES = 4;  // number of samples to send in test
localparam VERBOSE = 1;
localparam TXPERIOD = 10**9/BAUDRATE; // period*DIVISOR; // 
localparam TXPHASE = TXPERIOD * 1/4;

logic clk, reset, txclk;
logic tx, dv_le, dv_be, _x;
logic [WIDTH-1 : 0] data_le, data_be, temp, temp_w_le, temp_w_be, temp_d_le, temp_d_be;
logic [WIDTH-1 : 0] write_buffer_le [$];
logic [WIDTH-1 : 0] write_buffer_be [$];
logic [WIDTH-1 : 0] data_buffer_le [$];
logic [WIDTH-1 : 0] data_buffer_be [$];
enum {START, WRITE, UNTASKED, DONE} tb_state;
logic [$clog2(WIDTH):0] txcnt;
int fd_tx, fd_values_le, fd_values_be, n_errors_le=0, n_errors_be=0;


uart_rx #(
	.WIDTH       (WIDTH),
	.DIVISOR     (DIVISOR),
	.SAMPLE_PHASE(SAMPLE_PHASE),
	.LITTLE_ENDIAN(0)
	) dut_be (
	.clk         (clk),
	.i_reset     (reset),
	.i_rx        (tx),
	.o_data      (data_be),
	.o_data_valid(dv_be));

uart_rx #(
	.WIDTH       (WIDTH),
	.DIVISOR     (DIVISOR),
	.SAMPLE_PHASE(SAMPLE_PHASE),
	.LITTLE_ENDIAN(1)
	) dut_le (
	.clk         (clk),
	.i_reset     (reset),
	.i_rx        (tx),
	.o_data      (data_le),
	.o_data_valid(dv_le));


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
		$display("i   |write_le|data_le |write_be|data_be ");
		$display("-----------------");
		for (int i; i < write_buffer_le.size() || i < data_buffer_le.size(); i++) begin
			temp_w_le = write_buffer_le[i];
			temp_w_be = write_buffer_be[i];
			temp_d_le = data_buffer_le[i];
			temp_d_be = data_buffer_be[i];
			if (temp_w_le != temp_d_le) begin
				n_errors_le++;
			end
			if (temp_w_be != temp_d_be) begin
				n_errors_be++;
			end
			$display(" %0d |  %h   |   %h  |   %h  |   %h  ", i, temp_w_le, temp_d_le, temp_w_be, temp_d_be);

		end
		// $displayh("write_buffer = %p", write_buffer);
		// $displayh("data_buffer = %p", data_buffer);
	end
	assert (write_buffer_le == data_buffer_le) begin
		$display("============");
		$display("    (LITTLE ENDIAN) data read of %0d samples SUCCESSFUL", N_SAMPLES);
		$display("============");
	end else begin
		$display("============");
		$display("    (LITTLE ENDIAN) data read of %0d samples FAILED with %0d errors", N_SAMPLES, n_errors_le);
		$display("============");
	end
	assert (write_buffer_be == data_buffer_be) begin
		$display("============");
		$display("    (BIG ENDIAN) data read of %0d samples SUCCESSFUL", N_SAMPLES);
		$display("============");
	end else begin
		$display("============");
		$display("    (BIG ENDIAN) data read of %0d samples FAILED with %0d errors", N_SAMPLES, n_errors_le);
		$display("============");
	end
	$stop;
end

initial begin
	fd_values_le = $fopen("values_le.txt", "r");
	while (!$feof(fd_values_le)) begin
		_x = $fscanf(fd_values_le, "%d", temp);
		write_buffer_le.push_back(temp);
	end
	$fclose(fd_values_le);

	fd_values_be = $fopen("values_be.txt", "r");
	while (!$feof(fd_values_be)) begin
		_x = $fscanf(fd_values_be, "%d", temp);
		write_buffer_be.push_back(temp);
	end
	$fclose(fd_values_be);

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


always @(posedge dv_le) begin
	data_buffer_le.push_back(data_le);
end

always @(posedge dv_be) begin
	data_buffer_be.push_back(data_be);
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