from random import randint

n_samples = 4
WIDTH = 8
fname_tx = 'tx.txt'
fname_values_le = 'values_le.txt'
fname_values_be = 'values_be.txt'

values = [randint(0, 2**WIDTH - 1) for _ in range(n_samples)]
value_strs = [[0] + [int(x) for x in ('{:08b}'.format(value))[::-1]] + [1] for value in values]  # little endian by default

tx_str = ''
for value_str in value_strs:
	for x in value_str:
		tx_str += "{}\n".format(x)
tx_str = tx_str.rstrip()

with open(fname_tx, 'w') as f:
	f.write(tx_str)

reverse = lambda x: int("{0:08b}".format(x)[::-1], 2)

values_str_le = ''
values_str_be = ''
for value in values:
	values_str_le += "{}\n".format(value)
	values_str_be += "{}\n".format(reverse(value))
values_str_le = values_str_le.rstrip()
values_str_be = values_str_be.rstrip()


with open(fname_values_le, 'w') as f:
	f.write(values_str_le)

with open(fname_values_be, 'w') as f:
	f.write(values_str_be)
