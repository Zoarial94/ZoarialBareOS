.section .data
gdtr: 
     .short 0 # For limit storage
     .long 0 # For base storage
 
.section .text
.global setGdt
.type setGdt, @function
setGdt:
     movl 4(%esp), %eax
     movl %eax, (gdtr + 2)
     movw 8(%esp), %ax
     dec %ax # sub one per GDT standard
     movw %ax, gdtr
     lgdt gdtr
     ret

.global reloadSegments
.type reloadSegments, @function
reloadSegments:
     ljmp $0x08, $.reload_CS
.reload_CS:
     movw $0x10, %ax
     movw %ax, %ds
     movw %ax, %es
     movw %ax, %fs
     movw %ax, %gs
     movw %ax, %ss
     ret

/*
   MOV   EAX, [esp + 4]
   MOV   [gdtr + 2], EAX
   MOV   AX, [ESP + 8]
   MOV   [gdtr], AX
   LGDT  [gdtr]
   RET
*/
