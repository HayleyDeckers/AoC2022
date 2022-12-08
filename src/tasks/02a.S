
.section .rodata
.align 16
input_2_start:
.incbin "data/02_input.txt"
input_2_end:
debug: .asciz "\r\n\tintermediate value:"
debug2: .asciz "\r\n\t\t -"
final: .asciz "\r\nfinal value:"
.align 16
sub_mask: .4byte 0x0a582041
.align 16
lut: //todo: variable rotate [x,0,6,3]?
//they play rock
.byte 3
.byte 6
.byte 0
// they play paper
.byte 0
.byte 3
.byte 6
//they play scissors
.byte 6
.byte 0
.byte 3
.section ".text"
start_2a:
mov x29, x30
adr x7, lut
adr x4, sub_mask
ldr w4, [x4]
adr x0, input_2_start
adr x3, input_2_end
mov w9, 3
sub x3, x3, x9 //subtract 3 from then end to account for trailing \n
mov x1, xzr
mov x5, xzr
mov x6, xzr
load_2a:
ldr w2, [x0], 4 //[opponent][space][your move][\n]
sub w2, w2, w4 // [0,1,2][0][1,2,3][0]
ubfx w5, w2, 16, 8 // you
and w6, w2, 0xff // opponent
add x1, x1, 1 //add score for played
add x1, x1, x5
//add play score
madd w6, w6,w9,w5 //offset into lut by opponent*3  and self * 1
ldrb w8, [x7, x6]
add x1, x1, x8
cmp x0, x3
blt load_2a
ret x29
