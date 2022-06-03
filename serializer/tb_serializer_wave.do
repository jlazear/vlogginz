onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/tb_state
add wave -noupdate /testbench/clk
add wave -noupdate /testbench/reset
add wave -noupdate -divider SERIALIZER_BE
add wave -noupdate -radix hexadecimal /testbench/i_data
add wave -noupdate /testbench/i_dv
add wave -noupdate -radix hexadecimal /testbench/med_data
add wave -noupdate /testbench/med_dv
add wave -noupdate -divider DESERIALIZER_BE
add wave -noupdate -radix hexadecimal /testbench/o_data
add wave -noupdate /testbench/o_dv
add wave -noupdate -divider SERIALIZER_BE/2
add wave -noupdate -radix hexadecimal /testbench/i_data
add wave -noupdate /testbench/i_dv
add wave -noupdate -radix hexadecimal /testbench/med_data2
add wave -noupdate /testbench/med_dv2
add wave -noupdate -divider DESERIALIZER_BE/2
add wave -noupdate -radix hexadecimal /testbench/o_data2
add wave -noupdate /testbench/o_dv2
add wave -noupdate -divider SERIALIZER_LE
add wave -noupdate -radix hexadecimal /testbench/i_data
add wave -noupdate /testbench/i_dv
add wave -noupdate -radix hexadecimal /testbench/med_data3
add wave -noupdate /testbench/med_dv3
add wave -noupdate -divider DESERIALIZER_LE
add wave -noupdate -radix hexadecimal /testbench/o_data3
add wave -noupdate /testbench/o_dv3
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
WaveRestoreZoom {0 ns} {263 ns}
