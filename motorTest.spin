CON

  _clkmode        = xtal1 + pll16x
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

PUB motorTest

ctra[30..26]:=%00110
ctra[5..0]:=14
frqa:=$b8000000

dira[13..17]~~
'outa[14]~~
outa[15]~~
outa[17]~~

  repeat
    !outa[13]
    !outa[16]
    waitcnt(clkfreq+cnt)
    !outa[15]
    !outa[17]

    waitcnt(clkfreq*4 + cnt)
