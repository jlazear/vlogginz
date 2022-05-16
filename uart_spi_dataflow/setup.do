vlog *.sv
delete wave *

add wave -position end  sim:/testbench/tb_state
add wave -position end  sim:/testbench/clk
add wave -position end  sim:/testbench/reset
add wave -position end  -radix hex sim:/testbench/temp
add wave -position end  sim:/testbench/tx

add wave -divider UART_RX
add wave -position end  sim:/testbench/dut/u_uart_rx/state
add wave -position end  sim:/testbench/dut/u_uart_rx/next_state
add wave -position end  -radix hex sim:/testbench/dut/u_uart_rx/_data
add wave -position end  sim:/testbench/dut/u_uart_rx/cnt
add wave -position end  -radix hex sim:/testbench/dut/u_uart_rx/q
add wave -position end  sim:/testbench/dut/u_uart_rx/data_valid

add wave -divider SPI_MASTER
add wave -position end  sim:/testbench/dut/u_spi_master/state
add wave -position end  sim:/testbench/dut/u_spi_master/next_state
add wave -position end  -radix hex sim:/testbench/dut/u_spi_master/i_data
add wave -position end  sim:/testbench/dut/u_spi_master/i_load_enable
add wave -position end  sim:/testbench/dut/u_spi_master/o_sclk
add wave -position end  sim:/testbench/dut/u_spi_master/o_mosi
add wave -position end  sim:/testbench/dut/u_spi_master/o_output_valid
add wave -position end  -radix unsigned sim:/testbench/dut/u_spi_master/sclk_cnt
add wave -position end  -radix hex sim:/testbench/dut/u_spi_master/data
add wave -position end  sim:/testbench/dut/u_spi_master/data_buffered
add wave -position end  -radix hex sim:/testbench/dut/u_spi_master/load_buf
add wave -position end  sim:/testbench/dut/u_spi_master/data_buffered

add wave -divider SPI_SLAVE
add wave -position end  sim:/testbench/dut/u_spi_slave/i_sclk
add wave -position end  sim:/testbench/dut/u_spi_slave/i_mosi
add wave -position end  sim:/testbench/dut/u_spi_slave/i_cs
add wave -position end  -radix hex sim:/testbench/dut/u_spi_slave/o_data
add wave -position end  sim:/testbench/dut/u_spi_slave/o_output_valid
add wave -position end  sim:/testbench/dut/u_spi_slave/o_cs_desync
add wave -position end  -radix hex sim:/testbench/dut/u_spi_slave/sr
add wave -position end  -radix hex sim:/testbench/dut/u_spi_slave/data
add wave -position end  -radix unsigned sim:/testbench/dut/u_spi_slave/cnt

add wave -divider FIFO
add wave -position end  sim:/testbench/dut/u_fifo/i_w_en
add wave -position end  -radix hex sim:/testbench/dut/u_fifo/i_w_data
add wave -position end  -radix hex sim:/testbench/dut/u_fifo/mem
add wave -position end  -radix unsigned sim:/testbench/dut/u_fifo/ptr1
add wave -position end  -radix unsigned sim:/testbench/dut/u_fifo/ptr2
add wave -position end  -radix unsigned sim:/testbench/dut/u_fifo/n_elem
add wave -position end  sim:/testbench/dut/u_fifo/first
add wave -position end  sim:/testbench/dut/u_fifo/i_r_en
add wave -position end  -radix hex sim:/testbench/dut/u_fifo/o_r_data
add wave -position end  sim:/testbench/dut/u_fifo/o_afull
add wave -position end  sim:/testbench/dut/u_fifo/o_full
add wave -position end  sim:/testbench/dut/u_fifo/o_aempty
add wave -position end  sim:/testbench/dut/u_fifo/o_empty

restart
run -all