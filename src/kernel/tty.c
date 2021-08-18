#include <kernel/tty.h>
#include <arch/i686/vga.h>
#include <string.h>
#include <arch/i686/inline-asm.h>

size_t terminal_row;
size_t terminal_column;
uint8_t terminal_color;
uint16_t* terminal_buffer;

static void terminal_clear_row(void) {
	for (size_t x = 0; x < VGA_WIDTH; x++) {
	    const size_t index = terminal_row * VGA_WIDTH + x;
		terminal_buffer[index] = vga_entry(' ', terminal_color);
	}
}

static inline void terminal_setcolor(uint8_t color) 
{
	terminal_color = color;
}

static inline void terminal_incrementrow(void) {
	if(++terminal_row == VGA_HEIGHT) {
		terminal_row = 0;
	}
    terminal_clear_row();
}

static inline void terminal_resetrow(void) {
	terminal_row = 0;
}

static inline void terminal_incrementcolumn(void) {
	if(++terminal_column == VGA_WIDTH) {
		terminal_column = 0;
	}
}

static inline void terminal_resetcolumn(void) {
	terminal_column = 0;
}
 
void terminal_initialize(void) 
{
	terminal_row = 0;
	terminal_column = 0;
	terminal_color = vga_entry_color(VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK);
	terminal_buffer = (uint16_t*) 0xC03FF000;
	for (size_t y = 0; y < VGA_HEIGHT; y++) {
		for (size_t x = 0; x < VGA_WIDTH; x++) {
			const size_t index = y * VGA_WIDTH + x;
			terminal_buffer[index] = vga_entry(' ', terminal_color);
		}
	}
}
 
void terminal_putentryat(char c, uint8_t color, size_t x, size_t y) 
{
	const size_t index = y * VGA_WIDTH + x;
	switch(c) {
		case '\n':
			terminal_incrementrow();
			terminal_resetcolumn();
			break;
		default:
			terminal_buffer[index] = vga_entry(c, color);
			terminal_incrementcolumn();
			if(terminal_column == 0) {
				terminal_incrementrow();
			}
	}
}
 
void terminal_putchar(char c) 
{
	terminal_putentryat(c, terminal_color, terminal_column, terminal_row);

	/*if (++terminal_column == VGA_WIDTH) {
		terminal_column = 0;
		if (++terminal_row == VGA_HEIGHT)
			terminal_row = 0;
	}*/
}
 
void terminal_write(const char* data, size_t size) 
{
	for (size_t i = 0; i < size; i++)
		terminal_putchar(data[i]);
    uint16_t pos = terminal_row * VGA_WIDTH + terminal_column;
 
	outb(0x3D4, 0x0F);
	outb(0x3D5, (uint8_t) (pos & 0xFF));
	outb(0x3D4, 0x0E);
	outb(0x3D5, (uint8_t) ((pos >> 8) & 0xFF));
}
 
void terminal_writestring(const char* data) 
{
	terminal_write(data, strlen(data));
}
