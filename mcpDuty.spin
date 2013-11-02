CON

  _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

OBJ
  pst: "Parallax Serial Terminal"
  mcp: "MCP3208"

PUB mcpTest | l

  pst.start(115200)
  mcp.start(13,14,15,$80)

  ctra[30..26]:=%00110
  ctra[5..0]:=12
  dira[12]~~

  frqa:=0

  repeat
    l:=mcp.in(7)
    frqa:=l<<21
    pst.dec(l)
    pst.NewLine
    waitcnt(clkfreq>>2+cnt)



