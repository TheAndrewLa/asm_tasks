.text

.macro push_reg %reg
	addi sp, sp, -0x4
	sw %reg, 0x0 (sp)
.end_macro

.macro pop_reg %reg
	lw %reg, 0x0 (sp)
	addi sp, sp, 0x4
.end_macro

.macro syscall %call
	li a7, %call
	ecall
.end_macro

.macro getc %reg
	push_reg a0

	syscall 0xC
	mv %reg, a0
	
	pop_reg a0

	andi %reg, %reg, 0xFF
.end_macro

.macro putc %reg
	push_reg a0
	
	mv a0, %reg
	syscall 0xB
	
	pop_reg a0
.end_macro

.macro putc_imm %char
	push_reg a0

	li a0, %char
	syscall 0xB
	
	pop_reg a0
.end_macro

.macro exit %code
	li a0, %code
	syscall 0x5D
.end_macro

MAIN:
	call READ_NUMBER
	mv s0, a0

	call READ_NUMBER
	mv s1, a0

	mv a1, s0
	mv a2, s1
	call OPERATION
	mv s0, a0

	putc_imm 0xA

	mv a1, s0
	call PRINT_NUMBER
	
	exit 0

READ_NUMBER:
	# We keep our number in t0
	# Storing ret ('\n') symbol in t6 register (to check when to finish)
	li a1, 0xA
	li t0, 0x0

	.INPUT_LOOP:
	getc t1

	bne t1, a1, .CONVERT
	# Moving our number into a0 register (return)
	mv a0, t0
	ret

	.CONVERT:
	addi t2, t1, -0x30
	addi t3, t1, -0x41
	addi t4, t1, -0x61

	li t1, 0x0

	# In t3/t4 we have flags which indicate our number is from 0 to 9 or from A to F or from a to f
	sltiu a2, t2, 0xA
	sltiu a3, t3, 0x6
	sltiu a4, t4, 0x6

	# Adding 0xA to t3 & t4 'cause they indicate for A-F, and value range should be same
	addi t3, t3, 0xA
	addi t4, t4, 0xA

	# Checking that symbol is a hex digit (t3 or t4 flag has to be 1 aka true)
	add t1, a2, a3
	add t1, t1, a4
	beqz t1, ERROR

	# Do converting
	# 0x000000 => 0x000000
	# 0x000001 => 0x111111
	# We will use this registers as a mask
	
	neg a2, a2
	neg a3, a3
	neg a4, a4

	# Apply this masks
	and t2, t2, a2
	and t3, t3, a3
	and t4, t4, a4

	# Finally, we have entered number in last 4 bits in t1 register
	add t1, t2, t3
	add t1, t1, t4

	slli t0, t0, 0x4
	add t0, t0, t1

	j .INPUT_LOOP

OPERATION:
	# Our constants
	li t1 0x2B # +
	li t2 0x2D # -
	li t3 0x7C # |
	li t4 0x26 # &

	getc t0

	# Looks really bad, but I cant find a way how to realize switch-case implementation
	beq t0, t1, .ADD
	beq t0, t2, .SUB
	beq t0, t3, .OR
	beq t0, t4, .AND
	
	exit 1

	.ADD:
	add a0, a1, a2
	ret

	.SUB:
	sub a0, a1, a2
	ret

	.OR:
	or a0, a1, a2
	ret

	.AND:
	and a0, a1, a2
	ret

PRINT_NUMBER:
	mv t0, a1

	# Loop counter and decrement
	li t2, 0x1C

	# Constant = ('9' + 1)
	li t3, 0x3A

	# Organizing do-while loop

	.OUTPUT_LOOP:
	li t1, 0x0
	srl t1, t0, t2

	# Adding '0' to our number
	andi t1, t1, 0xF
	addi t1, t1, 0x30

	blt t1, t3, .PRINT

	# If needed, add this constant to our number (kind of hex-bias)
	addi t1, t1, 0x7

	.PRINT:
	putc t1

	addi t2, t2, -0x4
	bgez t2, .OUTPUT_LOOP

	ret

ERROR:
	exit 1
