`timescale 1ns/1ns

module testbench;

localparam period = 10;
localparam WIDTH = 8;
localparam NUM_WORDS = 4;
// localparam LITTLE_ENDIAN = 0;

logic clk, reset;
enum {START, DONE} tb_state;

logic [7:0] med_data, med_data2, med_data3;
logic [31:0] i_data, o_data, o_data2, o_data3;
logic i_dv, med_dv, o_dv, med_dv2, o_dv2, o_dv3;


serializer #(
	.WIDTH        (WIDTH        ),
	.NUM_WORDS    (NUM_WORDS    ),
	.LITTLE_ENDIAN(0)
) u_serializer (
	.clk    (clk     ),
	.i_reset(reset   ),
	.i_data (i_data  ),
	.i_dv   (i_dv    ),
	.o_data (med_data),
	.o_dv   (med_dv  )
);

deserializer #(
	.WIDTH        (WIDTH),
	.NUM_WORDS    (NUM_WORDS),
	.LITTLE_ENDIAN(0)	
	) u_deserializer (
	.clk			(clk),
	.i_reset      (reset),
	.i_data       (med_data),
	.i_dv         (med_dv),
	.o_data       (o_data),
	.o_dv         (o_dv)
	);


serializer #(
	.WIDTH        (WIDTH        ),
	.NUM_WORDS    (NUM_WORDS/2  ),
	.LITTLE_ENDIAN(0)
) u_serializer2 (
	.clk    (clk     ),
	.i_reset(reset   ),
	.i_data (i_data  ),
	.i_dv   (i_dv    ),
	.o_data (med_data2),
	.o_dv   (med_dv2  )
);

deserializer #(
	.WIDTH        (WIDTH),
	.NUM_WORDS    (NUM_WORDS),
	.LITTLE_ENDIAN(0)	
	) u_deserializer2 (
	.clk			(clk),
	.i_reset      (reset),
	.i_data       (med_data2),
	.i_dv         (med_dv2),
	.o_data       (o_data2),
	.o_dv         (o_dv2)
	);


serializer #(
	.WIDTH        (WIDTH        ),
	.NUM_WORDS    (NUM_WORDS    ),
	.LITTLE_ENDIAN(1)
) u_serializer3 (
	.clk    (clk     ),
	.i_reset(reset   ),
	.i_data (i_data  ),
	.i_dv   (i_dv    ),
	.o_data (med_data3),
	.o_dv   (med_dv3  )
);

deserializer #(
	.WIDTH        (WIDTH),
	.NUM_WORDS    (NUM_WORDS),
	.LITTLE_ENDIAN(1)	
	) u_deserializer3 (
	.clk			(clk),
	.i_reset      (reset),
	.i_data       (med_data3),
	.i_dv         (med_dv3),
	.o_data       (o_data3),
	.o_dv         (o_dv3)
	);


initial begin
	tb_state <= START;
	reset <= '0;
	i_data <= '0;
	i_dv <= '0;

	@(posedge clk) reset <= '1;
	@(posedge clk) reset <= '0;

	@(posedge clk);
	i_data <= 32'h12345678;
	i_dv <= '1;
	@(posedge clk);
	i_dv <= '0;

	repeat(10)
		@(posedge clk);

	@(posedge clk);
	i_data <= 32'h9abcdef0;
	i_dv <= '1;
	@(posedge clk);
	i_dv <= '0;



	tb_state <= DONE;
	#(10*period) $stop;
end

// clk block
initial begin
	clk <= '1;
	forever #(period/2) clk <= ~clk;
end

endmodule : testbench