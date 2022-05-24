import serial

def gray_decode(n):
    m = n >> 1
    while m:
        n ^= m
        m >>= 1
    return n

with serial.Serial('COM5', 115200) as ser:
	while True:
		value = ser.readline()[0]
		s = "{:08b} {:03d}"
		print(s.format(value, gray_decode(value)))


