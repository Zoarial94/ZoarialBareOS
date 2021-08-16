.section .data
idtr:
    .short 0
    .long 0

.section .text
.global setIdt
.type setIdt, @function
setIdt:
    movl 4(%esp), %eax
    movl %eax, (idtr + 2)
    movw 8(%esp), %ax
    movw %ax, idtr
    lidt idtr
    ret
