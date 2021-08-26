#include <arch/i686/idt.h>
#include <arch/i686/memory.h>
#include <kernel/panic.h>
#include <arch/i686/pic.h>

extern uint64_t id_table[];
extern void setIdt(void* idt_ptr, uint16_t idt_size);
extern void isr_keyboard(void);

void IDT_add_descriptor(uint8_t index, uint32_t isr, uint8_t flags) {
    uint64_t *descriptor = (id_table + index);

    *descriptor  = ((uint64_t)isr << 32) & 0xFFFF000000000000;
    *descriptor |= ((uint64_t)flags << 40);

    *descriptor |= isr & 0x0000FFFF;
    *descriptor |= 0x00080000;

}

void IDT_initialize(void) {
    
    IDT_add_descriptor(PIC1_INT + 1, (uint32_t)isr_keyboard, 0x8E);

    setIdt(&id_table, IDT_SIZE*8);
}
