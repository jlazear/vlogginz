`timescale 1ns/1ns

module testbench;

localparam period = 10;
localparam DEPTH = 8;
localparam LEVEL = 2;

logic clk, reset;
logic w_en, r_en, full, afull, empty, aempty;
logic [7:0] read_data, write_data, temp;
logic [7:0] write_buffer [$];
logic [7:0] read_buffer [$];

enum {START, LOAD1, READ1, RW_AT_FULL, DONE} tb_state;
enum {NONE, WRITE, READ} active_task;

task load_fifo(input int initial_delay=0, input r=0, input int n_samples=DEPTH);
	begin
		active_task <= WRITE;
		#(initial_delay);

		if (r) begin
			@(posedge clk) reset = '1;
			@(posedge clk) reset = '0;
		end

		for (int i=0; i < n_samples; i++) begin
			@(posedge clk);
			temp = $urandom;
			write_buffer.push_back(temp);
			w_en <= '1;
			write_data <= temp;
		end
		@(posedge clk) w_en <= '0;
		active_task <= NONE;
	end
endtask : load_fifo

task read_fifo(input int initial_delay=0, input int n_samples=DEPTH);
	begin
		active_task <= READ;
		#(initial_delay);

		@(posedge clk) r_en <= '1;
		@(posedge clk);
		for (int i=0; i < n_samples; i++) begin
			@(posedge clk);
			r_en <= (i >= n_samples - 1) ? '0 : '1;
			read_buffer <= {read_buffer, read_data};
		end
		active_task <= NONE;
	end
endtask : read_fifo

fifo #(
	.DEPTH(DEPTH),
	.LEVEL(LEVEL)
) dut (
	clk,
	reset,
	w_en,
	write_data,
	r_en,
	read_data,
	afull,
	full,
	aempty,
	empty
);

initial begin
	tb_state <= START;
	clk = '1;
	w_en = '0;
	r_en = '0;

	tb_state <= LOAD1;
	load_fifo(.r(1));

	// test simultaneous write/read at full capacity
	tb_state <= RW_AT_FULL;
	@(posedge clk);
	w_en <= '1;
	r_en <= '1;
	write_data <= 8'hff;
	write_buffer.push_back(8'hff);

	@(posedge clk);
	w_en <= '0;
	r_en <= '0;

	@(posedge clk);
	read_buffer.push_back(read_data);

	@(posedge clk);

	// test full read
	tb_state <= READ1;
	read_fifo(10);

	@(posedge clk);
	tb_state <= DONE;

	$display("%p", write_buffer);
	$display("%p", read_buffer);
	assert (write_buffer == read_buffer) begin
		$display("============");
		$display("    tests PASSED");
		$display("============");
	end else begin
		$display("============");
		$display("    tests FAILED");
		$display("============");
	end

	#(2*period) $stop;
end

always #(period/2) clk <= ~clk;

endmodule : testbench