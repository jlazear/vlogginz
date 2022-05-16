`timescale 1ns/1ns

module testbench_old;

logic clk, reset, rx, data_valid, dv_ref;
logic [7:0] data, data_ref;
logic rx_queue [$];
logic dv_queue [$];
logic [7:0] data_queue [$];

int c_fd;
int i=0, delay_count=0, delay=20;
int _tmp_rx, _tmp_dv, _tmp_data;

simple_uart_rx dut (clk, reset, rx, data, data_valid);

initial begin
	c_fd = $fopen("data.txt", "r");

	i=0;
	$display("Reading reference values from data.txt...");
	while ($fscanf(c_fd, "%b %b %d\n", _tmp_rx, _tmp_dv, _tmp_data) > 0) begin
		rx_queue.push_back(_tmp_rx);
		dv_queue.push_back(_tmp_dv);
		data_queue.push_back(_tmp_data);
		i++;
	end
	$display("Finished reading reference values. Read %0d values.", i);
	$fclose(c_fd);

	$display("rx_queue = %p", rx_queue);
	$display("dv_queue = %p", dv_queue);
	$display("data_queue = %p", data_queue);

	reset = 0;
	clk = 1;
	rx = 1;

	#10 reset = 1;
	#10 reset = 0;

	i = 0;

	while (rx_queue.size()) begin
		rx = rx_queue.pop_front();
		dv_ref = dv_queue.pop_front();
		data_ref = data_queue.pop_front();

		assert(data_valid == dv_ref) else $display("[t=%0t, i=%0d] dv = %0d expected %0d", $time, i, data_valid, dv_ref);
		assert(data_ref == data) else $display("[t=%0t, i=%0d] data = %0d expected %0d", $time, i, data, data_ref);
		i++;
		#10;
	end
	$stop;

end

always #5 clk = ~clk;

endmodule