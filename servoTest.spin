#define DEBUG
CON

  _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz


OBJ
  'qsb: "Quickstart Buttons"
  mcp: "MCP3208"

#ifdef DEBUG
  pst: "Parallax Serial Terminal"
#endif

VAR

  long width

PUB servoTest | clocksPerNS, interval, lastCount, in, tick

  clocksPerNS:=clkfreq/1000000
  interval:=clocksPerNS * 20000

  mcp.start(14,13,15,1)
  'qsb.start
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
  in:=0
  repeat
    tick++
    lastCount+=interval
    in+=mcp.in(0)

    if (tick & $7 == 0)
      in>>=3
      width:=(in>>1 <# 1500) + 750
#ifdef DEBUG
      pst.dec(in)
      pst.char($20)
      pst.dec(width)
      pst.NewLine
#endif
      in:=0

    phsa:=-clocksPerNS*width
    waitcnt(lastCount)



