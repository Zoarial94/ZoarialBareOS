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

bool PS2_poll_read_status(void) {
    return (PS2_controller_read() & PS2_STATUS_OUTPUT) != 0;
}

bool PS2_poll_write_status(void) {
    return (PS2_controller_read() & PS2_STATUS_INPUT) != 0;
}

static void wait_on_write_status() {
    // We want the buffer we write to to be EMPTY
    while(PS2_poll_write_status() != 0 ) {
        io_wait();
    }
}

static void wait_on_read_status() {
    // We want the buffer we read from to be FULL
    while(PS2_poll_read_status() == 0) {
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

    /* 
     * STEP 1
     **/

    /* 
     * STEP 2
     **/
    printf("In PS2 driver.\n");
    if(!PS2_controller_exists()) {
        printf("No controller exists\n");
        return 0;
    }
    printf("PS2 controller exists\n");

    /*
     * STEP 3
     **/
    printf("Disabling PS2 IRQs...");
    disable_irq();
    printf("done\n");

    wait_on_write_status();
    PS2_controller_write(CMD_READ_CTRL_CONF);
    wait_on_read_status();
    uint8_t controller_conf = PS2_data_read();
    printf("PS2 CTRL CONF byte: 0x%x\n", controller_conf);

    printf("Disabling PS2 devices...");
    disable_devices();
    printf("done\n");

    PS2_controller_write(CMD_READ_CTRL_CONF);
    wait_on_read_status();
    controller_conf = PS2_data_read();
    printf("PS2 CTRL CONF byte: 0x%x\n",controller_conf);

    /* 
     * If the bit is set (meaning port2 is disabled),
     * then we have 2 ports. If it was single channel, 
     * then disabling port2 would not affect this bit.
     * (Meaning it would still be 0)
     */
    if((controller_conf & CTRL_CONF_PORT2_CLOCK) != 0) { 
        puts("Looks like Duel Channel PS/2");
    } else {
        puts("Looks like Single Channel PS/2");
    }

    /* 
     * STEP 4
     */
    if(PS2_poll_read_status()) {
        PS2_controller_read();
    }

    /* 
     * STEP 5
     */
    controller_conf = controller_conf & ~(CTRL_CONF_PORT1_TRANS); // Clear keyboard translate bit

    wait_on_write_status();
    PS2_controller_write(CMD_WRITE_CTRL_CONF);
    wait_on_write_status();
    PS2_data_write(controller_conf);

    /*
     * STEP 6
     */

    wait_on_write_status();
    PS2_controller_write(CMD_CTRL_SELF_TEST);
    wait_on_read_status();
    uint8_t ret_status = PS2_data_read();

    switch(ret_status) {
        case CTRL_SELF_TEST_OK :
            puts("Controller Self Test is OK");
            break;
        case CTRL_SELF_TEST_FAIL :
            puts("Controller Self Test has failed");
            return 0;
        default:
            printf("Controller Self Test failed with code: 0x%x", ret_status);
    }

    /*
     * STEP 7
     */
    wait_on_write_status();
    PS2_controller_write(CMD_ENABLE_PORT2);

    controller_conf = PS2_controller_read();

    uint8_t port_status;
    const uint8_t PORT1 = 0x1;
    const uint8_t PORT2 = 0x2;
    if((controller_conf & CTRL_CONF_PORT2_CLOCK) == 0) { 
        puts("Is Duel Channel PS/2");
        port_status = PORT1 | PORT2;
    } else {
        puts("Is Single Channel PS/2");
        port_status = PORT1;
    }

    wait_on_write_status();
    PS2_controller_write(CMD_DISABLE_PORT2);

    if(PS2_poll_read_status()) {
        PS2_controller_read();
    }
    /* 
     * STEP 8
     */
    if(port_status & PORT1) {
        wait_on_write_status();
        PS2_controller_write(CMD_PORT1_SELF_TEST);
        wait_on_read_status();
        ret_status = PS2_data_read();
        if(ret_status != 0) {
            printf("Self Test on port1 failed with code: 0x%x\n", ret_status);
            port_status = port_status & ~(PORT1);
        } else {
            puts("Self Test on port1 succeeded");
        }
    }

    if(port_status & PORT2) {
        wait_on_write_status();
        PS2_controller_write(CMD_PORT2_SELF_TEST);
        wait_on_read_status();
        ret_status = PS2_data_read();
        if(ret_status != 0) {
            printf("Self Test on port2 failed with code: 0x%x\n", ret_status);
            port_status = port_status & ~(PORT2);
        } else {
            puts("Self Test on port2 succeeded");
        }
    }

    /* 
     * STEP 9
     */

    return ret_status;

}
