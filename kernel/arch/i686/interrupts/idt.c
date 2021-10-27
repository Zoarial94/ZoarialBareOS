#include <kernel/arch/i686/idt.h>
#include <kernel/arch/i686/memory.h>
#include <kernel/panic.h>
#include <kernel/arch/i686/pic.h>

extern uint64_t id_table[];
extern void setIdt(void* idt_ptr, uint16_t idt_size);
extern void isr_keyboard(void);
extern void (*isr_exception_stub_table[32])(void);

void IDT_add_descriptor(uint8_t index, void (*isr)(void), uint8_t flags) {
    uint64_t *descriptor = (id_table + index);

    *descriptor  = ((uint64_t)(uint32_t)isr << 32) & 0xFFFF000000000000;
    *descriptor |= ((uint64_t)flags << 40);

    *descriptor |= (uint32_t)isr & 0x0000FFFF;
    *descriptor |= 0x00080000;

}

void IDT_initialize(void) {

    // Add the 32 x86 defined exception handlers
    // (Defined in exception_handlers.S)
    for(int i = 0; i < 32; i++) {
        IDT_add_descriptor(i, isr_exception_stub_table[i], 0x8E);
    }
    
    // Add PS/2 keyboard handler
    IDT_add_descriptor(PIC1_INT + 1, isr_keyboard, 0x8E);

    // Set the IDT
    setIdt(&id_table, IDT_SIZE*8);
}
