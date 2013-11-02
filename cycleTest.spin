CON

  _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

OBJ

  pst: "Parallax Serial Terminal"

VAR
  byte aVar

PUB speedTest | a, b

  aVar:=12

  pst.start(115200)

  pst.str(string("Start"))
  pst.NewLine

  a:=cnt
  b:=cnt

  pst.dec(b-a)
  pst.NewLine

  dira[12]~~
  a:=cnt
  outa[12]~~
  b:=cnt

  pst.dec(b-a)
  pst.NewLine

  a:=cnt
  outa[aVar]~~
  b:=cnt

  pst.dec(b-a)
  pst.NewLine

  a:=cnt
  outa[aVar]~~
  outa[aVar]~
  b:=cnt

  pst.dec(b-a)
  pst.NewLine

  a:=cnt
  repeat 2
    !outa[aVar]
  b:=cnt

  pst.dec(b-a)
  pst.NewLine

  pst.str(string("Done"))
  pst.NewLine

