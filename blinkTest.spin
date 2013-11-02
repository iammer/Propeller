CON

  _clkmode        = xtal1 + pll16x
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

OBJ

   'pst : "Parallax Serial Terminal"

PUB blinkTest

  'pst.start(115200)

  dira[8]~~


  repeat
    !outa[8]
    waitcnt(clkfreq>>2 + cnt)
