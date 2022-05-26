onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench_fifo_uart/tb_state
add wave -noupdate /testbench_fifo_uart/clk
add wave -noupdate /testbench_fifo_uart/reset
add wave -noupdate /testbench_fifo_uart/enable
add wave -noupdate /testbench_fifo_uart/txclk
add wave -noupdate /testbench_fifo_uart/w_en
add wave -noupdate -radix hexadecimal /testbench_fifo_uart/w_data
add wave -noupdate /testbench_fifo_uart/tx
add wave -noupdate /testbench_fifo_uart/aempty
add wave -noupdate /testbench_fifo_uart/empty
add wave -noupdate -divider FIFO
add wave -noupdate -radix hexadecimal -childformat {{{/testbench_fifo_uart/dut/u_fifo/mem[0]} -radix hexadecimal} {{/testbench_fifo_uart/dut/u_fifo/mem[1]} -radix hexadecimal} {{/testbench_fifo_uart/dut/u_fifo/mem[2]} -radix hexadecimal} {{/testbench_fifo_uart/dut/u_fifo/mem[3]} -radix hexadecimal} {{/testbench_fifo_uart/dut/u_fifo/mem[4]} -radix hexadecimal} {{/testbench_fifo_uart/dut/u_fifo/mem[5]} -radix hexadecimal} {{/testbench_fifo_uart/dut/u_fifo/mem[6]} -radix hexadecimal} {{/testbench_fifo_uart/dut/u_fifo/mem[7]} -radix hexadecimal} {{/testbench_fifo_uart/dut/u_fifo/mem[8]} -radix hexadecimal} {{/testbench_fifo_uart/dut/u_fifo/mem[9]} -radix hexadecimal} {{/testbench_fifo_uart/dut/u_fifo/mem[10]} -radix hexadecimal} {{/testbench_fifo_uart/dut/u_fifo/mem[11]} -radix hexadecimal} {{/testbench_fifo_uart/dut/u_fifo/mem[12]} -radix hexadecimal} {{/testbench_fifo_uart/dut/u_fifo/mem[13]} -radix hexadecimal} {{/testbench_fifo_uart/dut/u_fifo/mem[14]} -radix hexadecimal} {{/testbench_fifo_uart/dut/u_fifo/mem[15]} -radix hexadecimal}} -subitemconfig {{/testbench_fifo_uart/dut/u_fifo/mem[0]} {-height 15 -radix hexadecimal} {/testbench_fifo_uart/dut/u_fifo/mem[1]} {-height 15 -radix hexadecimal} {/testbench_fifo_uart/dut/u_fifo/mem[2]} {-height 15 -radix hexadecimal} {/testbench_fifo_uart/dut/u_fifo/mem[3]} {-height 15 -radix hexadecimal} {/testbench_fifo_uart/dut/u_fifo/mem[4]} {-height 15 -radix hexadecimal} {/testbench_fifo_uart/dut/u_fifo/mem[5]} {-height 15 -radix hexadecimal} {/testbench_fifo_uart/dut/u_fifo/mem[6]} {-height 15 -radix hexadecimal} {/testbench_fifo_uart/dut/u_fifo/mem[7]} {-height 15 -radix hexadecimal} {/testbench_fifo_uart/dut/u_fifo/mem[8]} {-height 15 -radix hexadecimal} {/testbench_fifo_uart/dut/u_fifo/mem[9]} {-height 15 -radix hexadecimal} {/testbench_fifo_uart/dut/u_fifo/mem[10]} {-height 15 -radix hexadecimal} {/testbench_fifo_uart/dut/u_fifo/mem[11]} {-height 15 -radix hexadecimal} {/testbench_fifo_uart/dut/u_fifo/mem[12]} {-height 15 -radix hexadecimal} {/testbench_fifo_uart/dut/u_fifo/mem[13]} {-height 15 -radix hexadecimal} {/testbench_fifo_uart/dut/u_fifo/mem[14]} {-height 15 -radix hexadecimal} {/testbench_fifo_uart/dut/u_fifo/mem[15]} {-height 15 -radix hexadecimal}} /testbench_fifo_uart/dut/u_fifo/mem
add wave -noupdate -radix unsigned /testbench_fifo_uart/dut/u_fifo/ptr1
add wave -noupdate -radix unsigned /testbench_fifo_uart/dut/u_fifo/ptr2
add wave -noupdate -radix unsigned /testbench_fifo_uart/dut/u_fifo/n_elem
add wave -noupdate /testbench_fifo_uart/dut/u_fifo/first
add wave -noupdate -radix hexadecimal /testbench_fifo_uart/dut/u_fifo/o_r_data
add wave -noupdate -divider CONTROLLER
add wave -noupdate /testbench_fifo_uart/dut/u_controller/state
add wave -noupdate /testbench_fifo_uart/dut/u_controller/next_state
add wave -noupdate /testbench_fifo_uart/dut/u_controller/busy_edge
add wave -noupdate /testbench_fifo_uart/dut/u_controller/r_en
add wave -noupdate /testbench_fifo_uart/dut/u_controller/dv
add wave -noupdate -radix hexadecimal /testbench_fifo_uart/dut/u_controller/i_r_data
add wave -noupdate -radix hexadecimal -childformat {{{/testbench_fifo_uart/dut/u_controller/mem[7]} -radix hexadecimal} {{/testbench_fifo_uart/dut/u_controller/mem[6]} -radix hexadecimal} {{/testbench_fifo_uart/dut/u_controller/mem[5]} -radix hexadecimal} {{/testbench_fifo_uart/dut/u_controller/mem[4]} -radix hexadecimal} {{/testbench_fifo_uart/dut/u_controller/mem[3]} -radix hexadecimal} {{/testbench_fifo_uart/dut/u_controller/mem[2]} -radix hexadecimal} {{/testbench_fifo_uart/dut/u_controller/mem[1]} -radix hexadecimal} {{/testbench_fifo_uart/dut/u_controller/mem[0]} -radix hexadecimal}} -subitemconfig {{/testbench_fifo_uart/dut/u_controller/mem[7]} {-height 15 -radix hexadecimal} {/testbench_fifo_uart/dut/u_controller/mem[6]} {-height 15 -radix hexadecimal} {/testbench_fifo_uart/dut/u_controller/mem[5]} {-height 15 -radix hexadecimal} {/testbench_fifo_uart/dut/u_controller/mem[4]} {-height 15 -radix hexadecimal} {/testbench_fifo_uart/dut/u_controller/mem[3]} {-height 15 -radix hexadecimal} {/testbench_fifo_uart/dut/u_controller/mem[2]} {-height 15 -radix hexadecimal} {/testbench_fifo_uart/dut/u_controller/mem[1]} {-height 15 -radix hexadecimal} {/testbench_fifo_uart/dut/u_controller/mem[0]} {-height 15 -radix hexadecimal}} /testbench_fifo_uart/dut/u_controller/mem
add wave -noupdate -radix hexadecimal /testbench_fifo_uart/dut/u_controller/o_data
add wave -noupdate -divider UART
add wave -noupdate /testbench_fifo_uart/dut/u_uart/state
add wave -noupdate /testbench_fifo_uart/dut/u_uart/next_state
add wave -noupdate /testbench_fifo_uart/dut/u_uart/dclk
add wave -noupdate -radix decimal /testbench_fifo_uart/dut/u_uart/dclk_subcnt
add wave -noupdate /testbench_fifo_uart/dut/u_uart/i_dv
add wave -noupdate -radix hexadecimal -childformat {{{/testbench_fifo_uart/dut/u_uart/mem[7]} -radix hexadecimal} {{/testbench_fifo_uart/dut/u_uart/mem[6]} -radix hexadecimal} {{/testbench_fifo_uart/dut/u_uart/mem[5]} -radix hexadecimal} {{/testbench_fifo_uart/dut/u_uart/mem[4]} -radix hexadecimal} {{/testbench_fifo_uart/dut/u_uart/mem[3]} -radix hexadecimal} {{/testbench_fifo_uart/dut/u_uart/mem[2]} -radix hexadecimal} {{/testbench_fifo_uart/dut/u_uart/mem[1]} -radix hexadecimal} {{/testbench_fifo_uart/dut/u_uart/mem[0]} -radix hexadecimal}} -subitemconfig {{/testbench_fifo_uart/dut/u_uart/mem[7]} {-height 15 -radix hexadecimal} {/testbench_fifo_uart/dut/u_uart/mem[6]} {-height 15 -radix hexadecimal} {/testbench_fifo_uart/dut/u_uart/mem[5]} {-height 15 -radix hexadecimal} {/testbench_fifo_uart/dut/u_uart/mem[4]} {-height 15 -radix hexadecimal} {/testbench_fifo_uart/dut/u_uart/mem[3]} {-height 15 -radix hexadecimal} {/testbench_fifo_uart/dut/u_uart/mem[2]} {-height 15 -radix hexadecimal} {/testbench_fifo_uart/dut/u_uart/mem[1]} {-height 15 -radix hexadecimal} {/testbench_fifo_uart/dut/u_uart/mem[0]} {-height 15 -radix hexadecimal}} /testbench_fifo_uart/dut/u_uart/mem
add wave -noupdate /testbench_fifo_uart/dut/u_uart/tx
add wave -noupdate /testbench_fifo_uart/dut/u_uart/o_busy
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {21600 ns} 0}
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
WaveRestoreZoom {839951 ns} {1133689 ns}
