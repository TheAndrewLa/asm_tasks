.include "common/debug_io.asm"

.text

.macro syscall %code
	li a7, %code
	ecall
.end_macro

.macro exit %code
	li a0, %code
	syscall 0x5D
.end_macro

.macro putc %reg
	mv a0, %reg
	syscall 0xB
.end_macro

main:
	li a0, 0x5
	li a1, 0x32 # 5 * 50 = 250 = 0xFA

	call multiply
	call print_hex

	exit 0

# int multiply(int a0, int a1) -> a0
multiply:
	li t0, 0x0

	# Loop counter
	li t3, 0x1F

	.LOOP:
	li t1, 0x0
	li t1, 0x0

	# Pick i_th bit in a number
	srl t1, a1, t3
	andi t1, t1, 0x1

	# Convert t1: (0x0, 0x1) -> (0x00000000, 0xFFFFFFFF)
	neg t1, t1

	# Calculating a*2^(b_i), it's shifting a by position of a bit
	sll t2, a0, t3
	and t2, t2, t1

	# Add result
	add t0, t0, t2

	# Decrement and loop condition
	addi t3, t3, -0x1
	bgez t3, .LOOP
	
	mv a0, t0
	ret
