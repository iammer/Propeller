CON

  _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

  dpin = 12
  cpin = 13
  rpin = 14

PUB s2pTest | b, c
  dira[dpin]~~
  dira[cpin]~~
  dira[rpin]~~

  c:=0

  repeat
    b:=c
    outa[rpin]~~
    outa[dpin]~~
    outa[cpin]~~
    outa[cpin]~

    repeat 7
      outa[dpin]:=(b & 1)
      outa[cpin]~~
      b>>=1
      outa[cpin]~

    outa[rpin]~
    c++
