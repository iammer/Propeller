CON

  _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

OBJ
  qsb: "Quickstart Buttons"
  pst: "Parallax Serial Terminal"

PUB simpleServoTest | width, interval, lastCount, clocksPerNS, p

  clocksPerNS:=(clkfreq/1000000)
  interval:= clocksPerNS * 20000

  qsb.start

  pst.start(115200)
  pst.str(string("simpleServoTest"))
  pst.NewLine

  dira[12]~~
  dira[23..16]~~

  ctra[30..26]:=%00100
  ctra[5..0]:=12
  frqa:=1

  width:=1500

  lastCount:=cnt
  repeat
    lastCount+=interval

    p:=qsb.getPressed

    if p>0
      outa[23..16]:=1 << (p-1)
      pst.dec(p)
      pst.NewLine
      width:=p*250+450
      pst.dec(width)
      pst.NewLine

    phsa:=-clocksPerNS*width
    waitcnt(lastCount)
