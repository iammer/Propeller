#define DEBUG
CON

  _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz


OBJ
#ifdef DEBUG
  pst: "Parallax Serial Terminal"
#endif

VAR

  long width

PUB servoTest | clocksPerNS, interval, lastCount, dir, tick

  clocksPerNS:=clkfreq/1000000
  interval:=clocksPerNS * 20000
  dir:=-50

#ifdef DEBUG
  pst.start(115200)
  pst.str(string("servoTest"))
  pst.NewLine
#endif


  dira[8]~~

  ctra[30..26]:=%00100
  ctra[5..0]:=8
  frqa:=1

  width:=1500

  lastCount:=cnt
  tick:=0
  repeat
    tick++
    lastCount+=interval
    width+=dir
    if width=<700
      dir:=20
    if width=>2000
      dir:=-20

#ifdef DEBUG
    pst.dec(width)
    pst.char($20)
    if (tick & $7 == 0)
      pst.NewLine
#endif

    phsa:=-clocksPerNS*width
    waitcnt(lastCount)



