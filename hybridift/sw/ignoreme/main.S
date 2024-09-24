  .section ".text.init","ax",@progbits
  .globl _start
  .align 2
_start:
li a0, 0xff
li a1, 0x10
addi a0, a0, 1
sd a0, 0(a1)
fence
addi a0, a0, 1
sd a0, 0(a1)
fence
addi a0, a0, 1
sd a0, 0(a1)
fence
addi a0, a0, 1
sd a0, 0(a1)
fence
li a1, 0x0
sd a0, 0(a1)
fence


