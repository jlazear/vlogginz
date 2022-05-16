`timescale 1ns/1ns

module testbench;

parameter period = 10;

logic clk, reset, rx, data_valid, dv_ref;
logic [7:0] data, data_ref;

int c_fd, i;
logic _discard;
int n_errors = 0;

simple_uart_rx dut (clk, reset, rx, data, data_valid);

initial begin
	clk = 1;
	c_fd = $fopen("data.txt", "r");
	i=0;


	while (!$feof(c_fd)) begin
		@(posedge clk)
		_discard = $fscanf(c_fd, "%b %b %b %d\n", reset, rx, dv_ref, data_ref);

		#(period - 1);
		assert((data_valid == dv_ref) || $isunknown(data_valid)) else begin
			$display("[t=%0t, i=%0d] dv = %0d expected %0d", $time, i, data_valid, dv_ref);
			n_errors++;
		end
		assert((data_ref == data) || $isunknown(data)) else begin
			$display("[t=%0t, i=%0d] data = %0d expected %0d", $time, i, data, data_ref);
			n_errors++;
		end
		i++;
	end

	$fclose(c_fd);

	if (n_errors > 0)
		$display("test FAILED with %0d errors", n_errors);
	else
		$display("test PASSED with no errors");
	$stop;
end

always #(period/2) clk = ~clk;

endmodule