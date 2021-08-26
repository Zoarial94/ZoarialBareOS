file ./bin/ZoarialBareOS.bin
target remote :1234

b kernel_main
b isr_keyboard
c
