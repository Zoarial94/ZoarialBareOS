#include <arch/i686/gdt.h>

#include <kernel/tty.h>
#include <stdbool.h>
 
/* Check if the compiler thinks you are targeting the wrong operating system. */
#if defined(__linux__)
#error "You are not using a cross-compiler, you will most certainly run into trouble"
#endif
 
/* This tutorial will only work for the 32-bit ix86 targets. */
#if !defined(__i686__)
#error "This tutorial needs to be compiled with a ix86-elf compiler"
#endif


void kernel_main(void) 
{

	/* Initialize architechure specific features/attribtes */
	GDT_initialize();

	/* Initialize terminal interface */
	terminal_initialize();
 
	/* Newline support is left as an exercise. */
	terminal_writestring("Hello, kernel World!\nHello again!! And one more time!");
}
