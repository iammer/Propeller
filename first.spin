CON

  _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

  LEDs_START      = 16
  LEDs_END        = 23
  PUSHBUTTON      = 0

var

  byte scanVal
  long scanStack[12]

PUB ButtonBlinkSpeed

  cognew(scanCog(clkfreq/100),@scanStack)

  dira[LEDs_START..LEDs_END]~~

  repeat

    '! outa[LEDs_START..LEDs_END]


    waitcnt(clkfreq + cnt)
    outa[LEDs_START .. LEDs_END] := scanVal


pub scanCog(delay) | pads

  repeat
    outa[0..7]~~
    dira[0..7]~~
    dira[0..7]~
    waitcnt(delay+cnt)
    pads := $ff & !ina[0..7]
    if pads<>0
      scanVal:=pads
      waitcnt((delay * 2) +cnt)



