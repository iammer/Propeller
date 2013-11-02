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
  p:=0

  lastCount:=cnt
  repeat
    lastCount+=interval

    if qsb.testAndClear($1)
      width-=10

    if qsb.testAndClear($2)
      width+=10

    if qsb.testAndClear($4)
      width:=1500

    if qsb.testAndClear($8)
      width:=1000

    if qsb.testAndClear($10)
      width:=2000

    if p<>width
      pst.dec(width)
      pst.NewLine
      p:=width

    phsa:=-clocksPerNS*width
    waitcnt(lastCount)
