onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/tb_state
add wave -noupdate /testbench/clk
add wave -noupdate /testbench/reset
add wave -noupdate /testbench/o_reset
add wave -noupdate /testbench/i_buttons
add wave -noupdate /testbench/o_buttons
add wave -noupdate -radix hexadecimal /testbench/i_cmux_in
add wave -noupdate -radix hexadecimal /testbench/o_cmux_out
add wave -noupdate -divider DEBUG
add wave -noupdate /testbench/dut/i_reset
add wave -noupdate /testbench/dut/i_buttons
add wave -noupdate /testbench/dut/buttons
add wave -noupdate /testbench/dut/o_buttons
add wave -noupdate -radix hexadecimal /testbench/dut/i_cmux_in
add wave -noupdate -radix hexadecimal /testbench/dut/o_cmux_out
add wave -noupdate /testbench/dut/o_reset
add wave -noupdate /testbench/dut/reset
add wave -noupdate -radix hexadecimal /testbench/dut/mux_out
add wave -noupdate -divider DEBOUNCER0
add wave -noupdate /testbench/dut/u_debouncer_b0/state
add wave -noupdate /testbench/dut/u_debouncer_b0/next_state
add wave -noupdate /testbench/dut/u_debouncer_b0/i_reset
add wave -noupdate /testbench/dut/u_debouncer_b0/i_in
add wave -noupdate /testbench/dut/u_debouncer_b0/o_out
add wave -noupdate -radix unsigned /testbench/dut/u_debouncer_b0/cnt
add wave -noupdate -divider DEBOUNCER1
add wave -noupdate /testbench/dut/u_debouncer_b1/state
add wave -noupdate /testbench/dut/u_debouncer_b1/next_state
add wave -noupdate /testbench/dut/u_debouncer_b1/i_reset
add wave -noupdate /testbench/dut/u_debouncer_b1/i_in
add wave -noupdate /testbench/dut/u_debouncer_b1/o_out
add wave -noupdate -radix unsigned /testbench/dut/u_debouncer_b1/cnt
add wave -noupdate -divider CMUX
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
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
WaveRestoreZoom {0 ns} {1976 ns}
