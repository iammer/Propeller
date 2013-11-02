'#define DEBUG
CON

  _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz


OBJ
  mcp: "MCP3208"

#ifdef DEBUG
  pst: "Parallax Serial Terminal"
#endif

PUB isaacThing | clocksPerNS, interval, lastCount, width, tick, range


#ifdef DEBUG
  pst.start(115200)
#endif

  mcp.start(13,12,14,1<<7)

  clocksPerNS:=clkfreq/1_000_000
  interval:=clocksPerNS * 20000

  dira[15]~~

  ctra[30..26]:=%00100
  ctra[5..0]:=15
  frqa:=1

  width:=750
  lastCount:=cnt

  repeat
    tick++
    lastCount+=interval

    range:=mcp.in(7)

#ifdef DEBUG
    pst.dec(range)
    pst.NewLine
#endif

    if range > 1000
      width:=2250
    else
      width:=600


    phsa:=-clocksPerNS*width
    waitcnt(lastCount)

