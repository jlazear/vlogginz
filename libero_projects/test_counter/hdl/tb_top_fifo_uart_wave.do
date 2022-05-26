onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench_top_fifo_uart/tb_state
add wave -noupdate /testbench_top_fifo_uart/clk
add wave -noupdate /testbench_top_fifo_uart/reset
add wave -noupdate /testbench_top_fifo_uart/enable
add wave -noupdate /testbench_top_fifo_uart/txclk
add wave -noupdate /testbench_top_fifo_uart/tx
add wave -noupdate -divider COUNTER
add wave -noupdate -radix unsigned /testbench_top_fifo_uart/dut/u_counter/cnt
add wave -noupdate /testbench_top_fifo_uart/dut/u_counter/rollover
add wave -noupdate -divider PULSE_EXTENDER
add wave -noupdate /testbench_top_fifo_uart/dut/u_pulse_extender/i_x
add wave -noupdate /testbench_top_fifo_uart/dut/u_pulse_extender/o_x
add wave -noupdate -divider FIFO_UART
add wave -noupdate /testbench_top_fifo_uart/dut/u_fifo_uart/i_w_en
add wave -noupdate -radix hexadecimal /testbench_top_fifo_uart/dut/u_fifo_uart/i_w_data
add wave -noupdate /testbench_top_fifo_uart/dut/u_fifo_uart/o_tx
add wave -noupdate /testbench_top_fifo_uart/dut/u_fifo_uart/o_empty
add wave -noupdate /testbench_top_fifo_uart/dut/u_fifo_uart/busy
add wave -noupdate /testbench_top_fifo_uart/dut/u_fifo_uart/r_en
add wave -noupdate -radix hexadecimal /testbench_top_fifo_uart/dut/u_fifo_uart/r_data
add wave -noupdate -radix hexadecimal /testbench_top_fifo_uart/dut/u_fifo_uart/data
add wave -noupdate -divider FIFO
add wave -noupdate /testbench_top_fifo_uart/dut/u_fifo_uart/u_fifo/mem
add wave -noupdate -radix unsigned /testbench_top_fifo_uart/dut/u_fifo_uart/u_fifo/ptr1
add wave -noupdate -radix unsigned /testbench_top_fifo_uart/dut/u_fifo_uart/u_fifo/ptr2
add wave -noupdate -radix unsigned /testbench_top_fifo_uart/dut/u_fifo_uart/u_fifo/n_elem
add wave -noupdate /testbench_top_fifo_uart/dut/u_fifo_uart/u_fifo/first
add wave -noupdate /testbench_top_fifo_uart/dut/u_fifo_uart/u_fifo/i_r_en
add wave -noupdate /testbench_top_fifo_uart/dut/u_fifo_uart/u_fifo/o_r_data
add wave -noupdate -divider UART
add wave -noupdate /testbench_top_fifo_uart/dut/u_fifo_uart/u_uart/state
add wave -noupdate /testbench_top_fifo_uart/dut/u_fifo_uart/u_uart/next_state
add wave -noupdate /testbench_top_fifo_uart/dut/u_fifo_uart/u_uart/dclk
add wave -noupdate -radix hexadecimal /testbench_top_fifo_uart/dut/u_fifo_uart/u_uart/mem
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1205260 ns} 0}
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
WaveRestoreZoom {1196436 ns} {1214084 ns}
