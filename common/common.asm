.text
.macro exit %imm
	li a0, %imm
	li a7 0x5D
	ecall
.end_macro
