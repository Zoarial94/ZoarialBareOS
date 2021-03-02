#include <arch/i686/gdt.h>

#include <kernel/tty.h>
#include <stdbool.h>
#include <multiboot/multiboot.h>
#include <stdio.h>
 
/* Check if the compiler thinks you are targeting the wrong operating system. */
#if defined(__linux__)
#error "You are not using a cross-compiler, you will most certainly run into trouble"
#endif
 
/* This tutorial will only work for the 32-bit ix86 targets. */
#if !defined(__i686__)
#error "This tutorial needs to be compiled with a ix86-elf compiler"
#endif


void kernel_main(multiboot_info_t* mbt, unsigned int magic) 
{

	/* Initialize architechure specific features/attribtes */
	GDT_initialize();

	/* Initialize terminal interface */
	terminal_initialize();
	
	/* Newline support is left as an exercise. */
	terminal_writestring("Hello, kernel World!\nHello again!! And one more time!\n");

	printf("Printing 12345: %d\n", 12345);
	printf("Printing 0xdeadbeef: 0x%x\n", 0xdeadbeef);
	printf("Magic is: 0x%x\n", magic);
	printf("At address: 0x%x\n", mbt);
	// printf("Memory Map Length: 0x%x\n", mbt->mmap_length);

	typedef multiboot_memory_map_t mmap_entry_t;
	/*
	mmap_entry_t* entry = mbt->mmap_addr;
	while(entry < mbt->mmap_addr + mbt->mmap_length) {
		// do something with the entry
		printf("Size: 0x%x, Addr:0x%x, Len:0x%x Type:%d\n", entry->size, entry->addr, entry->len, entry->type);
		entry = (mmap_entry_t*) ((unsigned int) entry + entry->size + sizeof(entry->size));
	}
	*/
}
