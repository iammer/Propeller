CON

  _clkmode        = xtal1 + pll16x
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

OBJ

  ts: "DS1620"
  pst: "Parallax Serial Terminal"

PUB tempTest | t

ts.start(13,14,15,FALSE)
pst.start(115200)

repeat
  t:=ts.gettempf
  pst.dec(t/10)
  pst.str(string("."))
  pst.dec(t//10)
  pst.NewLine
  waitcnt(clkfreq + cnt)


