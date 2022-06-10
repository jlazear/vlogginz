`timescale 1ns/1ns

module testbench_ro;

localparam period = 10;
localparam WIDTH = 16;
localparam DEPTH = 4;
localparam DEPTH_RO = 4;

logic clk, reset;
enum {START, WRITE, READ, WRITE_RO, READ_RO, DONE} tb_state;

logic i_w_en, i_r_en, i_wro_en, o_r_valid;
logic [$clog2(DEPTH+DEPTH_RO)-1 : 0] i_r_addr;
logic [$clog2(DEPTH)-1 : 0] i_w_addr;
logic [WIDTH-1:0] i_w_value, o_r_value, temp;
logic [WIDTH-1:0] o_mem [DEPTH-1 : 0];
logic [WIDTH-1:0] i_mem_ro [DEPTH_RO-1 : 0];


register_block_w_ro #(
	.WIDTH   (WIDTH),
	.DEPTH   (DEPTH),
	.DEPTH_RO(DEPTH_RO)
	) u_register_block_w_ro (
	.clk      (clk),
	.reset    (reset),
	.i_w_en   (i_w_en),
	.i_w_addr (i_w_addr),
	.i_w_value(i_w_value),
	.i_r_en   (i_r_en),
	.i_r_addr (i_r_addr),
	.o_r_value(o_r_value),
	.o_r_valid(o_r_valid),
	.o_mem    (o_mem),
	.i_mem_ro (i_mem_ro),
	.i_wro_en (i_wro_en)
	);

initial begin
	tb_state <= START;
	reset <= '0;
	i_w_en <= '0;
	i_r_en <= '0;
	i_wro_en <= '0;
	i_r_addr <= '0;
	i_w_addr <= '0;
	i_w_value <= '0;
	for (int i=0; i < DEPTH_RO; i++) begin
		i_mem_ro[i] <= '0;
	end

	@(posedge clk) reset <= '1;
	@(posedge clk) reset <= '0;

	// test writing
	tb_state <= WRITE;
	for (int i=0; i < DEPTH; i++) begin
		@(posedge clk);
		temp = $urandom();
		i_w_value <= temp;
		i_w_en <= '1;
		i_w_addr <= i;
	end
	@(posedge clk);
	i_w_en <= '0;
	@(posedge clk);

	// test reading from rw
	tb_state <= READ;
	@(posedge clk);
	i_r_en <= '1;
	i_r_addr <= '0;
	@(posedge clk);
	i_r_en <= '0;

	// test writing to ro
	tb_state <= WRITE_RO;
	@(posedge clk);
	i_mem_ro[0] <= 16'h0123;
	i_mem_ro[1] <= 16'h4567;
	i_mem_ro[2] <= 16'h89ab;
	i_mem_ro[3] <= 16'hcdef;
	i_wro_en <= '1;

	@(posedge clk);
	i_wro_en <= '0;

	// test reading from ro
	tb_state <= READ_RO;
	@(posedge clk);
	i_r_en <= '1;
	i_r_addr <= 3'd6;
	@(posedge clk);
	i_r_en <= '0;



	tb_state <= DONE;
	#(10*period) $stop;
end

// clk block
initial begin
	clk <= '1;
	forever #(period/2) clk <= ~clk;
end

endmodule : testbench_ro