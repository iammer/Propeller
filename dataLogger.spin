CON

  _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

OBJ

  sd: "SD-MMC_FATEngine"
  qsb: "Quickstart Buttons"
  mcp: "MCP3208"
  clk: "Clock"

PUB dataLogger | counter

  clk.Init(5_000_000)


  dira[23..17]~~
  qsb.start

  repeat
    if qsb.testAndClear(1 << 7)
      quit
    waitcnt(clkfreq + cnt)

  'outa[23]~~
  sd.FATEngineStart(8,9,10,11,12,13,0,0,0)
  sd.mountPartition(0)
  'sd.newFile(string("data.log"))
  sd.openFile(string("data.log"),"W")

  mcp.start(15,14,16,%11)

  outa[18]~~
  outa[17]~~
  waitcnt(clkfreq >> 4 + cnt)


  repeat
    if qsb.testAndClear(1)
      quit
    sd.writeLong(cnt)
    sd.writeShort(mcp.in(0))
    sd.writeShort(mcp.in(1))
    sd.writeLong(0)
    outa[17]~
    clk.setClock(rcslow)
    waitcnt(clkfreq << 2 + cnt)
    outa[17]~~
    waitcnt(clkfreq >> 4 + cnt)
    clk.setClock(xtal1 + pll16x)


  sd.closeFile
  sd.FATEngineStop
  mcp.stop
  qsb.stop

  'outa[22]~~
  waitcnt(clkfreq << 2 + cnt)




