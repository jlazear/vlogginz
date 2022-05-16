from random import randint

consolidated_fname = 'data.txt'

# Add some well-behaved samples
n_values = 5

values = [randint(0, 255) for _ in range(n_values)]
binvalues = ["{:08b}".format(x) for x in values]

rx_packets = ['0' + x + '1' for x in binvalues]
rx_stream = ''.join(rx_packets) + '1'

dv_packets = ['0'*9 + '1' for _ in range(n_values)]
dv_stream = '0' + ''.join(dv_packets)

values_packets = [[0]*9 + [value] for value in values]
values_stream = [0]
for vp in values_packets:
	values_stream.extend(vp)



# turn off for 20 cycles
rx_stream += '1'*20
dv_stream += '0'*20
values_stream += [0]*20


# add some more values
values = [randint(0, 255) for _ in range(n_values)]
binvalues = ["{:08b}".format(x) for x in values]

rx_packets = ['0' + x + '1' for x in binvalues]
rx_stream += ''.join(rx_packets) + '1'

dv_packets = ['0'*9 + '1' for _ in range(n_values)]
dv_stream += '0' + ''.join(dv_packets)

values_packets = [[0]*9 + [value] for value in values]
values_stream.append(0)
for vp in values_packets:
	values_stream.extend(vp)


# prepend a reset
values_stream = [0] + values_stream
rx_stream = '1' + rx_stream
dv_stream = '0' + dv_stream

reset_stream = [0]*len(values_stream)
reset_stream[0] = 1

# sabotage a stop bit, which may induce a spurious error...
stop_index = 121
values_stream[stop_index + 1] = 0
rx_stream = rx_stream[:stop_index+1] + '0' + rx_stream[stop_index+2:]
dv_stream = dv_stream[:stop_index+1] + '0' + dv_stream[stop_index+2:]


with open(consolidated_fname, 'w') as f:
	fmtstr = "{} {} {} {:d}\n"
	for i in range(len(values_stream)):
		f.write(fmtstr.format(reset_stream[i], rx_stream[i], dv_stream[i], values_stream[i]))