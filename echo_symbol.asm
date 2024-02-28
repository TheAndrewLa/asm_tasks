.text

.macro syscall %scode
	li a7, %scode
	ecall
.end_macro

.macro getc %reg
	syscall 12
	mv %reg, a0
.end_macro

.macro putc %reg
	mv a0, %reg
	syscall 11
.end_macro

.macro putc_imm %char
	li a0, %char
	syscall 11
.end_macro

.macro exit %ecode
	li a0, %ecode
	syscall 93
.end_macro

main:
	# Space and enter symbols
	li t2, '\n'

.WAIT_INPUT:
	getc t0
	andi t0, t0, 0xFF
	beq t0, t2, .EXIT

	putc t0
	
	addi t0, t0, 1
	putc t0
	
	# Adding space between input
	putc_imm 0x20

	j .WAIT_INPUT
	
.EXIT:
	exit 0
