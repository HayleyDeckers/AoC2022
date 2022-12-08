.section .rodata
input_1_start:
.incbin "data/01_input.txt"
input_1_end:
.byte '\n'
.section ".text"
start_1ab:
adr x0, input_1_start
adr x5, input_1_end
mov x1, xzr
mov x2, xzr
mov x3, xzr
mov x10, 10
mov x28, xzr
mov x27, xzr
next_character:
cmp x0, x5
b.eq end
ldrb w4, [x0], #1
cmp w4, '\n'
b.eq update_sum
sub w4, w4, '0'
madd x1, x1, x10, x4
b next_character
update_sum:
add x3, x3, x1
mov x1, xzr
ldrb w4, [x0] 
cmp w4, '\n'
bne next_character
cmp x3, x2
csel x29, x2, x3, HI
csel x2, x3, x2, HI
cmp x29, x27
csel x3, x27, x29, HI
csel x27, x29, x27, HI
cmp x3, x28
csel x28, x3, x28, HI
mov x3, xzr
b next_character
end:
mov x1, x2
add x0, x27, x28
add x0, x0, x2
ret 
