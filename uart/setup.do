python generate_data.py
vlog *.sv
delete wave *

restart

add wave -position end  sim:/testbench/tb_state
add wave -position end  sim:/testbench/clk
add wave -position end  sim:/testbench/reset
add wave -position end  sim:/testbench/txclk
add wave -position end  sim:/testbench/tx
add wave -position end  -radix hex sim:/testbench/data_le
add wave -position end  -radix hex sim:/testbench/data_be
add wave -position end  sim:/testbench/dv_le
add wave -position end  sim:/testbench/dv_be

add wave -divider LITTLE_ENDIAN

add wave -divider SAMPLING
add wave -position end  sim:/testbench/txclk
add wave -position end  sim:/testbench/dut_le/dclk_reset
add wave -position end  sim:/testbench/dut_le/dclk
add wave -position end  sim:/testbench/tx
add wave -position end  sim:/testbench/dut_le/sync_rx
add wave -position end  sim:/testbench/dut_le/sampling
add wave -position end  sim:/testbench/dut_le/s

add wave -divider UART_RX
add wave -position end  sim:/testbench/dut_le/state
add wave -position end  sim:/testbench/dut_le/next_state
add wave -position end  sim:/testbench/dut_le/dclk
add wave -position end  sim:/testbench/dut_le/sync_rx
add wave -position end  sim:/testbench/dut_le/sampling
add wave -position end  sim:/testbench/dut_le/sampled
add wave -position end  sim:/testbench/dut_le/s
add wave -position end  -radix hex sim:/testbench/dut_le/mem
add wave -position end  sim:/testbench/dut_le/start_bit
add wave -position end  sim:/testbench/dut_le/end_bit
add wave -position end  -radix unsigned sim:/testbench/dut_le/s_cnt
add wave -position end  -radix hex sim:/testbench/dut_le/o_data
add wave -position end  sim:/testbench/dut_le/o_data_valid
add wave -position end  -radix unsigned sim:/testbench/dut_le/dclk_subcnt


add wave -divider SAMPLE_COUNTER
add wave -position end  sim:/testbench/dut_le/q_sample_counter/clk
add wave -position end  sim:/testbench/dut_le/q_sample_counter/reset
add wave -position end  sim:/testbench/dut_le/q_sample_counter/enable
add wave -position end  -radix hex sim:/testbench/dut_le/q_sample_counter/cnt
add wave -position end  sim:/testbench/dut_le/q_sample_counter/_rollover

add wave -divider BIG_ENDIAN

add wave -divider SAMPLING
add wave -position end  sim:/testbench/txclk
add wave -position end  sim:/testbench/dut_be/dclk_reset
add wave -position end  sim:/testbench/dut_be/dclk
add wave -position end  sim:/testbench/tx
add wave -position end  sim:/testbench/dut_be/sync_rx
add wave -position end  sim:/testbench/dut_be/sampling
add wave -position end  sim:/testbench/dut_be/s

add wave -divider UART_RX
add wave -position end  sim:/testbench/dut_be/state
add wave -position end  sim:/testbench/dut_be/next_state
add wave -position end  sim:/testbench/dut_be/dclk
add wave -position end  sim:/testbench/dut_be/sync_rx
add wave -position end  sim:/testbench/dut_be/sampling
add wave -position end  sim:/testbench/dut_be/sampled
add wave -position end  sim:/testbench/dut_be/s
add wave -position end  -radix hex sim:/testbench/dut_be/mem
add wave -position end  sim:/testbench/dut_be/start_bit
add wave -position end  sim:/testbench/dut_be/end_bit
add wave -position end  -radix unsigned sim:/testbench/dut_be/s_cnt
add wave -position end  -radix hex sim:/testbench/dut_be/o_data
add wave -position end  sim:/testbench/dut_be/o_data_valid
add wave -position end  -radix unsigned sim:/testbench/dut_be/dclk_subcnt


add wave -divider SAMPLE_COUNTER
add wave -position end  sim:/testbench/dut_be/q_sample_counter/clk
add wave -position end  sim:/testbench/dut_be/q_sample_counter/reset
add wave -position end  sim:/testbench/dut_be/q_sample_counter/enable
add wave -position end  -radix hex sim:/testbench/dut_be/q_sample_counter/cnt
add wave -position end  sim:/testbench/dut_be/q_sample_counter/_rollover


run -all