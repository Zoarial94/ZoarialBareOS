#include <kernel/arch/i686/driver/PS2/constants.h>

.section .data

.align 8
.global PS2_keyboard_index
PS2_keyboard_index:
    .4byte 0
.global PS2_keyboard_used_len
PS2_keyboard_used_len:
    .4byte 0
.global PS2_keyboard_skipped_keys
PS2_keyboard_skipped_keys:
    .4byte 0


.section .bss

.align 64
.global PS2_keyboard_buf
PS2_keyboard_buf:
    .fill PS2_KEYBOARD_BUF_SIZE 


.section .text

/*
inc_front:
    incl PS2_keyboard_index_front
    lea PS2_keyboard_index_front, %eax
    lea -PS2_keyboard_buf(%eax), %eax
    cmp %eax, PS2_KEYBOARD_BUF_SIZE
    jne inc_done
    movl $0, PS2_keyboard_index_front
    jmp _end
*/



keyboard_printf_isr_string:
.string "Received code: 0x%x\n"

# Written in asm just because
.global isr_keyboard
.type isr_keyboard, @function
.align 4
isr_keyboard:
    pushal
    cld

    call PS2_data_read
    mov %eax, %ecx

    push %ecx
    push $keyboard_printf_isr_string
    call printf
    add $8, %esp

    cmpl $PS2_KEYBOARD_BUF_SIZE, PS2_keyboard_used_len
    je _skip_key

    // index_back is always one ahead
    xor %edx, %edx
    movl PS2_keyboard_used_len, %eax
    add PS2_keyboard_index, %eax
    movl $PS2_KEYBOARD_BUF_SIZE, %ebx
    div %ebx
    movb %cl, PS2_keyboard_buf(%edx)

inc_used_len:
    incl PS2_keyboard_used_len

_end:
    push $0 # 16-byte alignment
    push $1 
    call PIC_sendEOI
    pop %eax
    pop %eax

    popal
    iret

_skip_key:
    incl PS2_keyboard_skipped_keys
    jmp _end
