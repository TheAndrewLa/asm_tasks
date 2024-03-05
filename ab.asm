.text

.macro push_reg %reg
	addi sp, sp, -0x4
	sw %reg, (sp)
.end_macro

.macro pop_reg %reg
	lw %reg, 0x0(sp)
	addi sp, sp, 0x4
.end_macro

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

.macro putc_imm %imm
	li a0, %imm
	syscall 0xB
.end_macro

main:
	li s1, 0xA
	li s2, 0xA

	mv a1, s1
	mv a2, s2
	call multiply
	mv s0, a0

	mv a1, s0
	call print_hex

	exit 0

multiply:
	li t0, 0x0
	mv t1, a1
	mv t2, a2

	li t3, 0x1F

	.LOOP:

	set_zero t4
	set_zero t5
	set_zero t6

	srl t4, t2, t3
	andi t4, t4, 0x1

	# Convert t4 from {0, 1} to {0x00000000, 0xFFFFFFFF}
	slli t4, t4, 0x1F
	srai t4, t4, 0x1F

	# Calculating a*2^(b_i)
	sll t5, t1, t3
	and t5, t5, t4

	# Add result
	add t0, t0, t5

	# Decrement and loop condition
	addi t3, t3, -0x1
	bgez t3, .LOOP

	mv a0, t0
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

# From hex_calc task
read_hex:
	li t6, 0xA
	set_zero t0

	.INPUT_LOOP:
	getc t1

	bne t1, t6, .CONVERT

	mv a0, t0
	ret

	.CONVERT:
	addi t2, t1, -0x30
	addi t3, t1, -0x41

	sltiu t4, t2, 0xA
	sltiu t5, t3, 0x6
	
	addi t3, t3, 0xA

	xor t1, t4, t5
	beqz t1, ERROR

	slli t4, t4, 0x1F
	srai t4, t4, 0x1F
	andi t4, t4, 0xF

	slli t5, t5, 0x1F
	srai t5, t5, 0x1F
	andi t4, t4, 0xF

	and t2, t2, t4
	and t3, t3, t5

	mv t1, t2
	add t1, t1, t3

	slli t0, t0, 0x4
	add t0, t0, t1

	j .INPUT_LOOP
