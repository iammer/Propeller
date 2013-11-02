CON

  _clkmode        = xtal1 + pll2x
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

OBJ

   pst : "Parallax Serial Terminal"

PUB serialTest

  pst.start(115200)

  repeat

    pst.Dec(((1999-2000) * 5) >> 1)
    pst.NewLine
    waitcnt(clkfreq + cnt)
