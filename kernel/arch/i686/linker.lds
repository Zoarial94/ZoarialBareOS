#include <kernel/arch/i686/memory.h>

/* The bootloader will look at this image and start execution at the symbol
   designated as the entry point. */
ENTRY(_start)
 
/* Tell where the various sections of the object files will be put in the final
   kernel image. */
SECTIONS
{
	/* Begin putting sections at 1 MiB, a conventional place for kernels to be
	   loaded at by the bootloader. */
	. = 1M;
 
	/* First put the multiboot header, as it is required to be put very early
	   early in the image or the bootloader won't recognize the file format.
	   Next we'll put the .text section. */

	_kernel_physical_start = .;
	.multiboot.data ALIGN(4K) : 
	{
		*(.multiboot.data)
	}

	.paging.setup.text ALIGN(4K) :
	{
		*(.paging.setup.text)
	}
	_kernel_physical_end = .;

	. += PAGE_OFFSET;
	_kernel_virtual_start = .;

	.text ALIGN(4K) : AT (ADDR (.text) - PAGE_OFFSET)
	{
		*(.text)
	}

	/* Read-only data. */
	.rodata ALIGN(4K) : AT (ADDR (.rodata) - PAGE_OFFSET)
	{
		*(.rodata*)
		
		. = ALIGN(4K);
		_kernel_physical_memmap = .;
		*(.grub_memory_map)
	}
 
	. = ALIGN(4K);
	_kernel_rw_start = .;
	/* Read-write data (initialized) */
	.data ALIGN(4K) : AT (ADDR (.data) - PAGE_OFFSET)
	{
		*(.data)
	}
 
	/* Read-write data (uninitialized) and stack */
	.bss ALIGN(4K) : AT (ADDR (.bss) - PAGE_OFFSET)
	{
		*(COMMON)
		*(.bss)
		*(.bootstrap_stack)
	}
 
	/* The compiler may produce other sections, by default it will put them in
	   a segment with the same name. Simply add stuff here as needed. */
	_kernel_end = .;
}
