create_clock -name {50MHz_clk} -period 20 -waveform {0 10 } [ get_pins { OSC_C0_0/OSC_C0_0/I_RCOSC_25_50MHZ/CLKOUT } ]
