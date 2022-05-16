add wave -position end  sim:/testbench/clk
add wave -position end  sim:/testbench/reset
add wave -position end  sim:/testbench/load_enable
add wave -position end  sim:/testbench/data
add wave -position end  sim:/testbench/dut/data
add wave -position end  sim:/testbench/dut/state
add wave -position end  sim:/testbench/dut/next_state
add wave -position 5  sim:/testbench/dut/data_loaded
add wave -position 6  sim:/testbench/dut/load_buf
add wave -position 7  sim:/testbench/dut/data_buffered
add wave -position end  sim:/testbench/dut/sclk_cnt
add wave -position end  sim:/testbench/sclk
add wave -position 12  sim:/testbench/dut/sclk_cnt
add wave -position end  sim:/testbench/dut/data
add wave -position 15  sim:/testbench/dut/o_mosi
add wave -position end  sim:/testbench/ov
add wave -position 13  sim:/testbench/dut/sclk_edge

restart
run -all