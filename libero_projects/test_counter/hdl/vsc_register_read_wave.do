onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench_vsc_register_read/tb_state
add wave -noupdate /testbench_vsc_register_read/clk
add wave -noupdate /testbench_vsc_register_read/reset
add wave -noupdate /testbench_vsc_register_read/tx
add wave -noupdate /testbench_vsc_register_read/busy
add wave -noupdate /testbench_vsc_register_read/mdc
add wave -noupdate /testbench_vsc_register_read/mdio
add wave -noupdate -divider VSC_REG_READ
add wave -noupdate /testbench_vsc_register_read/dut/state
add wave -noupdate /testbench_vsc_register_read/dut/next_state
add wave -noupdate /testbench_vsc_register_read/dut/rollover
add wave -noupdate /testbench_vsc_register_read/dut/read_en
add wave -noupdate -radix hexadecimal /testbench_vsc_register_read/dut/data
add wave -noupdate -radix hexadecimal /testbench_vsc_register_read/dut/mem
add wave -noupdate -radix hexadecimal /testbench_vsc_register_read/dut/uart_data
add wave -noupdate /testbench_vsc_register_read/dut/uart_dv
add wave -noupdate -radix unsigned /testbench_vsc_register_read/dut/tx_cnt
add wave -noupdate -radix unsigned /testbench_vsc_register_read/dut/load_cnt
add wave -noupdate /testbench_vsc_register_read/dut/tx
add wave -noupdate -divider COUNTER
add wave -noupdate /testbench_vsc_register_read/dut/u_counter/enable
add wave -noupdate -radix unsigned /testbench_vsc_register_read/dut/u_counter/cnt
add wave -noupdate /testbench_vsc_register_read/dut/u_counter/rollover
add wave -noupdate -radix unsigned /testbench_vsc_register_read/dut/u_counter/_cnt
add wave -noupdate /testbench_vsc_register_read/dut/u_counter/_rollover
add wave -noupdate -divider VSC_INTERFACE
add wave -noupdate /testbench_vsc_register_read/dut/u_vsc/state
add wave -noupdate /testbench_vsc_register_read/dut/u_vsc/next_state
add wave -noupdate /testbench_vsc_register_read/dut/u_vsc/o_mdc
add wave -noupdate /testbench_vsc_register_read/dut/u_vsc/mdc_subcnt
add wave -noupdate /testbench_vsc_register_read/dut/u_vsc/mdio
add wave -noupdate /testbench_vsc_register_read/dut/u_vsc/dv
add wave -noupdate -radix hexadecimal /testbench_vsc_register_read/dut/u_vsc/data
add wave -noupdate -divider UART
add wave -noupdate /testbench_vsc_register_read/dut/u_uart_tx/state
add wave -noupdate /testbench_vsc_register_read/dut/u_uart_tx/next_state
add wave -noupdate /testbench_vsc_register_read/dut/u_uart_tx/dclk
add wave -noupdate /testbench_vsc_register_read/dut/u_uart_tx/dclk_subcnt
add wave -noupdate /testbench_vsc_register_read/dut/u_uart_tx/i_dv
add wave -noupdate -radix hexadecimal /testbench_vsc_register_read/dut/u_uart_tx/mem
add wave -noupdate /testbench_vsc_register_read/dut/u_uart_tx/tx
add wave -noupdate /testbench_vsc_register_read/dut/u_uart_tx/o_busy
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {10549 ns} 0}
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
WaveRestoreZoom {31191 ns} {31851 ns}
