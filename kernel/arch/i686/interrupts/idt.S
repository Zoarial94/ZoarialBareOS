.section .data
idtr:
    .short 0
    .long 0

.section .text
.global setIdt
.type setIdt, @function

# Automatically removes 1 from IDT size
setIdt:
    movl 4(%esp), %eax
    movl %eax, (idtr + 2)
    movw 8(%esp), %ax
    dec %ax # sub 1 per the IDT standart
    movw %ax, idtr
    lidt idtr
    ret
