.text

.macro syscall %call
	li a7, %call
	ecall
.end_macro

.macro getc %reg
	syscall 0xC
	mv %reg, a0
	li a0, 0
	
	andi %reg, %reg, 0xFF
.end_macro

.macro putc %reg
	mv a0, %reg
	syscall 0xB
.end_macro

.macro putc_imm %char
	li a0, %char
	syscall 0xB
.end_macro

.macro exit %code
	li a0, %code
	syscall 0x5D
.end_macro

.macro set_zero %reg
	xor %reg, %reg, %reg
.end_macro

MAIN:
	call READ_NUMBER
	mv a1, a0

	call READ_NUMBER
	mv a2, a0

	call OPERATION
	mv a1, a0

	putc_imm 0xA
	
	call PRINT_NUMBER
	
	exit 0

READ_NUMBER:
	# We keep our number in t0
	# Storing ret ('\n') symbol in t6 register (to check when to finish)
	li t6, 0xA
	set_zero t0

	.INPUT_LOOP:
	getc t1

	# Make our auxiliary registers be empty
	set_zero t2
	set_zero t3
	set_zero t4
	set_zero t5

	bne t1, t6, .CONVERT
	# Moving our number into a0 register (return)
	mv a0, t0
	ret

	.CONVERT:
	addi t2, t1, -0x30
	addi t3, t1, -0x41

	# In t3/t4 we have flags which indicate our number is from 0 to 9 or from A to F
	sltiu t4, t2, 0xA
	sltiu t5, t3, 0x6
	
	# Adding 0xA to t3 'cause t3 indicates for A-F, and value range should be same
	addi t3, t3, 0xA

	# Checking that symbol is a hex digit (t3 or t4 flag has to be 1 aka true)
	xor t1, t4, t5
	beqz t1, ERROR

	# Do converting
	# 0x000000 => 0x000000
	# 0x000001 => 0x001111
	# We will use this registers as a mask

	# I'll use a5/a6 registers

	mv a5, t4
	mv a6, t5

	slli t4, t4, 0x1
	slli t5, t5, 0x1
	add t4, t4, a5
	add t5, t5, a6

	slli t4, t4, 0x1
	slli t5, t5, 0x1
	add t4, t4, a5
	add t5, t5, a6

	slli t4, t4, 0x1
	slli t5, t5, 0x1
	add t4, t4, a5
	add t5, t5, a6
	
	set_zero a5
	set_zero a6
	
	# Apply this masks
	and t2, t2, t4
	and t3, t3, t5

	# Finally, we have entered number in last 4 bits in t1 register
	mv t1, t2
	add t1, t1, t3

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
	set_zero t1
	srl t1, t0, t2

	# Adding '0' to our number
	andi t1, t1, 0xF
	addi t1, t1, 0x30

	blt t1, t3, .PRINT

	# If needed, add this constant to our number
	addi t1, t1, 0x7

	.PRINT:
	putc t1

	addi t2, t2, -0x4
	bgez t2, .OUTPUT_LOOP

	ret

ERROR:
	exit 1
