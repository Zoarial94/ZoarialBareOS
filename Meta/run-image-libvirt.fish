#!/bin/fish
set VM_NAME ZoarialBareOS

set VM_STATE (virsh domstate $VM)
echo "VM State: $VM_STATE"
switch (string trim "$VM_STATE")
    case "shut off" crashed
        virsh start $VM_NAME
    case "*"
        virsh reset $VM_NAME
end
