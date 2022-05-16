vlog *.sv
delete wave *
add wave -position end  sim:/testbench/tb_state
add wave -position end  sim:/testbench/active_task
add wave -position end  sim:/testbench/clk
add wave -position end  sim:/testbench/reset
add wave -position end  sim:/testbench/w_en
add wave -position end  -radix hex sim:/testbench/write_data
add wave -position end  -radix unsigned sim:/testbench/dut/ptr1
add wave -position end  -radix unsigned sim:/testbench/dut/ptr2
add wave -position end  sim:/testbench/dut/first
add wave -position end  -radix hex sim:/testbench/dut/mem
add wave -position end  sim:/testbench/full
add wave -position end  sim:/testbench/afull
add wave -position end  sim:/testbench/empty
add wave -position end  sim:/testbench/aempty
add wave -position end  -radix unsigned sim:/testbench/dut/n_elem
add wave -position end  sim:/testbench/r_en
add wave -position end  -radix hex sim:/testbench/read_data

restart
run -all