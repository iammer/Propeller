CON

  _clkmode        = xtal1 + pll16x
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

OBJ

  pst: "Parallax Serial Terminal"

PUB irTest | counter

  pst.start(115200)

  dira[16]~~
  dira[12]~

  ctra[30..26]:=%01001
  ctra[14..9]:=16
  ctra[5..0]:=12

  counter:=cnt
  pst.str(string("start"))
  pst.NewLine
  repeat
    waitpeq(0,1<<12,0)
    pst.str(string("off "))
    pst.dec((cnt-counter)/18000)
    pst.NewLine
    counter:=cnt
    waitpeq(1<<12,1<<12,0)
    pst.str(string("on "))
    pst.dec((cnt-counter)/18000)
    pst.NewLine
    counter:=cnt





