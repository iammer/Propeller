CON

  _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

  pin=18
OBJ

  'pst: "Parallax Serial Terminal"

PUB start

  pst.start(115200)

  ctra[30..26]:=%11010
  ctra[5..0]:=pin
  frqa:=1

  dira[18]~
  repeat
    'dira[pin]~~
    phsa:=0
    'dira[pin]~
    waitcnt(cnt+clkfreq>>2)
    'pst.dec(phsa)
    'pst.NewLine


