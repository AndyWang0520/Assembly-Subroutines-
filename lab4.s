	.text
	.global _start
	.org 0

	.equ	JTAG_UART_BASE,	0x10001000
	.equ	DATA_OFFSET,	0
	.equ	STATUS_OFFSET,	4
	.equ	WSPACE_MASK,	0xFFFF

_start:
	movia 	sp, 0x7FFFFC
	
	movia	r2, TEXT
	call	PrintString
	
	movia 	r6,LIST
	movia	r3, N
	ldw 	r3, 0(r3)
loop:
	ldbu 	r2, 0(r6)
	call 	PrintHexByte

	movia r2,'?'
	call PrintChar
	movia r2,''
	call PrintChar

	call GetChar
	call PrintChar
	mov	r5, r2

	movia r2,'\n'
	call PrintChar

	movia	r4, 'Z'
	bne	r5, r4, NotReplace
	
	stb	r0, 0(r6)
NotReplace:
	subi	r3, r3, 1
	addi	r6, r6, 1
	bgt	r3, r0, loop



_end:
	break

GetChar:
	subi	sp, sp , 8
	stw	r3, 4(sp)
	stw	r4, 0(sp)		#st
	movia	r3, JTAG_UART_BASE
gc_loop:
	ldwio	r2, DATA_OFFSET(r3)	#data = read JTAG data
	andi	r4, r2, 0x8000		#st = data AND 0x8000

	beq	r4, r0, gc_loop		#while st is zero
	andi	r2, r2, 0xFF		#data = data AND 0xFF
	
	ldw	r3, 4(sp)
	ldw	r4, 0(sp)
	addi	sp, sp, 8
	ret
#-------------------------------------------------------------------------------------
PrintByteList:
	subi	sp, sp, 16
	stw		r2, 12(sp)
	stw		r3, 8(sp)
	stw		r4, 4(sp)
	stw		ra, 0(sp)

	mov		r4, r2
	
pbl_loop:

	movi	r2, '0'
	call	PrintChar
	movi	r2, 'x'
	call 	PrintChar
	ldbu	r2, 0(r4)
	call	PrintHexByte
	movi	r2, ' '
	call	PrintChar

	addi	r4, r4, 1
	subi	r3, r3, 1
	bgt		r3, r0, pbl_loop
pbl_end_loop:

	movi	r2, '\n'
	call	PrintChar

	ldw	r2, 12(sp)
	ldw	r3, 8(sp)
	ldw	r4, 4(sp)
	ldw	ra, 0(sp)
	addi	sp, sp, 16
	ret

#-------------------------------------------------------------------------------------

PrintHexByte:
	subi	sp, sp, 12
	stw		r2, 8(sp)
	stw		r3, 4(sp)
	stw		ra, 0(sp)
	
	mov 	r3, r2
	srli	r2, r3, 4
	call	PrintHexDigit
	
	andi	r2, r3, 0xF
	call	PrintHexDigit
	
	
	ldw		r2, 8(sp)
	ldw		r3, 4(sp)
	ldw		ra, 0(sp)
	addi	sp, sp, 12
	ret
	
#-------------------------------------------------------------------------------------

PrintHexDigit:
	subi	sp, sp, 12
	stw		r2, 8(sp)
	stw		r3, 4(sp)
	stw		ra, 0(sp)
phd_if:
	movi	r3, 10
	bge		r2, r3, phd_else
phd_then:
	addi	r2, r2, '0'
	br		phd_end_if
phd_else:
	subi	r2, r2, 10
	addi	r2, r2, 'A'
phd_end_if:
	call	PrintChar
	ldw		r2, 8(sp)
	ldw		r3, 4(sp)
	ldw		ra, 0(sp)
	addi	sp, sp, 12
	ret

#-------------------------------------------------------------------------------------

PrintString:
	subi	sp, sp, 12
	stw		r2, 8(sp)
	stw		r3, 4(sp)
	stw		ra, 0(sp)
	
	mov		r3, r2
ps_loop:
	ldbu	r2, 0(r3)
ps_if:
	beq		r2, r0, ps_end_loop
ps_then:
	call	PrintChar
	addi	r3, r3, 1
	br		ps_loop
ps_end_loop:
	ldw		r2, 8(sp)
	ldw		r3, 4(sp)
	ldw		ra, 0(sp)
	addi	sp, sp, 12
	ret

#-------------------------------------------------------------------------------------

PrintChar:
	subi	sp, sp , 8
	stw		r3, 4(sp)
	stw		r4, 0(sp)
	movia	r3, JTAG_UART_BASE
pc_loop:
	ldwio	r4, STATUS_OFFSET(r3)
	andhi	r4, r4, WSPACE_MASK
	beq		r4, r0, pc_loop
	stwio	r2, DATA_OFFSET(r3)
	
	ldw		r3, 4(sp)
	ldw		r4, 0(sp)
	addi	sp, sp, 8
	ret
	
#-------------------------------------------------------------------------------------

		.org	0x1000

N:		.word	4

LIST:	.byte	0x88, 0xA3, 0xF2, 0x1C

TEXT:	.asciz	"Lab 4\n"
	.end
	