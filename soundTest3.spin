CON

  _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz


PUB soundTest3

  'ctra[30..26]:=%00100
  'ctra[5..0]:=13

  'frqa:=5397

  outa[13]~~

  dira[13]~~

  repeat
    waitcnt(cnt)
