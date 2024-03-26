.text

.macro push_reg %reg
	addi sp, sp, -0x4
	sw %reg, 0x0 (sp)
.end_macro

.macro pop_reg %reg
	lw %reg, 0x0 (sp)
	addi sp, sp, 0x4
.end_macro
