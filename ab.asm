.text

.macro syscall %code
	li a7, %code
	ecall
.end_macro

.macro exit %code
	li a0, %code
	syscall 0x5D
.end_macro

.macro set_zero %reg
	xor %reg, %reg, %reg
.end_macro

.macro putc %reg
	mv a0, %reg
	syscall 0xB
.end_macro

main:
	li s1, 0x5
	li s2, 0x32 # 5 * 50 = 250 = 0xFA

	mv a1, s1
	mv a2, s2
	call multiply
	mv s0, a0

	mv a1, s0
	call print_hex

	exit 0

multiply:
	set_zero a0

	# Loop counter
	li t3, 0x1F

	.LOOP:
	set_zero t1
	set_zero t2

	srl t1, a2, t3
	andi t1, t1, 0x1

	# Convert t4: (0x0, 0x1) -> (0x00000000, 0xFFFFFFFF)
	slli t1, t1, 0x1F
	srai t1, t1, 0x1F

	# Calculating a*2^(b_i), it's shifting a by position of a bit
	sll t2, a1, t3
	and t2, t2, t1

	# Add result
	add a0, a0, t2

	# Decrement and loop condition
	addi t3, t3, -0x1
	bgez t3, .LOOP

	ret

# From hex_calc task
print_hex:
	mv t0, a1
	li t2, 0x1C
	li t3, 0x3A

	.OUTPUT_LOOP:
	set_zero t1
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