#!/bin/fish
rm -r ../build/isodir

grub2-file --is-x86-multiboot ../build/kernel/kernel
if test $status = 0
    echo "File is multiboot"
else
    echo "File is not multiboot"
    exit 1
end

mkdir -p ../build/isodir/boot/grub
if test $status = 0
    echo "File is multiboot"
else
    echo "File is not multiboot"
    exit 1
end

cp ../build/kernel/kernel ../build/isodir/boot/ZoarialBareOS.bin
cp ../kernel/grub.cfg ../build/isodir/boot/grub/grub.cfg
grub2-mkrescue -o ../build/ZoarialBareOS.iso ../build/isodir
