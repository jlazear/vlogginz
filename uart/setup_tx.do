vlog *.sv
delete wave *

add wave -position end  sim:/testbench_tx/tb_state
add wave -position end  sim:/testbench_tx/clk
add wave -position end  sim:/testbench_tx/reset
add wave -position end  sim:/testbench_tx/txclk
add wave -position end  sim:/testbench_tx/dv
add wave -position end  -radix hex sim:/testbench_tx/data
add wave -position end  sim:/testbench_tx/tx
add wave -position end  sim:/testbench_tx/busy

add wave -divider UART_TX
add wave -position end  sim:/testbench_tx/dut/state
add wave -position end  sim:/testbench_tx/dut/next_state
add wave -position end  sim:/testbench_tx/dut/dclk
add wave -position end  -radix hex sim:/testbench_tx/dut/mem
add wave -position end  -radix unsigned sim:/testbench_tx/dut/s_cnt
add wave -position end  -radix unsigned sim:/testbench_tx/dut/dclk_subcnt

restart
run -all