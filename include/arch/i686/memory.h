#ifndef MEMORY_H
#define MEMORY_H

// Kernel lives in top 1GB 
#define PAGE_OFFSET 0xC0000000

// Allow 16 entries into the GDT
// 4 entires for ring 0/3 and 12 for TSS
#define GDT_SIZE 16
#define IDT_SIZE 256
#define LDT_SIZE 16 // Not sure how many to have now. Currently at 16

#endif
