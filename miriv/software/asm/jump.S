		.text
		.align  2
		.globl  _start

_start:
		nop
A:
		jal x1, B
		addi x5, x5, 1
		nop
		nop
		jal x1, C
		nop
		nop
		nop
B:
		jalr x1, 0(x1)
C:
		addi x5, x5, 5
		nop
		nop
		nop
		.end _start
		.size _start, .-_start
