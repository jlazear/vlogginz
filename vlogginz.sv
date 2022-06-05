// include all of the utility modules for convenience

// counter
`include "counter/counter.sv"
`include "counter/gray.sv"

// debouncer
`include "debouncer/debouncer.sv"

// debug
`include "debug/debug.sv"

// fifo
`include "fifo/fifo.sv"

// fifo_uart
`include "fifo_uart/fifo_uart.sv"
`include "fifo_uart/fifo_uart_controller.sv"

// lfsr
`include "lfsr/lfsr.sv"

// muxes
`include "muxes/click_mux.sv"
`include "muxes/mux.sv"

// pulse
`include "pulse/pulse.sv"

// register_block
`include "register_block/register_block.sv"

// serializer
`include "serializer/deserializer.sv"
`include "serializer/serializer.sv"

// synchronizer
`include "synchronizer/synchronizer.sv"

// uart
`include "uart/uart_rx.sv"
`include "uart/uart_tx.sv"

// wombat
`include "wombat_command_parser/command_controller.sv"
`include "wombat_command_parser/wombat_command_parser_uart.sv"
`include "wombat_command_parser/top_wombat_command_parser.sv"