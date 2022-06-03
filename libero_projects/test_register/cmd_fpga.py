import serial
import argparse

verbose = 1
baudrate = 115200  # baud
port = 'COM5'
timeout = 1  # second

write_cmd = 0x01
read_cmd = 0x02

# expects 1 byte address and 4 byte value, sends LSB first
def write(addr, value, ser=None, verbose=True):
	send(cmd=write_cmd, addr=addr, value=value, ser=ser, verbose=verbose)

def read(addr, ser=None, verbose=True, *args, **kwargs):
	return send(cmd=read_cmd, addr=addr, value=0, read_response=True, ser=ser, verbose=verbose)

def send(cmd, addr, value=0, read_response=False, ser=None, verbose=True):
	if isinstance(value, str):
		val0, val1, val2, val3 = value.encode()
	elif isinstance(value, int):
		val3 = value & 0xff
		val2 = (value >> 8) & 0xff
		val1 = (value >> 16) & 0xff
		val0 = (value >> 24) & 0xff
	elif isinstance(value, bytes):
		val0, val1, val2, val3 = value
	b = bytearray([cmd, addr, val0, val1, val2, val3])

	if ser is None:
		ser = serial.Serial(port, baudrate, timeout=timeout)
		close = True
	else:
		close = False

	if verbose: print("b = {} (len = {})".format(b, len(b)))
	ser.write(b)
	if read_response:
		toret = ser.read(4)
		if verbose: print("response = {}".format(toret))
		if close: ser.close()
		return toret
	if close: ser.close()

cmd_dict = {'w': write,
            'write': write,
            'r': read,
            'read': read}


if __name__ == '__main__':
	parser = argparse.ArgumentParser(description="read/write to FPGA")
	parser.add_argument('cmd')
	parser.add_argument('addr')
	parser.add_argument('value')

	parsed = parser.parse_args()
	print("parsed = ", parsed)  #DELME

	addr = int(parsed.addr, 16)
	value = int(parsed.value, 16)

	print(repr(cmd_dict[parsed.cmd](addr, value)))