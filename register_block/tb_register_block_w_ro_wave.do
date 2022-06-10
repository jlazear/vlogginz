onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench_ro/tb_state
add wave -noupdate /testbench_ro/clk
add wave -noupdate /testbench_ro/reset
add wave -noupdate -divider READ
add wave -noupdate /testbench_ro/i_r_en
add wave -noupdate -radix hexadecimal /testbench_ro/i_r_addr
add wave -noupdate /testbench_ro/o_r_valid
add wave -noupdate -radix hexadecimal /testbench_ro/o_r_value
add wave -noupdate -divider WRITE
add wave -noupdate /testbench_ro/i_w_en
add wave -noupdate -radix hexadecimal /testbench_ro/i_w_addr
add wave -noupdate -radix hexadecimal /testbench_ro/i_w_value
add wave -noupdate -radix hexadecimal /testbench_ro/temp
add wave -noupdate -radix hexadecimal /testbench_ro/o_mem
add wave -noupdate -divider RP
add wave -noupdate /testbench_ro/i_wro_en
add wave -noupdate -radix hexadecimal /testbench_ro/i_mem_ro
add wave -noupdate -radix hexadecimal -childformat {{{/testbench_ro/u_register_block_w_ro/mem_ro[3]} -radix hexadecimal} {{/testbench_ro/u_register_block_w_ro/mem_ro[2]} -radix hexadecimal} {{/testbench_ro/u_register_block_w_ro/mem_ro[1]} -radix hexadecimal} {{/testbench_ro/u_register_block_w_ro/mem_ro[0]} -radix hexadecimal}} -expand -subitemconfig {{/testbench_ro/u_register_block_w_ro/mem_ro[3]} {-radix hexadecimal} {/testbench_ro/u_register_block_w_ro/mem_ro[2]} {-radix hexadecimal} {/testbench_ro/u_register_block_w_ro/mem_ro[1]} {-radix hexadecimal} {/testbench_ro/u_register_block_w_ro/mem_ro[0]} {-radix hexadecimal}} /testbench_ro/u_register_block_w_ro/mem_ro
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
WaveRestoreZoom {0 ns} {242 ns}
