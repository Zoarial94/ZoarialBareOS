#!/bin/fish
set -gx VM_NAME ZoarialBareOS

echo "VM_NAME: $VM_NAME"
set VM_STATE (virsh domstate $VM_NAME)
echo "VM State: $VM_STATE"
switch (string trim "$VM_STATE")
    case "shut off" crashed
        virsh start $VM_NAME
    case "*"
        virsh reset $VM_NAME
end
