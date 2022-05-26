module vsc8541_register 
	#(
		parameter DIVISOR=2)
	(
	input clk,    // Clock
	input i_reset,
	input [4:0] i_register,
	input i_read_en,
	output [14:0] o_data,
	output o_dv,
	inout io_mdio,
	inout o_mdc
);

	wire _x;

	// clock divider to generate mdc
	localparam MDC_SUBCNT_WIDTH = $clog2(DIVISOR);

	counter #(
		.WIDTH    (MDC_SUBCNT_WIDTH),
		.MAX_VALUE(DIVISOR-1        )
	) q_dclk_counter (
		.clk     (clk        ),
		.reset   (i_reset),
		.enable  ('1         ),
		.cnt     (mdc_subcnt),
		.rollover(_x    )
	);

	assign o_mdc = !(mdc_subcnt < DIVISOR>>1);

	// mdio state machine
	enum {RESET, IDLE, SFD0, SFD1, READ0, READ1, PHYADDRESS, REGADDRESS, TA0, TA1, REGDATA} state, next_state;
	localparam RESET_CNT = 2;
	logic [$clog2(RESET_CNT) : 0] reset_cnt;
	localparam PHYADDRESS_CNT = 5;
	logic [$clog2(PHYADDRESS_CNT) : 0] phyaddress_cnt;
	localparam REGADDRESS_CNT = 5;
	logic [$clog2(REGADDRESS_CNT) : 0] regaddress_cnt;
	localparam REGDATA_CNT = 16;
	logic [$clog2(REGDATA_CNT) : 0] regdata_cnt;

	logic mdio;
	wire i_mdio;
	logic dv;
	logic [14:0] data;
	logic [4:0] reg_addr;

	always_comb begin
		unique case (state)
			RESET: next_state = (reset_cnt < RESET_CNT) ? RESET : IDLE;
			IDLE: next_state = i_read_en ? SFD0 : IDLE;
			SFD0: next_state = SFD1;
			SFD1: next_state = READ0;
			READ0: next_state = READ1;
			READ1: next_state = PHYADDRESS;
			PHYADDRESS: next_state = (phyaddress_cnt < PHYADDRESS_CNT-1) ? PHYADDRESS : REGADDRESS;
			REGADDRESS: next_state = (regaddress_cnt < REGADDRESS_CNT-1) ? REGADDRESS : TA0;
			TA0: next_state = TA1;
			TA1: next_state = REGDATA;
			REGDATA: next_state = (regdata_cnt < REGDATA_CNT-1) ? REGDATA : IDLE;
		endcase
	end

	always_ff @(posedge clk) begin
		if (i_reset)
			state <= RESET;
		else if (mdc_subcnt == DIVISOR>>1)
			state <= next_state;
		else
			state <= state;
	end

	always_ff @(posedge clk) begin
		mdio <= mdio;
		dv <= dv;
		data <= data;
		reset_cnt <= reset_cnt;
		phyaddress_cnt <= phyaddress_cnt;
		regaddress_cnt <= regaddress_cnt;
		regdata_cnt <= regdata_cnt;
		reg_addr <= reg_addr;
		if (i_reset) begin
			reg_addr <= '0;
			mdio <= 'z;
			dv <= '0;
			data <= '0;
			reset_cnt <= '0;
			phyaddress_cnt <= '0;
			regaddress_cnt <= '0;
			regdata_cnt <= '0;
			reg_addr <= '0;
		end else if (mdc_subcnt == DIVISOR>>1) begin
			mdio <= 'z;
			dv <= '0;
			data <= '0;
			reset_cnt <= '0;
			phyaddress_cnt <= '0;
			regaddress_cnt <= '0;
			regdata_cnt <= '0;
			reg_addr <= reg_addr;
			if (state == RESET) begin
				reset_cnt <= reset_cnt + 1'b1;
			end else if (state == IDLE) begin
				reg_addr <= i_read_en ? i_register : '0;
			end else if (state == SFD0) begin
				mdio <= '0;
			end else if (state == SFD1) begin
				mdio <= '1;
			end else if (state == READ0) begin
				mdio <= '1;
			end else if (state == READ1) begin
				mdio <= '0;
			end else if (state == PHYADDRESS) begin
				mdio <= '0;
				phyaddress_cnt <= phyaddress_cnt + 1'b1;
			end else if (state == REGADDRESS) begin
				mdio <= reg_addr[0];
				reg_addr <= reg_addr >> 1;
				regaddress_cnt <= regaddress_cnt + 1'b1;
			end else if (state == TA0) begin
				mdio <= 'z;
			end else if (state == REGDATA) begin
				regdata_cnt <= regdata_cnt + 1'b1;
				data <= {data[14:0], i_mdio};
				dv <= (regdata_cnt >= REGDATA_CNT - 1) ? '1 : '0;
			end
		end
	end

	assign o_data = data;
	assign o_dv = dv;
	assign io_mdio = (state == IDLE || state == REGDATA) ? 'z : mdio;
	assign i_mdio = io_mdio;

endmodule