CON

  _clkmode        = xtal1 + pll16x
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

  clkspd=80_000_000

PUB asmTest
  DIRA[23..16]~~
  COGINIT(0, @startAsm, 0)


DAT
        org 0
startAsm
       mov dira, mask
       shr waitTime, #5
       mov counter, cnt
       add counter, waitTime
:loop
       mov outa, a
       shl a, #1
       and a, mask wz
       if_z mov a, #1
       if_z shl a, #16
       waitcnt counter, waitTime
       jmp #:loop
       'jmp $-1

a long $FF0000
mask long $FF0000
counter long 0
waitTime long 60_000_000

fit
