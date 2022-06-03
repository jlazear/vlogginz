wombat command parser
=====================

Source module located in `wombat_command_parser.sv`. Module requires an external register table to be connected. 

Example usage in `top_wombat_command_parser.sv`. Also included is usage of the `debug` module for muxing signals to the LEDs on the board. 

Testbenches included that demonstrate functionality. Testbenches have not been tested extensively...

`cmd_fpga.py` shows a Python interface to the wombat. 