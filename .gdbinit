file ./bin/ZoarialBareOS.bin
target remote :1234

b _start
b kernel_main
c
