		.text
		.align  2
		.globl  _start

_start:
		lui x5, 128
		auipc x6, 16
		nop
		nop
		nop
		nop
		.end _start
		.size _start, .-_start
