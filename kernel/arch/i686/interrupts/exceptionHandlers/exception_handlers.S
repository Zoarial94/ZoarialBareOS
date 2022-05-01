print_string:
.string "In ISR: %d. Stopping.\n"

isr_exception_stub_common:
    # Check EAX for stub number
    cli
    cld

    push %eax
    push $print_string
    call printf
    hlt

isr_exception_stub_0:
	
    movl $0, %eax
    jmp isr_exception_stub_common

isr_exception_stub_1:
	
	movl $1, %eax
	jmp isr_exception_stub_common

isr_exception_stub_2:
	
	movl $2, %eax
	jmp isr_exception_stub_common

isr_exception_stub_3:
	
	movl $3, %eax
	jmp isr_exception_stub_common

isr_exception_stub_4:
	
	movl $4, %eax
	jmp isr_exception_stub_common

isr_exception_stub_5:
	
	movl $5, %eax
	jmp isr_exception_stub_common

isr_exception_stub_6:
	
	movl $6, %eax
	jmp isr_exception_stub_common

isr_exception_stub_7:
	
	movl $7, %eax
	jmp isr_exception_stub_common

isr_exception_stub_8:
	
	movl $8, %eax
	jmp isr_exception_stub_common

isr_exception_stub_9:
	
	movl $9, %eax
	jmp isr_exception_stub_common

isr_exception_stub_10:
	
	movl $10, %eax
	jmp isr_exception_stub_common

isr_exception_stub_11:
	
	movl $11, %eax
	jmp isr_exception_stub_common

isr_exception_stub_12:
	
	movl $12, %eax
	jmp isr_exception_stub_common

isr_exception_stub_13:
	
	movl $13, %eax
	jmp isr_exception_stub_common

isr_exception_stub_14:
	
	movl $14, %eax
	jmp isr_exception_stub_common

isr_exception_stub_15:
	
	movl $15, %eax
	jmp isr_exception_stub_common

isr_exception_stub_16:
	
	movl $16, %eax
	jmp isr_exception_stub_common

isr_exception_stub_17:
	
	movl $17, %eax
	jmp isr_exception_stub_common

isr_exception_stub_18:
	
	movl $18, %eax
	jmp isr_exception_stub_common

isr_exception_stub_19:
	
	movl $19, %eax
	jmp isr_exception_stub_common

isr_exception_stub_20:
	
	movl $20, %eax
	jmp isr_exception_stub_common

isr_exception_stub_21:
	
	movl $21, %eax
	jmp isr_exception_stub_common

isr_exception_stub_22:
	
	movl $22, %eax
	jmp isr_exception_stub_common

isr_exception_stub_23:
	
	movl $23, %eax
	jmp isr_exception_stub_common

isr_exception_stub_24:
	
	movl $24, %eax
	jmp isr_exception_stub_common

isr_exception_stub_25:
	
	movl $25, %eax
	jmp isr_exception_stub_common

isr_exception_stub_26:
	
	movl $26, %eax
	jmp isr_exception_stub_common

isr_exception_stub_27:
	
	movl $27, %eax
	jmp isr_exception_stub_common

isr_exception_stub_28:
	
	movl $28, %eax
	jmp isr_exception_stub_common

isr_exception_stub_29:
	
	movl $29, %eax
	jmp isr_exception_stub_common

isr_exception_stub_30:
	
	movl $30, %eax
	jmp isr_exception_stub_common

isr_exception_stub_31:
	
	movl $31, %eax
	jmp isr_exception_stub_common

.global isr_exception_stub_table
isr_exception_stub_table:
    .4byte isr_exception_stub_0
    .4byte isr_exception_stub_1
    .4byte isr_exception_stub_2
    .4byte isr_exception_stub_3
    .4byte isr_exception_stub_4
    .4byte isr_exception_stub_5
    .4byte isr_exception_stub_6
    .4byte isr_exception_stub_7
    .4byte isr_exception_stub_8
    .4byte isr_exception_stub_9
    .4byte isr_exception_stub_10
    .4byte isr_exception_stub_11
    .4byte isr_exception_stub_12
    .4byte isr_exception_stub_13
    .4byte isr_exception_stub_14
    .4byte isr_exception_stub_15
    .4byte isr_exception_stub_16
    .4byte isr_exception_stub_17
    .4byte isr_exception_stub_18
    .4byte isr_exception_stub_19
    .4byte isr_exception_stub_20
    .4byte isr_exception_stub_21
    .4byte isr_exception_stub_22
    .4byte isr_exception_stub_23
    .4byte isr_exception_stub_24
    .4byte isr_exception_stub_25
    .4byte isr_exception_stub_26
    .4byte isr_exception_stub_27
    .4byte isr_exception_stub_28
    .4byte isr_exception_stub_29
    .4byte isr_exception_stub_30
    .4byte isr_exception_stub_31

