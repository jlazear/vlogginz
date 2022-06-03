onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench_top_uart_test/tb_state
add wave -noupdate /testbench_top_uart_test/clk
add wave -noupdate /testbench_top_uart_test/reset
add wave -noupdate /testbench_top_uart_test/txclk
add wave -noupdate /testbench_top_uart_test/i_tx_en
add wave -noupdate /testbench_top_uart_test/w_en
add wave -noupdate -radix hexadecimal /testbench_top_uart_test/w_data
add wave -noupdate /testbench_top_uart_test/ext_o_dv
add wave -noupdate -radix hexadecimal /testbench_top_uart_test/ext_o_data
add wave -noupdate -radix hexadecimal /testbench_top_uart_test/final_data
add wave -noupdate /testbench_top_uart_test/final_dv
add wave -noupdate -divider EXT_FIFO_TX
add wave -noupdate /testbench_top_uart_test/u_fifo_uart_tx/u_controller/state
add wave -noupdate /testbench_top_uart_test/u_fifo_uart_tx/u_controller/next_state
add wave -noupdate /testbench_top_uart_test/u_fifo_uart_tx/i_w_en
add wave -noupdate -radix hexadecimal /testbench_top_uart_test/u_fifo_uart_tx/i_w_data
add wave -noupdate /testbench_top_uart_test/u_fifo_uart_tx/u_uart/dclk
add wave -noupdate /testbench_top_uart_test/u_fifo_uart_tx/tx
add wave -noupdate /testbench_top_uart_test/u_fifo_uart_tx/busy
add wave -noupdate -divider UART_RX
add wave -noupdate /testbench_top_uart_test/dut/u_uart_rx/state
add wave -noupdate /testbench_top_uart_test/dut/u_uart_rx/next_state
add wave -noupdate /testbench_top_uart_test/dut/u_uart_rx/dclk_reset
add wave -noupdate /testbench_top_uart_test/dut/u_uart_rx/dclk
add wave -noupdate /testbench_top_uart_test/dut/u_uart_rx/sampling
add wave -noupdate /testbench_top_uart_test/dut/u_uart_rx/sync_rx
add wave -noupdate -radix hexadecimal /testbench_top_uart_test/dut/u_uart_rx/o_data
add wave -noupdate /testbench_top_uart_test/dut/u_uart_rx/o_data_valid
add wave -noupdate -divider DESERIALIZER
add wave -noupdate -radix hexadecimal /testbench_top_uart_test/dut/u_deserializer/i_data
add wave -noupdate /testbench_top_uart_test/dut/u_deserializer/i_dv
add wave -noupdate -radix hexadecimal /testbench_top_uart_test/dut/u_deserializer/o_data
add wave -noupdate /testbench_top_uart_test/dut/u_deserializer/o_dv
add wave -noupdate -divider REG_TABLE
add wave -noupdate /testbench_top_uart_test/dut/u_register_block/i_w_en
add wave -noupdate -radix hexadecimal /testbench_top_uart_test/dut/u_register_block/i_w_addr
add wave -noupdate -radix hexadecimal /testbench_top_uart_test/dut/u_register_block/i_w_value
add wave -noupdate -radix hexadecimal /testbench_top_uart_test/dut/u_register_block/mem
add wave -noupdate /testbench_top_uart_test/dut/u_register_block/i_r_en
add wave -noupdate -radix hexadecimal /testbench_top_uart_test/dut/u_register_block/i_r_addr
add wave -noupdate -radix hexadecimal /testbench_top_uart_test/dut/u_register_block/o_r_value
add wave -noupdate /testbench_top_uart_test/dut/u_register_block/o_r_valid
add wave -noupdate -divider SERIALIZER
add wave -noupdate -radix hexadecimal /testbench_top_uart_test/dut/u_serializer/i_data
add wave -noupdate /testbench_top_uart_test/dut/u_serializer/i_dv
add wave -noupdate -radix hexadecimal /testbench_top_uart_test/dut/u_serializer/o_data
add wave -noupdate /testbench_top_uart_test/dut/u_serializer/o_dv
add wave -noupdate -divider UART_TX
add wave -noupdate /testbench_top_uart_test/dut/u_fifo_uart/u_controller/state
add wave -noupdate /testbench_top_uart_test/dut/u_fifo_uart/u_controller/next_state
add wave -noupdate /testbench_top_uart_test/dut/u_fifo_uart/u_uart/dclk
add wave -noupdate /testbench_top_uart_test/dut/u_fifo_uart/i_w_en
add wave -noupdate -radix hexadecimal /testbench_top_uart_test/dut/u_fifo_uart/i_w_data
add wave -noupdate /testbench_top_uart_test/dut/u_fifo_uart/o_tx
add wave -noupdate -radix hexadecimal /testbench_top_uart_test/dut/u_fifo_uart/u_fifo/mem
add wave -noupdate -radix unsigned /testbench_top_uart_test/dut/u_fifo_uart/u_fifo/n_elem
add wave -noupdate -divider EXT_UART_RX
add wave -noupdate /testbench_top_uart_test/u_fifo_rx/state
add wave -noupdate /testbench_top_uart_test/u_fifo_rx/next_state
add wave -noupdate /testbench_top_uart_test/u_fifo_rx/dclk_reset
add wave -noupdate /testbench_top_uart_test/u_fifo_rx/dclk
add wave -noupdate /testbench_top_uart_test/u_fifo_rx/sampling
add wave -noupdate /testbench_top_uart_test/u_fifo_rx/sync_rx
add wave -noupdate -radix hexadecimal /testbench_top_uart_test/u_fifo_rx/o_data
add wave -noupdate /testbench_top_uart_test/u_fifo_rx/o_data_valid
add wave -noupdate -divider DESERIALIZER
add wave -noupdate -radix hexadecimal /testbench_top_uart_test/u_deserializer/i_data
add wave -noupdate /testbench_top_uart_test/u_deserializer/i_dv
add wave -noupdate -radix hexadecimal /testbench_top_uart_test/u_deserializer/o_data
add wave -noupdate /testbench_top_uart_test/u_deserializer/o_dv
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3986290 ns} 0}
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
WaveRestoreZoom {3892082 ns} {4080498 ns}
