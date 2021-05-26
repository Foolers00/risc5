		.text
		.align  2
		.globl  _start

_start:
		addi x5, x0, 3
		addi x6, x0, 4
		nop
		nop
		beq x5, x6, A
		addi x7, x0, 7
		beq x5, x5, A
		nop
		nop
		nop
A:
		addi x8, x0, 8
		blt x5, x6, B
		nop
		nop
		nop
B:
		addi x9, x0, 9
		.end _start
		.size _start, .-_start
