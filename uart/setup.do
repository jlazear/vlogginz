vlog *.sv
delete wave *

add wave -position end  sim:/testbench/tb_state
add wave -position end  sim:/testbench/clk
add wave -position end  sim:/testbench/reset
add wave -position end  sim:/testbench/tx
add wave -position end  -radix hex sim:/testbench/data
add wave -position end  sim:/testbench/dv

add wave -divider UART_RX
add wave -position end  sim:/testbench/dut/state
add wave -position end  sim:/testbench/dut/next_state
add wave -position end  sim:/testbench/dut/dclk
add wave -position end  sim:/testbench/dut/sync_rx
add wave -position end  sim:/testbench/dut/sampling
add wave -position end  sim:/testbench/dut/sampled
add wave -position end  sim:/testbench/dut/s
add wave -position end  -radix hex sim:/testbench/dut/mem
add wave -position end  sim:/testbench/dut/start_bit
add wave -position end  sim:/testbench/dut/end_bit
add wave -position end  -radix unsigned sim:/testbench/dut/s_cnt
add wave -position end  -radix hex sim:/testbench/dut/o_data
add wave -position end  sim:/testbench/dut/o_data_valid
add wave -position end  -radix unsigned sim:/testbench/dut/dclk_subcnt


add wave -divider SAMPLE_COUNTER
add wave -position end  sim:/testbench/dut/q_sample_counter/clk
add wave -position end  sim:/testbench/dut/q_sample_counter/reset
add wave -position end  sim:/testbench/dut/q_sample_counter/enable
add wave -position end  -radix hex sim:/testbench/dut/q_sample_counter/cnt
add wave -position end  sim:/testbench/dut/q_sample_counter/_rollover


restart
run -all