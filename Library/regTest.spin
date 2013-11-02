CON

  _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz


  vStep=1
  syncSpeed=$ff
  reportFreq=1000
OBJ
  qsb: "Quickstart Buttons"
  mcp: "MCP3208"
  pst: "Parallax Serial Terminal"

PUB regTest | vTarget, vActual, c

  vTarget:=0

  pst.start(115200)

  qsb.start
  mcp.start(15,13,14,1)


  pst.NewLine
  pst.str(string("regTest"))
  pst.NewLine

  dira[12]~~
  ctra[30..26]:=%00110
  ctra[5..0]:=12

  frqa:=0
  c:=0

  repeat
    c++

    vActual:=mcp.in(0)
    frqa:=vTarget*$11111111

    if c//reportFreq==0
      if qsb.testAndClear(1<<7)
        vTarget+=vStep
      if qsb.testAndClear(1<<6)
        vTarget-=vStep

      pst.dec(vActual)
      pst.char($20)
      pst.dec(vTarget)
      pst.char($20)
      pst.hex(frqa,8)
      pst.NewLine
    else
      waitcnt(clkfreq/50000+cnt)
