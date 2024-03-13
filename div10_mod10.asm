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

.macro exit %code
	li a0, %code
	syscall 0x5D
.end_macro

main:
	li a1, 0x20
	call div10
	call mod10
	
	exit 0

# unsigned mul10(unsigned a1);
mul10:
	# Using this formula:
	# x * 10 = x * 8 + x + x
	
	slli a0, a1, 0x3 # Multiplying by 8
	add a0, a0, a1
	add a0, a0, a1
	ret

# unsigned div10(unsigned a1);
div10:
	# Recursion fallback
	sltiu t0, a1, 0xA
	beqz t0, .div10_body

	li a0, 0x0
	li t0, 0x0
	ret

	.div10_body:

	# Prolog
	push_reg ra
	push_reg s0
	
	# Using this formula:
	# x/10 = x/8 - ((x/4)/10)

	srai s0, a1, 0x3 # Divide by 8
	srai a1, a1, 0x2 # Divide by 4
	call div10

	sub a0, s0, a0

	# Epilog
	pop_reg s0
	pop_reg ra
	ret

# unsigned mod10(unsigned a1);
mod10:
	# Using this formula:
	# x % 10 = x - 10 * (x / 10)
	
	mv t0, a1
	call div10
	
	mv a1, a0
	call mul10
	
	mv t1, a0

	# Now t0 is X, t1 is 10 * (X / 10)
	
	sub a0, t0, t1
	ret
