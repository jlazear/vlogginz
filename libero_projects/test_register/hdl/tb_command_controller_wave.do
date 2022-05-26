onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/tb_state
add wave -noupdate /testbench/clk
add wave -noupdate /testbench/reset
add wave -noupdate -radix hexadecimal /testbench/data
add wave -noupdate /testbench/dv
add wave -noupdate -radix hexadecimal /testbench/w_addr
add wave -noupdate -radix hexadecimal /testbench/w_data
add wave -noupdate /testbench/w_en
add wave -noupdate -divider CONTROLLER
add wave -noupdate /testbench/dut/state
add wave -noupdate /testbench/dut/next_state
add wave -noupdate /testbench/dut/dv_edge
add wave -noupdate -radix unsigned /testbench/dut/value_cnt
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {510 ns} 0}
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
WaveRestoreZoom {526 ns} {846 ns}
