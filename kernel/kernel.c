#include <kernel/arch/i686/gdt.h>
#include <kernel/arch/i686/idt.h>
#include <kernel/arch/i686/pic.h>

#include <kernel/arch/i686/driver/PS2/ps2.h>

#include <kernel/tty.h>
#include <stdbool.h>
#include <multiboot/multiboot.h>
#include <stdio.h>

#include <kernel/arch/i686/inline-asm.h>
 
/* Check if the compiler thinks you are targeting the wrong operating system. */
#if defined(__linux__)
#error "You are not using a cross-compiler, you will most certainly run into trouble"
#endif
 
/* This tutorial will only work for the 32-bit ix86 targets. */
#if !defined(__i386__)
#error "This tutorial needs to be compiled with a ix86-elf compiler"
#endif

extern multiboot_info_t _kernel_physical_memmap;


void kernel_main(multiboot_info_t* mbt, unsigned int magic) 
{

	/* Initialize architechure specific features/attribtes */
	GDT_initialize();

	IDT_initialize();

    PIC_initialize();

	//TODO: research and create LDT
	//LDT_initialize();

	/* Initialize terminal interface */
	terminal_initialize();
	
	terminal_writestring("Hello, kernel World! (IDT) \nHello again!! And one more time!\n");

	printf("Printing 12345: %d\n", 12345);
	printf("Printing 0xdeadbeef: 0x%x\n", 0xdeadbeef);
	printf("Magic is: 0x%x\n", magic);
	const unsigned int memmap_offset = (unsigned int)&_kernel_physical_memmap - (unsigned int)mbt;
	printf("Multiboot info physical address: 0x%x\n", mbt);
	mbt = &_kernel_physical_memmap;
	printf("Multiboot info virtual address: 0x%x\n", mbt);
	printf("Offset: 0x%x\n", memmap_offset);
	printf("\nMultiboot Memory Map Length: 0x%x\n", mbt->mmap_length);

	typedef multiboot_memory_map_t mmap_entry_t;
	
	mmap_entry_t* entry = (mmap_entry_t*)(mbt->mmap_addr);
	printf("Entry physical address at: 0x%x\n", entry);
	printf("Entry virtual address at: 0x%x\n", ((unsigned int)entry + memmap_offset));
	entry = (mmap_entry_t*)((unsigned int)entry + memmap_offset);
	printf("Entry virtual address at: 0x%x\n", entry);

    puts("addr and len as 64-bit integers:");
	while(entry < (mmap_entry_t*)((mbt->mmap_addr + memmap_offset) + mbt->mmap_length)) {
		// do something with the entry
		printf("Addr:0x%lx, Len:0x%lx Type:%d\n", entry->addr, entry->len, entry->type);


		entry = (mmap_entry_t*) ((unsigned int) entry + entry->size + sizeof(entry->size));
	}
	
    printf("PIC Masks: 0x%x\n", PIC_get_mask());
    PIC_set_mask(0xFFFF);
    printf("PIC Masks: 0x%x\n", PIC_get_mask());
	
    PS2_driver_initialize();

    printf("PIC Masks: 0x%x\n", PIC_get_mask());

    enable_interrupts();
    puts("Testing again");
    while(1) {
      puts("In halt loop");
      halt();
      puts("Interrupt occured.");
    }


}
