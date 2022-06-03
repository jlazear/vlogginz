`ifndef SYNCHRONIZER
	`define SYNCHRONIZER 1

module synchronizer 
	#(N=2,
		SYNC_HIGH=0)
	(
	input clk,    // Clock
	input reset,
	input in,
	output out
);

	logic [N-1 : 0] sr;

	always @(posedge clk) begin
		if (reset)
			sr <= SYNC_HIGH ? '1 : '0;
		else
			sr <= {sr, in};
	end

	assign out = sr[N-1];

endmodule

`endif