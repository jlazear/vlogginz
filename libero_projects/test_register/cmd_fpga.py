import serial
import bitstring
import argparse
import time

verbose = 1
baudrate = 115200  # baud
port = 'COM5'
timeout = 1  # second

# write_cmd = 0x01
# read_cmd = 0x02
write_cmd = ord('w')
read_cmd = ord('r')


# expects 1 byte address and 4 byte value, sends LSB first
def write(addr, value, ser=None, verbose=True, nbytes_value=4, pad=b'\x00'):
    send(cmd=write_cmd, addr=addr, value=value, ser=ser, verbose=verbose,
         nbytes_value=nbytes_value, pad=pad)

def read(addr, ser=None, verbose=True, nbytes_value=4, pad=b'\x00', *args, **kwargs):
    return send(cmd=read_cmd, addr=addr, value=0, read_response=True, ser=ser, verbose=verbose,
                nbytes_value=nbytes_value, pad=pad)

def send(cmd, addr, value=0, read_response=False, ser=None, verbose=True,
         nbytes_value=4, pad=b'\x00', virtual=False):
    if isinstance(value, str):
        vals = value.encode()
    elif isinstance(value, int):
        vals = [(value >> 8*i) & 0xff for i in range(nbytes_value)][::-1]
    elif isinstance(value, bytes):
        vals = value
    base = [cmd, addr]
    base.extend(vals)
    b = bytearray(base)
    
    if len(b) < nbytes_value + 2:
        b += pad*(nbytes_value + 2 - len(b))
    elif len(b) > nbytes_value + 2:
        b = b[:nbytes_value + 2]

    if ser is None:
        ser = serial.Serial(port, baudrate, timeout=timeout)
        close = True
    else:
        close = False

    if verbose: print("b = {} (len = {})".format(b, len(b)))
    if not virtual:
        ser.write(b)
    if read_response:
        toret = ser.read(nbytes_value)
        if verbose: print("response = {}".format(toret))
        if close: ser.close()
        return toret
    if close: ser.close()

def fill_ascending(base='boo', depth=16, verbose=False, nbytes_value=4):
    for i in range(depth):
        write(i, (base + "{:x}".format(i))[:nbytes_value], verbose=verbose, nbytes_value=nbytes_value)

def fill_all(value='boo', depth=16, verbose=False, nbytes_value=4):
    for i in range(depth):
        write(i, value[:nbytes_value], verbose=verbose, nbytes_value=nbytes_value)


def read_all(depth=16, verbose=False, nbytes_value=4):
    for i in range(depth):
        s = "addr 0x{0:02x} = {1}"
        print(s.format(i, read(i, verbose=verbose, nbytes_value=nbytes_value)))

# configurable_blinky commands
def enable_blinky(enable=True):
    if enable:
        write(0x00, b'\x00\x00\x00\x00')
    else:
        write(0x00, b'\x00\x00\x00\x01')


def set_mux(mode):
    write(0x01, 3*b'\x00' + bytes([mode]))

# SMIO
def configure_smio(mode='r', phy_addr=0, reg_addr=0, input_data=0, verbose=False):
    ba = bitstring.BitArray(length=32)
    ba[31] = 0 if (mode == 'r') else 1
    ba[26:31] = phy_addr % 2**5
    ba[21:26] = reg_addr % 2**5
    ba[5:21] = input_data % 2**16

    write(addr=0x04, value=ba.tobytes(), nbytes_value=4, verbose=verbose)
    return ba

def trigger_smio(addr=5, delay=.1):
    write(5, b'\x00\x00\x00\x01')
    time.sleep(delay)
    write(5, b'\x00\x00\x00\x00')


cmd_dict = {'w': write,
            'write': write,
            'r': read,
            'read': read,
            'fill_all': fill_ascending,
            'read_all': read_all}


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