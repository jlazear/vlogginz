`timescale 1ns/1ns

module testbench_smi;

localparam period = 10;  // 100 MHz clock
localparam DIVISOR = 4;

enum {START, RESET, READ_CONFIG, READ_RX, IDLE, WRITE_CONFIG, WRITE_TX, DONE} tb_state;

logic clk, i_reset;
logic o_mdc, i_mode, i_en, o_dv;
logic [4:0] i_reg_addr, i_phy_addr;
logic [15:0] o_data, i_data;
wire io_mdio;

// external tri-state
wire ext_io_mdio;
logic ext_rx, ext_tx, ext_w_en;
assign ext_io_mdio = ext_w_en ? ext_tx : 'z;
assign ext_rx = ext_w_en ? ext_tx : io_mdio;

vsc8541_smi_mdc_gen #(
	.DIVISOR(DIVISOR)
	) u_mdc_gen (
	.clk    (clk),
	.i_reset(i_reset),
	.o_mdc  (o_mdc)
	);

vsc8541_smi_mdio u_mdio (
	.clk       (clk),
	.i_reset   (i_reset),
	.i_mdc     (o_mdc),

	.i_mode    (i_mode),
	.i_en      (i_en),
	.i_reg_addr(i_reg_addr),
	.i_phy_addr(i_phy_addr),
	.i_data    (i_data),
	.o_dv      (o_dv),
	.o_data    (o_data),

	.io_mdio   (io_mdio)
	);

assign io_mdio = ext_io_mdio;
// assign ext_io_mdio = io_mdio;

task read(
	input [4:0] phy_addr = 5'h05,
	input [4:0] reg_addr = 5'h1b,
	input [15:0] data = 16'h5aa5
	);

	@(posedge clk);
	tb_state <= READ_CONFIG;
	i_en <= '1;
	i_phy_addr <= phy_addr;
	i_reg_addr <= reg_addr;

	@(posedge clk);
	i_en <= '0;

	tb_state <= READ_RX;
	repeat(16)
		@(negedge o_mdc);
	ext_w_en <= '1;
	repeat(16) begin
		@(negedge o_mdc); 
		ext_tx <= data[15];
		data <= data << 1;
	end

	@(negedge o_mdc);
	ext_w_en <= '0;

	repeat(8)
		@(posedge o_mdc);

endtask : read

task write(
	input [4:0] phy_addr = 5'h05,
	input [4:0] reg_addr = 5'h1b,
	input [15:0] data = 16'ha55a
	);

	@(posedge clk);
	tb_state <= WRITE_CONFIG;
	i_en <= '1;
	i_mode <= '1;
	i_phy_addr <= phy_addr;
	i_reg_addr <= reg_addr;
	i_data <= data;

	@(posedge clk);
	i_en <= '0;

	tb_state <= WRITE_TX;
	repeat(32)
		@(negedge o_mdc);

	repeat(8)
		@(posedge o_mdc);

endtask : write

initial begin
	tb_state <= START;
	i_reset <= '0;
	i_mode <= '0;
	i_en <= '0;
	i_reg_addr <= '0;
	i_phy_addr <= '0;
	i_data <= '0;

	ext_w_en <= '0;
	ext_tx <= '0;

	@(posedge clk) i_reset <= '1;
	@(posedge clk);
	@(posedge clk);
	@(posedge clk) i_reset <= '0;

	tb_state <= RESET;
	repeat(10)
		@(posedge o_mdc);

	read();

	tb_state <= IDLE;
	repeat(10)
		@(posedge o_mdc);

	write();


	// @(posedge clk);
	// tb_state <= READ_CONFIG;
	// i_en <= '1;
	// i_phy_addr <= 5'h05;
	// i_reg_addr <= 5'h1b;

	// @(posedge clk);
	// i_en <= '0;

	// tb_state <= READ_RX;
	// repeat(16)
	// 	@(negedge o_mdc);
	// ext_w_en <= '1;
	// repeat(16)
	// 	@(negedge o_mdc) ext_tx <= ~ext_tx;

	// @(negedge o_mdc);
	// ext_w_en <= '0;

	// repeat(8)
	// 	@(posedge o_mdc);

	@(posedge clk) tb_state <= DONE;
	repeat(10)
		@(posedge o_mdc);
	$stop;


end

// clk block
initial begin
	clk <= '1;
	forever #(period/2) clk <= ~clk;
end

endmodule : testbench_smi