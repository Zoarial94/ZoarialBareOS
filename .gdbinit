file ./build/kernel/kernel
target remote :1294

b kernel_main
b isr_keyboard
b isr_exception_stub_common
c
