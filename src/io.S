MU_IO_REG =  0x40
ENABLES = 0x04
MU_CNTL_REG = 0x60
MU_LCR_REG =  0x4c
MU_BAUD_REG = 0x68
MU_IIR_REG = 0x48
MU_STAT_REG = 0x64 

.section .rodata
scratch_nr: .asciz "0xA1B2C3D4E5F6G7H8\r\n"
hex_lookup: .asciz "0123456789abcdef"
//20 digits, extra byte for +-, zero terminator
scratch_dec: .fill 22, 1, 0

.section .text
setup_miniuart:
//base address
mov w0, 0x5000
movk w0, 0xFE21, lsl 16 
// set enables to 1
mov w2, 1
str w2, [x0, ENABLES]
// disable tx, rx
str wzr, [x0, MU_CNTL_REG]
// enable 8 bit mode
mov w3, 3
str w3, [x0, MU_LCR_REG]
//baudrate register value for a baudrate of 9600 at a core frequency of 200.
mov w6, 3254
str w6, [x0, MU_BAUD_REG]
// clear fifo
mov w4, 6
str w4, [x0, MU_IIR_REG]
//enable tx/rx again
mov w5, 3
str w5, [x0, MU_CNTL_REG]
ret

print_dec:
adr x26, scratch_dec
mov x28, 1 //digits
mov x27, 10
mov x25, 10
cmp x27, x1
bgt print_dec_1
print_dec_0:
add x28, x28, 1
mul x27, x27, x25
cmp x27, x1
ble print_dec_0 
print_dec_1:
//now x27 is the first power of 10 > x1
//and x28 is the number of digits.
add x26, x26, x28
strb wzr, [x26], -1
print_dec_2:
udiv x27, x1, x25
msub x28, x27, x25, x1
mov x1, x27
add x28, x28, '0'
strb w28, [x26], -1
cbnz x27, print_dec_2
adr x1, scratch_dec
b print_str

print_hex:
//lookup table
adr x29, hex_lookup
//space to write to
adr x28, scratch_nr
mov x27, xzr
//offset by two for the 0x
add x28, x28, 2
bfxil x27, x1, 60, 4
ldrb w26, [x29, x27]
strb w26, [x28], 1
bfxil x27, x1, 56, 4
ldrb w26, [x29, x27]
strb w26, [x28], 1
bfxil x27, x1, 52, 4
ldrb w26, [x29, x27]
strb w26, [x28], 1
bfxil x27, x1, 48, 4
ldrb w26, [x29, x27]
strb w26, [x28], 1
bfxil x27, x1, 44, 4
ldrb w26, [x29, x27]
strb w26, [x28], 1
bfxil x27, x1, 40, 4
ldrb w26, [x29, x27]
strb w26, [x28], 1
bfxil x27, x1, 36, 4
ldrb w26, [x29, x27]
strb w26, [x28], 1
bfxil x27, x1, 32, 4
ldrb w26, [x29, x27]
strb w26, [x28], 1
bfxil x27, x1, 28, 4
ldrb w26, [x29, x27]
strb w26, [x28], 1
bfxil x27, x1, 24, 4
ldrb w26, [x29, x27]
strb w26, [x28], 1
bfxil x27, x1, 20, 4
ldrb w26, [x29, x27]
strb w26, [x28], 1
bfxil x27, x1, 16, 4
ldrb w26, [x29, x27]
strb w26, [x28], 1
bfxil x27, x1, 12, 4
ldrb w26, [x29, x27]
strb w26, [x28], 1
bfxil x27, x1, 8, 4
ldrb w26, [x29, x27]
strb w26, [x28], 1
bfxil x27, x1, 4, 4
ldrb w26, [x29, x27]
strb w26, [x28], 1
bfxil x27, x1, 0, 4
ldrb w26, [x29, x27]
strb w26, [x28], 1
adr x1, scratch_nr //falltrough

print_str:
mov w28, 0x8000000
//base address
mov w27, 0x5000
movk w27, 0xFE21, lsl 16 
ldrb w22, [x1], 1
cbz w22, return
wait_queue_free:
ldr w24, [x27, MU_STAT_REG]
//might be able to use an ANDS beq here
and w24, w24, 0xf000000
cmp w28,w24
//or bnz
beq wait_queue_free
str w22, [x27, MU_IO_REG]
ldrb w22, [x1], 1
cbnz w22, wait_queue_free
return:
ret

