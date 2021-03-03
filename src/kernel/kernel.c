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

extern multiboot_info_t _kernel_physical_memmap;


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
	const unsigned int memmap_offset = (unsigned int)&_kernel_physical_memmap - (unsigned int)mbt;
	printf("At physical address: 0x%x\n", mbt);
	mbt = &_kernel_physical_memmap;
	printf("At virtual address: 0x%x\n", mbt);
	printf("Offset: 0x%x\n", memmap_offset);
	printf("Memory Map Length: 0x%x\n", mbt->mmap_length);

	typedef multiboot_memory_map_t mmap_entry_t;
	
	mmap_entry_t* entry = (mmap_entry_t*)(mbt->mmap_addr);
	printf("Entry physical address at: 0x%x\n", entry);
	printf("Entry virtual address at: 0x%x\n", ((unsigned int)entry + memmap_offset));
	entry = (mmap_entry_t*)((unsigned int)entry + memmap_offset);
	printf("Entry virtual address at: 0x%x\n", entry);

	while(entry < (mmap_entry_t*)((mbt->mmap_addr + memmap_offset) + mbt->mmap_length)) {
		// do something with the entry
		uint64_t addr = (uint64_t)entry->addr_low | (uint64_t)entry->addr_high << 32;
		uint64_t len = (uint64_t)entry->len_low | (uint64_t)entry->len_high << 32;
		printf("Addr:0x%lx, Len:0x%lx Type:%d\n", addr, len, entry->len_high, entry->len_low, entry->type);


		entry = (mmap_entry_t*) ((unsigned int) entry + entry->size + sizeof(entry->size));
	}
	
	
}
