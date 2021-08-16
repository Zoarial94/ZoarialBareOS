#include <arch/i686/idt.h>
#include <arch/i686/memory.h>
#include <kernel/panic.h>

extern uint64_t id_table;
extern void setIdt(void* idt_ptr, uint16_t idt_size);

void IDT_add_descriptor(void) {

}

void IDT_initialize(void) {

    setIdt(&id_table, IDT_SIZE*8);
}
