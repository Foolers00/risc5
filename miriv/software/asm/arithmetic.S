		.text
		.align  2
		.globl  _start

_start:
		addi x5, x0, 10
		addi x6, x0, -20
		nop
		nop
		add x7, x5, x6
		sub x8, x5, x6
		sll x9, x6, x5
		slt x10, x5, x6
		sltu x11, x5, x6
		xor x12, x5, x6
		srl x13, x6, x5
		sra x14, x6, x5
		or x15, x5, x6
		and x16, x5, x6
		.end _start
		.size _start, .-_start
