CON

  _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

  topFreq = 1_000_367
  bottomFreq = 500_184

PUB soundTest | direction, f

  ctra[30..26]:=%00100
  ctra[5..0]:=0

  frqa:=bottomFreq
  dira[0]~~

  f:=bottomFreq
  direction:=1

  repeat
    if f < bottomFreq
      direction:=1
    if f > topFreq
      direction:=-1

    f+=(direction<<8)

    frqa:=f

    waitcnt(clkfreq >> 7 + cnt)

