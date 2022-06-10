`ifndef VSC8541_SMI_MDC_GEN
	`define VSC8541_SMI_MDC_GEN 1

// `include "../counter/counter.sv"

module vsc8541_smi_mdc_gen 
	#(
		DIVISOR=100
	) (
	input clk,    // Clock
	input i_reset,
	output o_mdc
	);

	localparam MDC_SUBCNT_WIDTH = $clog2(DIVISOR);

	logic [MDC_SUBCNT_WIDTH-1 : 0] mdc_subcnt;
	logic rollover;

	// clock divider to generate dclk
	counter #(
		.WIDTH    (MDC_SUBCNT_WIDTH),
		.MAX_VALUE(DIVISOR-1        )
	) u_mdc_counter (
		.clk     (clk        ),
		.reset   (i_reset),
		.enable  ('1         ),
		.cnt     (mdc_subcnt),
		.rollover(rollover)
	);

	assign o_mdc = (mdc_subcnt < DIVISOR>>1);	

endmodule : vsc8541_smi_mdc_gen

`endif