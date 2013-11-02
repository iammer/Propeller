CON

  _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

VAR

  byte c
  byte delay

PUB blinken

  dira[16..23]~~

  c := 0

  repeat
    outa[23..16] := c

    c <<= 1
    c += ((!c >< 8) & 1)

    outa[0..7]~~
    dira[0..7]~~
    dira[0..7]~
    waitcnt(clkfreq / freq + cnt)


pub scan_pads(delay) : pads

  outa[0..7]~~                                            ' "charge" pads
  dira[0..7]~~
  dira[0..7]~                                             ' release to inputs
  waitcnt(delay + cnt)                                          ' give time for "touch"

  pads := %1111_1111 & !ina[0 .. 7]
