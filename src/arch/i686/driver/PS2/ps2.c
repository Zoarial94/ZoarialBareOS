#include <arch/i686/driver/PS2/ps2.h>
#include <arch/i686/driver/PS2/constants.h>
#include <arch/i686/pic.h>
#include <arch/i686/inline-asm.h>
#include <stdio.h>

uint8_t PS2_data_read(void) {
    return inb(PS2_DATA_PORT);
}

void PS2_data_write(uint8_t data) {
    outb(PS2_DATA_PORT, data);
}

/* 
 * Status Register 
 **/
static uint8_t PS2_controller_read(void) {
    return inb(PS2_STATUS_REGISTER);
}

/*
 * Command Register 
 **/
static void PS2_controller_write(uint8_t data) {
    outb(PS2_COMMAND_REGISTER, data);
}

static void wait_on_write_status() {
    while((PS2_controller_read() & 2) != 0 ) {
        io_wait();
    }
}

static void wait_on_read_status() {
    while((PS2_controller_read() & 1) == 0) {
        io_wait();
    }
}


static void disable_irq(void) {
    PIC_set_mask(PIC_get_mask() | PS2_PORT1_IRQ | PS2_PORT2_IRQ);
}

static void disable_devices(void) {
    wait_on_write_status();
    PS2_controller_write(CMD_DISABLE_PORT1);
    wait_on_write_status();
    PS2_controller_write(CMD_DISABLE_PORT2);
}


bool PS2_controller_exists(void) {
    // TODO: Use APCI to determine if the PS2 controller exists
    return true; 
}

/* 
 * Return some information back
 * Bit 0 : Port 1 is working
 * Bit 1 : Port 2 is working
 *
 * */

uint8_t PS2_driver_initialize(void) {
    /*
     * https://wiki.osdev.org/"8042"_PS/2_Controller
     * Step 1: Init USB controllers
     * Step 2: Determine if PS/2 controller exists
     * Step 3: Disable devices;
     * Step 4: Flush the Output Buffer
     * Step 5: Set the contoller configuration byte
     * Step 6: Perform Controller Self Test
     * Step 7: Determine if there are 2 channels
     * Step 8: Perform Interface Tests
     * Step 9: Enable Devices
     * Step 10 Reset Devices
     **/
    printf("In PS2 driver.\n");
    if(!PS2_controller_exists()) {
        printf("No controller exists\n");
        return 0;
    }
    printf("PS2 controller exists\n");

    printf("Disabling PS2 IRQs...");
    disable_irq();
    printf("done\n");

    wait_on_write_status();
    PS2_controller_write(CMD_READ_CTRL_CONF);
    wait_on_read_status();
    printf("PS2 CTRL CONF byte: 0x%x\n", PS2_data_read());

    printf("Disabling PS2 devices...");
    disable_devices();
    printf("done\n");

    PS2_controller_write(CMD_READ_CTRL_CONF);
    wait_on_read_status();
    printf("PS2 CTRL CONF byte: 0x%x\n", PS2_data_read());

    return 0;

}
