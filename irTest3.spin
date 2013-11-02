CON

  _clkmode        = xtal1 + pll16x
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

OBJ

  qsb: "Quickstart Buttons"

PUB irTest | counter

  ctra[30..26]:=%00100
  ctra[5..0]:=12
  frqa:=2040109

  qsb.start

  'dira[12]~~

  repeat
    if qsb.testAndClear(1)
      !dira[12]
    waitcnt(cnt+clkfreq>>4)
    'waitcnt(0)



