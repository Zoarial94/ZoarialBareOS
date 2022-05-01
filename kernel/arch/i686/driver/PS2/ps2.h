#ifndef PS2_H
#define PS2_H

#include <kernel/arch/i686/driver/PS2/constants.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

extern const uint8_t PS2_keyboard_buf[PS2_KEYBOARD_BUF_SIZE];
extern size_t PS2_keyboard_index_front;
extern size_t PS2_keyboard_index_back;

uint8_t PS2_driver_initialize(void);

/*
 * Status Register
 **/
uint8_t PS2_controller_read(void);
/*
 * Command Register
 **/
void PS2_controller_write(uint8_t data);

// R/W from data port
uint8_t PS2_data_read(void);
void PS2_data_write(uint8_t data);

// Poll for the read and write status bit in the status register
bool PS2_poll_read_status(void);
bool PS2_poll_write_status(void);

// Wait for read to set or write to clear
void PS2_wait_on_write_status(void);
void PS2_wait_on_read_status();

// Wait for read to set or write to clear on a timeout
bool PS2_wait_on_read_timeout(uint32_t timeout);
bool PS2_wait_on_write_timeout(uint32_t timeout);

// Disable IRQ 1 and 12
void PS2_disable_irq(void);

// Disable Port1 and Port2 devices
void PS2_disable_devices(void);

//
bool PS2_controller_exists(void);

#endif
