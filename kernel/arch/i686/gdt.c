#include <kernel/arch/i686/gdt.h>
#include <kernel/arch/i686/memory.h>
#include <kernel/panic.h>

#define GDT_CODE_PL0 SEG_DESCTYPE(1) | SEG_PRES(1) | SEG_SAVL(0) | \
                     SEG_LONG(0)     | SEG_SIZE(1) | SEG_GRAN(1) | \
                     SEG_PRIV(0)     | SEG_CODE_EXRD
 
#define GDT_DATA_PL0 SEG_DESCTYPE(1) | SEG_PRES(1) | SEG_SAVL(0) | \
                     SEG_LONG(0)     | SEG_SIZE(1) | SEG_GRAN(1) | \
                     SEG_PRIV(0)     | SEG_DATA_RDWR
 
#define GDT_CODE_PL3 SEG_DESCTYPE(1) | SEG_PRES(1) | SEG_SAVL(0) | \
                     SEG_LONG(0)     | SEG_SIZE(1) | SEG_GRAN(1) | \
                     SEG_PRIV(3)     | SEG_CODE_EXRD
 
#define GDT_DATA_PL3 SEG_DESCTYPE(1) | SEG_PRES(1) | SEG_SAVL(0) | \
                     SEG_LONG(0)     | SEG_SIZE(1) | SEG_GRAN(1) | \
                     SEG_PRIV(3)     | SEG_DATA_RDWR
    
extern uint64_t gd_table;
extern void setGdt(void* gdt_ptr, uint16_t gdt_size);
extern void reloadSegments();


void GDT_add_descriptor(uint32_t base, uint32_t limit, uint16_t type) {
    static int GDT_pos = 0;

    if(GDT_pos - 1 >= GDT_SIZE) {
        panic("Not enough space in GDT for another descriptor!");
    }

    uint64_t *descriptor = &gd_table + GDT_pos; 

    // Create the high 32 bit segment
    *descriptor  =  limit       & 0x000F0000;         // set limit bits 19:16
    *descriptor |= (type <<  8) & 0x00F0FF00;         // set type, p, dpl, s, g, d/b, l and avl fields
    *descriptor |= (base >> 16) & 0x000000FF;         // set base bits 23:16
    *descriptor |=  base        & 0xFF000000;         // set base bits 31:24
 
    // Shift by 32 to allow for low part of segment
    *descriptor <<= 32;
 
    // Create the low 32 bit segment
    *descriptor |= base  << 16;                       // set base bits 15:0
    *descriptor |= limit  & 0x0000FFFF;               // set limit bits 15:0

    GDT_pos++;
}

void GDT_initialize(void) {
    static const uint32_t MAX_LIMIT = 0xFFFFF;

    GDT_add_descriptor(0, 0, 0);
    GDT_add_descriptor(0, MAX_LIMIT, (GDT_CODE_PL0));
    GDT_add_descriptor(0, MAX_LIMIT, (GDT_DATA_PL0));
    GDT_add_descriptor(0, MAX_LIMIT, (GDT_CODE_PL3));
    GDT_add_descriptor(0, MAX_LIMIT, (GDT_DATA_PL3));

    setGdt(&gd_table, GDT_SIZE*8);
    reloadSegments();

}
