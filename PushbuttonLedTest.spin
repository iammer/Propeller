'' File: PushbuttonLedTest.spin
'' Test program for the Propeller Education Lab "PE Platform Setup"

CON

  _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

  LEDs_START      = 16                       ' Start of I/O pin group for on/off signals
  LEDs_END        = 23                       ' End of I/O pin group for on/off signals
  PUSHBUTTON      = 0                        ' Pushbutton Input Pin

PUB ButtonBlinkSpeed                         ' Main method

  '' Sends on/off (3.3 V / 0 V) signals at approximately 2 Hz. 

  dira[LEDs_START..LEDs_END]~~               ' Set entire pin group to output

  repeat                                     ' Endless loop

    '! outa[LEDs_START..LEDs_END]             ' Change the state of pin group


    waitcnt(clkfreq / 4 + cnt)
    outa[LEDs_START .. LEDs_END] := scan_pads(clkfreq / 100)


pub scan_pads(delay) : pads | t

  outa[0..7]~~                                            ' "charge" pads
  dira[0..7]~~
  dira[0..7]~                                             ' release to inputs
  waitcnt(delay + cnt)                                          ' give time for "touch"

  pads := %1111_1111 & !ina[0 .. 7]                         ' return touched pads

