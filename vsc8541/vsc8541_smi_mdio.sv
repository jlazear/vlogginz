module vsc8541_smi_mdio (
	input clk,    // Clock
	input i_reset,
	input i_mdc,  // mdc clock from mdc_gen

	// register parameters
	input i_mode, // 1 = write, 0 = read
	input i_en,
	input [4:0] i_phy_addr,
	input [4:0] i_reg_addr,
	input [15:0] i_data,
	output o_dv,
	output [15:0] o_data,

	// mdio signal line
	inout io_mdio
);
	logic dv;

	// storage arrays
	logic [15:0] read_data, write_data;

	// mdio tristate buffer
	logic tx, rx, w_en; // read/write of io_mdio tristate, !w_en = high impedance
	assign io_mdio = w_en ? tx : 'z;
	assign rx = io_mdio;

	// mdc monitor
	logic prev_mdc;
	logic [1:0] mdc_edge;
	localparam HIGH = 2'b11, LOW = 2'b00, RISING = 2'b01, FALLING = 2'b10;
	assign mdc_edge = {prev_mdc, i_mdc};
	always_ff @(posedge clk)
		if (i_reset)
			prev_mdc <= '0;
		else
			prev_mdc <= i_mdc;


	// FSM
	localparam RESET_CNT = 4;  // only 2 strictly necessary, but be safe
	localparam SFD_CNT = 2;
	localparam MODE_CNT = 2;
	localparam PHYADDR_CNT = 5;
	localparam REGADDR_CNT = 5;
	localparam TA_CNT = 2;
	localparam READ_CNT = 16;
	localparam WRITE_CNT = 16;
	localparam [1:0] READ_MODE = 2'b01, WRITE_MODE = 2'b10;
	logic [3:0] cnt;
	enum {RESET, IDLE, WAIT, SFD, MODE, PHYADDRESS, REGADDRESS, TA, READ, WRITE} state, next_state;

	always_comb
		unique case (state)
			RESET: 	next_state = (cnt >= RESET_CNT-1) ? IDLE : RESET;
			IDLE: next_state = i_en ? WAIT : IDLE;
			WAIT: next_state = (mdc_edge == FALLING) ? SFD : WAIT;
			SFD: next_state = (cnt >= SFD_CNT-1 && mdc_edge == FALLING) ? MODE : SFD;
			MODE: next_state = (cnt >= MODE_CNT-1 && mdc_edge == FALLING) ? PHYADDRESS : MODE;
			PHYADDRESS: next_state = (cnt >= PHYADDR_CNT-1 && mdc_edge == FALLING) ? REGADDRESS : PHYADDRESS;
			REGADDRESS: next_state = (cnt >= REGADDR_CNT-1 && mdc_edge == FALLING) ? TA : REGADDRESS;
			TA: next_state = (cnt >= TA_CNT-1 && mdc_edge == FALLING) ? (i_mode ? WRITE : READ) : TA;
			READ: next_state = (cnt >= READ_CNT-1 && mdc_edge == FALLING) ? IDLE : READ;
			WRITE: next_state = (cnt >= WRITE_CNT-1 && mdc_edge == FALLING) ? IDLE : WRITE;
		endcase

	always_ff @(posedge clk)
		if (i_reset)
			state <= RESET;
		else
			state <= next_state;

	always_ff @(posedge clk) begin
		cnt <= cnt;
		read_data <= read_data;
		if (i_reset) begin
			cnt <= '0;
			read_data <= '0;
		end else if (state == RESET) begin
			if (mdc_edge == FALLING)
				cnt <= (cnt >= RESET_CNT-1) ? '0 : cnt + 1'b1;
		end else if (state == IDLE) begin
			cnt <= '0;
			write_data <= i_data;
		end else if (state == WAIT) begin
			cnt <= '0;
		end else if (state == SFD) begin
			if (mdc_edge == FALLING)
				cnt <= (cnt >= SFD_CNT-1) ? '0 : cnt + 1'b1;
		end else if (state == MODE) begin
			if (mdc_edge == FALLING)
				cnt <= (cnt >= MODE_CNT-1) ? '0 : cnt + 1'b1;			
		end else if (state == PHYADDRESS) begin
			if (mdc_edge == FALLING)
				cnt <= (cnt >= PHYADDR_CNT-1) ? '0 : cnt + 1'b1;
		end else if (state == REGADDRESS) begin
			if (mdc_edge == FALLING)
				cnt <= (cnt >= REGADDR_CNT-1) ? '0 : cnt + 1'b1;			
		end else if (state == TA) begin
			if (mdc_edge == FALLING)
				cnt <= (cnt >= TA_CNT-1) ? '0 : cnt + 1'b1;			
		end else if (state == READ) begin
			if (mdc_edge == RISING)
				read_data <= {read_data, rx};
			else if (mdc_edge == FALLING) begin
				cnt <= (cnt >= READ_CNT-1) ? '0 : cnt + 1'b1;
			end
		end else if (state == WRITE) begin
			if (mdc_edge == FALLING) begin
				cnt <= (cnt >= WRITE_CNT-1) ? '0 : cnt + 1'b1;
				write_data <= write_data << 1;
			end
		end
	end

	// FSM outputs
	always_comb begin
		if (i_reset) begin
			w_en = '0;
			tx = '0;
			dv = '0;
		end else if (state == RESET) begin
			w_en = '1;
			tx = '1;
			dv = '0;
		end else if (state == IDLE) begin
			w_en = '0;
			tx = '0;
			dv = '0;
		end else if (state == WAIT) begin
			w_en = '0;
			tx = '0;
			dv = '0;
		end else if (state == SFD) begin
			w_en = '1;
			tx = (cnt == 0) ? '0 : '1;
			dv = '0;
		end else if (state == MODE) begin
			w_en = '1;
			tx = i_mode ? WRITE_MODE[cnt[0]] : READ_MODE[cnt[0]];
			dv = '0;
		end else if (state == PHYADDRESS) begin
			w_en = '1;
			tx = i_phy_addr[PHYADDR_CNT - cnt - 1];
			dv = '0;
		end else if (state == REGADDRESS) begin
			w_en = '1;
			tx = i_reg_addr[REGADDR_CNT - cnt - 1];
			dv = '0;
		end else if (state == TA) begin
			w_en = i_mode ? '1 : !cnt;
			tx = !cnt;
			dv = '0;
		end else if (state == READ) begin
			w_en = '0;
			dv = (cnt >= READ_CNT-1) ? '1 : '0;
		end else if (state == WRITE) begin
			w_en = '1;
			tx = write_data[15];
			dv = '0;
		end
		
	end

	// module outputs
	assign o_data = read_data;
	assign o_dv = dv;

endmodule : vsc8541_smi_mdio