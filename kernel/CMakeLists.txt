
add_executable(kernel)

target_sources(kernel
	PRIVATE
		kernel.c
		panic.c
		panic.h
		stackProtection.c
		tty.c
		
		arch/i686/memory.h

		arch/i686/boot.S

		arch/i686/gdt.S
		arch/i686/gdt.c
		arch/i686/gdt.h

		arch/i686/vga.c
		arch/i686/vga.h

		arch/i686/driver/PS2/keyboard_isr.S
		arch/i686/driver/PS2/ps2.c

		arch/i686/interrupts/idt.S
		arch/i686/interrupts/idt.c
		arch/i686/interrupts/pic.c
		arch/i686/interrupts/exceptionHandlers/exception_handlers.S

		libc/stdio/printf.c
		libc/stdio/putchar.c
		libc/stdio/puts.c
		libc/stdlib/abort.c
		libc/string/memcmp.c
		libc/string/memcpy.c
		libc/string/memmove.c
		libc/string/memset.c
		libc/string/strlen.c

		# The linker is a dependency (source file)
		arch/i686/linker.lds

		grub.cfg
)

#add_custom_command(
#	OUTPUT ${CMAKE_BINARY

set(PREPROCESSED_LINKER_FILE "${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/kernel.dir/linker.lds")

# Override the default command for the linker file
# (add_custom_command overrides what CMake will do to the dependencies)
add_custom_command(
	OUTPUT CMakeFiles/kernel.dir/linker.lds
	COMMAND "${CMAKE_C_COMPILER}" -E -P -x c-header -I include/ -I ${CMAKE_SOURCE_DIR} "${CMAKE_CURRENT_SOURCE_DIR}/arch/i686/linker.lds" -o ${PREPROCESSED_LINKER_FILE}
	MAIN_DEPENDENCY "/home/hwhite/Projects/ZoarialBareOS/kernel/arch/i686/linker.lds"
    COMMENT "Preprocessing linker.lds"
    VERBATIM
)

# Give the linker options
target_link_options(kernel PRIVATE LINKER:-T ${PREPROCESSED_LINKER_FILE} -ffreestanding -O2 -nostdlib -lgcc)

# If the linker files changes, then only re-link
set_target_properties(kernel PROPERTIES LINK_DEPENDS "kernel/CMakeFiles/kernel.dir/linker.lds")


