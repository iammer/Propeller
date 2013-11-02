CON

  _clkmode        = xtal1 + pll16x
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

OBJ

   pst : "Parallax Serial Terminal"

PUB serialTest | lastCnt

  pst.start(115200)
  ctra[5..0]:=13
  ctra[30..26]:=%01000
  frqa:=1
  outa[13]:=1

  repeat
    dira[13]~~
    waitcnt(clkfreq
    phsa:=0
    waitcnt(clkfreq/100+cnt)
    if (phsa>0)
      pst.str(string("Push"))
      pst.NewLine

