CON

  _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

OBJ

  pst: "Parallax Serial Terminal"

PUB counterTest | rnd

  pst.start(115200)

  ctra[30..26]:=%00100
  ctra[5..0]:=8

  frqa:=536
  dira[8]~~


  rnd:=42

  repeat
    frqa:=(rnd? & $3ff) + 10
    pst.dec(frqa)
    pst.newline
    waitcnt(cnt+(rnd? & $00ff_ffff) + 10000)
