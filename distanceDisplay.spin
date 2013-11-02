CON

  _clkmode        = xtal1 '+ pll16x           ' Feedback and PLL multiplier
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

OBJ
  'pst: "Parallax Serial Terminal"
  mcp: "MCP3208"
  led: "serialLED"

PUB distanceDisplay | dist, v

  dira[23]~~
  'pst.start(115200)
  mcp.start(12,11,13,2)
  led.start(8,9,10)

  repeat
    !outa[23]
    v:=4096/mcp.in(1)
    'dist:=(7349+672613*v)/(88852+v*(v-243))

    'pst.dec(v)
    'pst.NewLine
    led.convertAndDisplay(v<#9)
    !outa[23]
    waitcnt(clkfreq >> 2 + cnt)

