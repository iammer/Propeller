CON

  _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

OBJ
  pst: "Parallax Serial Terminal"
  mcp: "MCP3208"

PUB mcpTest | l, maxSample, minSample, i, s

  pst.start(115200)
  mcp.start1(14,13,15,$f,12)

'  maxSample:=0
'  minSample:=4096

  repeat
'    l:=mcp.in(0)
'    if maxSample < l
'      maxSample:=l
'    l:=100-(l*100/maxSample)
'    pst.dec(l)
'    pst.NewLine
    l:=0
    repeat i from 0 to 3
      s:=mcp.in(i)
      l+=s
      pst.dec(s)
      pst.str(string(" "))
    pst.dec(l<<18)
    mcp.out(l<<18,0)
    pst.NewLine
    waitcnt(clkfreq>>2+cnt)



