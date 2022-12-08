.include "src/io.S"
.include "src/tasks/01ab.S"
.include "src/tasks/02ab.S"

.section .vector_table
VECTOR_TABLE: .fill 10, 8, 0
GPIO_BASE = 0xFE000000 + 0x200000
PWR_BASE = 0xFE000000 + 0x100000

.section .rodata
led_off: .asciz "\r\nTurning LED off..."
led_on: .asciz "\r\nTurning LED on!"
waiting: .asciz "\r\nwaiting on 'r' signal!"
invalid_signal: .asciz "\invalid signal: "
//not read-only but ssssh we haven;t implemented mmu anyway
char: .asciz "X\r\n"
restart_start: .asciz "rebooting..."
rebooting: .asciz "NOW\r\n"
dot: .asciz "."

msg_1a: .asciz "\r\nSolution 1a: "
msg_1b: .asciz "\r\nSolution 1b: "
msg_2a: .asciz "\r\nSolution 2a: "
msg_2b: .asciz "\r\nSolution 2b: "

.align 4
timeout: .4byte 1 << 12 //must start with 000, 1<<16 = 1 second according to linux but seems to be 16?

.section ".text.boot"
.global start
.global halt
start:
//load special register
mrs x0, MPIDR_EL1
//mask of the cpu-number
and x0, x0, 3
//halt if not cpu0
cbnz x0, halt
//set-up stack pointer to point to start of text segment, growing down from there.
mov x0, 0x80000
mov  sp, x0
bl setup_miniuart

//do 1
bl set_watchdog
adr x1, msg_1a
bl print_str
bl start_1ab
str x0, [sp, #-16]!
bl print_dec
adr x1, msg_1b
bl print_str
ldr x1, [sp], 16
bl print_dec

// do 2
bl set_watchdog
adr x1, msg_2a
bl print_str
bl start_2ab
str x0, [sp, #-16]!
bl print_dec
adr x1, msg_2b
bl print_str
ldr x1, [sp], 16
bl print_dec

wait_for_restart:
//unset watchdog, code below is tested and works
bl stop_watchdog
adr x1, waiting
bl print_str

mov w0, 0x5000
movk w0, 0xFE21, lsl 16 

wait_read_queue:
ldr w4, [x0, MU_STAT_REG]
and w5, w4, 0xF0000
cbz w5, wait_read_queue
ldr w2, [x0, MU_IO_REG]
and w3, w2, 0xff
cmp w3, '1'
beq turn_led_on
cmp w3, '2'
beq turn_led_off
cmp w3, 'r'
beq restart
//else invalid key pressed
adr x1, invalid_signal
bl print_str
adr x1, char
strb w3, [x1]
bl print_str
b wait_read_queue
restart:
adr x1, restart_start
bl print_str
//load the secret password | timeout value
mov w1, 1
bl set_watchdog_to
//halt loop for cores 1..=3.
adr x1, rebooting
bl print_str
spin:
adr x1, dot
bl print_str
b spin

halt: 
wfi
b halt

turn_led_off:
mov     w8, wzr
mov     w9, #0x400
movk    w8, #0xfe20, lsl #16
str     w9, [x8, 0x2c]
b wait_read_queue

turn_led_on:
mov     w8, wzr
mov     w9, #0x400
movk    w8, #0xfe20, lsl #16
str     w9, [x8, 0x20]
b wait_read_queue

set_watchdog:
adr x1, timeout
ldr w1, [x1]
set_watchdog_to:
movz x0, 0xfe10, lsl 16
movz w2, 0x5a00, lsl 16
orr w1, w1, w2
// put it into wdog
str w1, [x0, 0x24]
//read RTSC
ldr w2, [x0, 0x1c]
mov w6, 0xffcf
movk w6, 0xffff, lsl 16
and w3, w2, w6
mov w4, 0x20
movk w4, 0x5a00, lsl 16
orr w5, w3,w4
//write it back to pm_rstc
str w5, [x0, 0x1c]
ret

stop_watchdog:
movz x0, 0xfe10, lsl 16 
mov w2, 0x0102 //reset flag
movk w2, 0x5a00, lsl 16 //password
str w2, [x0, 0x1c]
ret
