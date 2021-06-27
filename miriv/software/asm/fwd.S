		.text
		.align  2
		.globl  _start

_start:
		addi x1, x0, 7
		addi x2, x0, 5
		and x1, x2, x1
		sw x1, 0(x0)
		nop
		nop
		nop
		lw x3, 0(x0)
		addi x3, x3, 1
		nop
		nop
		nop
		.end _start
		.size _start, .-_start
