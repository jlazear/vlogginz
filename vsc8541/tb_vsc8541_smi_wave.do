onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench_smi/tb_state
add wave -noupdate /testbench_smi/clk
add wave -noupdate /testbench_smi/i_reset
add wave -noupdate /testbench_smi/o_mdc
add wave -noupdate /testbench_smi/i_mode
add wave -noupdate /testbench_smi/i_en
add wave -noupdate -radix hexadecimal /testbench_smi/i_reg_addr
add wave -noupdate -radix hexadecimal /testbench_smi/i_phy_addr
add wave -noupdate /testbench_smi/io_mdio
add wave -noupdate /testbench_smi/ext_io_mdio
add wave -noupdate /testbench_smi/o_dv
add wave -noupdate -radix hexadecimal /testbench_smi/o_data
add wave -noupdate -divider MDIO
add wave -noupdate /testbench_smi/u_mdio/state
add wave -noupdate /testbench_smi/u_mdio/next_state
add wave -noupdate /testbench_smi/u_mdio/mdc_edge
add wave -noupdate -radix unsigned /testbench_smi/u_mdio/cnt
add wave -noupdate /testbench_smi/u_mdio/w_en
add wave -noupdate /testbench_smi/u_mdio/tx
add wave -noupdate /testbench_smi/u_mdio/rx
add wave -noupdate -radix hexadecimal /testbench_smi/u_mdio/read_data
add wave -noupdate -radix hexadecimal /testbench_smi/u_mdio/write_data
add wave -noupdate -divider EXT_MDIO
add wave -noupdate /testbench_smi/ext_io_mdio
add wave -noupdate /testbench_smi/ext_w_en
add wave -noupdate /testbench_smi/ext_tx
add wave -noupdate /testbench_smi/ext_rx
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {41500 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {61089 ns} {93857 ns}
