vlog *.sv
delete wave *
add wave -position end  sim:/testbench/tb_state
add wave -position end  sim:/testbench/clk
add wave -position end  sim:/testbench/reset
add wave -position end  sim:/testbench/w_en
add wave -position end  -radix hex sim:/testbench/w_addr
add wave -position end  -radix hex sim:/testbench/w_value
add wave -position end  sim:/testbench/r_en
add wave -position end  -radix hex sim:/testbench/r_addr
add wave -position end  -radix hex sim:/testbench/r_value
add wave -position end  -radix hex sim:/testbench/dut/mem

restart
run -all