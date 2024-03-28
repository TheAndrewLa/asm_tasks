.include "common/stack.asm"
.include "common/debug_io.asm"
.include "common/common.asm"

.global main

.text

main:
	li a0, 0x30
	call div10
	call print_hex

	li a0, 0x30
	call mod10
	call print_hex

	exit 0

# unsigned mul10(unsigned a0) -> a0;
mul10:
	# Using this formula:
	# x * 10 = x * 8 + x + x
	
	mv t0, a0

	slli a0, a0, 0x3 # Multiplying by 8
	add a0, a0, t0
	add a0, a0, t0
	ret

# unsigned div10(unsigned a0) -> a0;
div10:
	# Recursion fallback
	slti t0, a0, 0xA
	beqz t0, .div10_body
	li a0, 0x0
	ret

	.div10_body:
	push_reg ra
	push_reg s0
	push_reg s1
	push_reg s2

	# Using this formula:
	# x/10 = ((x/8) - ((x/4)/10))

	mv s1, a0

	srli s0, a0, 0x3 # Divide by 8
	srli a0, a0, 0x2 # Divide by 4
	call div10

	sub a0, s0, a0

	mv s2, a0
	
	call mul10

	sgtu t0, a0, s1
	sub a0, s2, t0

	pop_reg s2
	pop_reg s1
	pop_reg s0
	pop_reg ra
	ret

# unsigned mod10(unsigned a0) -> a0;
mod10:
	# Using this formula:
	# x % 10 = x - 10 * (x / 10)

	push_reg ra
	push_reg s0
	push_reg a0

	call div10
	call mul10

	pop_reg a1

	sub a0, a1, a0

	pop_reg s0
	pop_reg ra
	ret
