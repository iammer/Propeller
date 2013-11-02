CON

  _clkmode        = xtal1 + pll16x
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

PUB LowSpeed | a

  dira[16]~~

  a:=0

  repeat
    repeat 10000
      a*=37
    !outa[16]
