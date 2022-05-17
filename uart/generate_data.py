from random import randint

n_samples = 1024
WIDTH = 8
fname_tx = 'tx.txt'
fname_values = 'values.txt'

values = [randint(0, 2**WIDTH - 1) for _ in range(n_samples)]
value_strs = [[0] + [int(x) for x in '{:08b}'.format(value)] + [1] for value in values]

tx_str = ''
for value_str in value_strs:
	for x in value_str:
		tx_str += "{}\n".format(x)
tx_str = tx_str.rstrip()

with open(fname_tx, 'w') as f:
	f.write(tx_str)


values_str = ''
for value in values:
	values_str += "{}\n".format(value)
values_str = values_str.rstrip()

with open(fname_values, 'w') as f:
	f.write(values_str)
