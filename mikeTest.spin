CON

  _clkmode        = xtal1 + pll16x
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

OBJ

   pst : "Parallax Serial Terminal"

PUB serialTest | lastCnt

  pst.start(115200)
  ctra[5..0]:=13
  ctra[30..26]:=%01010
  frqa:=1

  repeat
    phsa:=0
    waitcnt(clkfreq+cnt)
    pst.Dec(phsa)
    pst.NewLine

