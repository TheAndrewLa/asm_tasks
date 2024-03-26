.text

.macro putc %reg
	mv a0, %reg
	li a7, 0xB
	ecall
.end_macro

# void print_hex(int a0)
print_hex:
	mv t0, a0
	li t2, 0x1C
	li t3, 0x3A

	.OUTPUT_LOOP:
	li t1, 0x0
	srl t1, t0, t2

	andi t1, t1, 0xF
	addi t1, t1, 0x30

	blt t1, t3, .PRINT

	addi t1, t1, 0x7

	.PRINT:
	putc t1

	addi t2, t2, -0x4
	bgez t2, .OUTPUT_LOOP

	ret
