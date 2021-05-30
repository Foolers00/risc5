		.text
		.align  2
		.globl  _start

_start:
		addi x20, x0, -1
		nop
		nop
		srli x20, x20, 16
		nop
		nop
		sw x20, 0(x0)
		lb x21, 0(x0)
		lh x22, 0(x0)
		lw x23, 0(x0)
		lbu x24, 0(x0)
		lhu x25, 0(x0)
		.end _start
		.size _start, .-_start
