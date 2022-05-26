import serial
import time

def gray_decode(n):
    m = n >> 1
    while m:
        n ^= m
        m >>= 1
    return n

# with serial.Serial('COM5', 115200) as ser:
# 	while True:
# 		value = ser.readline()[0]
# 		s = "{:08b} {:03d}"
# 		print(s.format(value, gray_decode(value)))

i = 0
t0 = time.time()
with serial.Serial('COM5', 115200) as ser:
	while True:
		if ser.in_waiting:
			value = ser.read()
			s = "[t={0:03.1f} s] {1:03d} {2:08b} {2:03d}"
			dt = time.time() - t0
			print(s.format(dt % 60, i % 32, int.from_bytes(value, "little")))
			i += 1

