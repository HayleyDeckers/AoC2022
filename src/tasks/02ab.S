
.section .rodata
.align 16
input_2_start:
.incbin "data/02_input.txt"
input_2_end:
.align 4
sub_mask: .4byte 0x0a582041
.align 1
lut_a:
//they play rock
.byte 3+1 //draw, rock
.byte 6+2 //win, paper
.byte 0+3 //lose, scissors
// they play paper
.byte 0+1 //lose, rock
.byte 3+2 //draw, paper
.byte 6+3 //win, scissors
//they play scissors
.byte 6+1 //win, rock
.byte 0+2 //lose, paper
.byte 3+3 //draw, scissors
.align 1
lut_b: //todo: could merge LUTs and use a single load.
//they play rock
.byte 0+3 //lose, scissors
.byte 3+1 //draw, rock
.byte 6+2 //win, paper
//they play paper
.byte 0+1 //lose, rock
.byte 3+2 //draw, paper
.byte 6+3 //win scissors
//they play scissors
.byte 0+2 //lose, paper
.byte 3+3 //draw, scissors
.byte 6+1 //win, rock
.section ".text"
start_2ab:
mov x29, x30
adr x7, lut_a
adr x12, lut_b
adr x4, sub_mask
ldr w4, [x4]
adr x0, input_2_start
adr x3, input_2_end
mov w9, 3
sub x3, x3, x9 //subtract 3 from then end to account for trailing \n
mov x1, xzr
mov x5, xzr
mov x6, xzr
mov x11, xzr
load_2ab:
ldr w2, [x0], 4 //[opponent][space][your move][\n]
sub w2, w2, w4 // [0,1,2][0][1,2,3][0]
ubfx w5, w2, 16, 8 // you
and w6, w2, 0xff // opponent
//create score index in lut
madd w6, w6,w9,w5 //offset into lut by opponent*3  and self * 1
//load lut
ldrb w8, [x7, x6]
ldrb w10, [x12, x6]
add x1, x1, x8
add x11, x11, x10
cmp x0, x3
blt load_2ab
mov x0, x11
ret x29
