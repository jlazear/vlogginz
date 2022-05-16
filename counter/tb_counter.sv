`timescale 1ns/1ns

module testbench;

logic clk, reset, enable_q4, enable_q8, rollover_q4, rollover_q8;
wire [3:0] cnt4;
wire [7:0] cnt8;
int cnt_ref = 0;
int n_errors = 0;

counter #(
	.WIDTH    (4 ),
	.MAX_VALUE(15)
) q4 (
	clk,
	reset,
	enable_q4,
	cnt4,
	rollover_q4
);

counter #(
	.WIDTH         (8  ),
	.MAX_VALUE     (220),
	.RESET_VALUE   (200),
	.ROLLOVER_VALUE(210)
) q8 (
	clk,
	reset,
	enable_q8,
	cnt8,
	rollover_q8
);

initial begin
	$monitor("[monitor] t=%0t, reset=%d, q4=[%d / %0d / %0d], q8=[%d / %0d / %0d]",
		     $time, reset, enable_q4, cnt4, rollover_q4, enable_q8, cnt8, rollover_q8);
end

initial begin : initial_setup
	clk = 1;
	enable_q4 = 0;
	enable_q8 = 0;
	reset = 0;
end

always #5 clk = ~clk;

initial begin : stimulus
	#10 reset = 1;
	#10 reset = 0;

	enable_q4 = 1;
	for (int i=0; i < 20; i++) begin
		cnt_ref = i;
		while (cnt_ref > 15) 
			cnt_ref = cnt_ref - 16;
		if (cnt_ref !== cnt4) begin
			$display("ASSERT FAILED AT t=%0t IN %m, (%0d : %0d vs %0d)", $time, i, (i > 15) ? i-16 : i, cnt4);
			n_errors++;
		end
		#10;
	end
	enable_q4 = 0;

	#10 reset = 1;
	#10 reset = 0;

	enable_q8 = 1;
	for (int i=200; i < 240; i++) begin
		cnt_ref = i;
		while (cnt_ref > 220)
			cnt_ref = cnt_ref - 11;
		if (cnt_ref !== cnt8) begin
			$display("ASSERT FAILED AT t=%0t IN %m, (%0d : %0d vs %0d)", $time, i, (i > 220) ? i - 11 : i, cnt8);
			n_errors++;
		end
		#10;
	end
	enable_q8 = 0;
	#10;
	if (n_errors == 0) begin
		$display("-------------------------");
		$display("     test SUCCEEDED with no errors");
		$display("-------------------------");
	end else begin
		$display("-------------------------");
		$display("     test FAILED with %0d errors", n_errors);
		$display("-------------------------");
	end
	$stop;
end

endmodule : testbench