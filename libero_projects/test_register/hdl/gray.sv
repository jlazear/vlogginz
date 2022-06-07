module gray 
	#(parameter WIDTH=8)
	(
	input [WIDTH-1 : 0] in, 
	output logic [WIDTH-1 : 0] out	
);

	always_comb out = in ^ (in >> 1);

endmodule