CON

  _clkmode        = xtal1 + pll16x
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

  flushAt         = 100
OBJ

  gps: "Parallax Serial Terminal"
  'pc: "Parallax Serial Terminal"
  sd: "SD-MMC_FATEngine"

PUB gpsTest | c, nextFlush

  'pc.start(115200)
  gps.startRxTx(8,9,0,9600)
  sd.FATEngineStart(11,10,13,12,-1,-1,0,0,0)

  dira[23..16]~~

  sd.mountPartition(0)
  sd.openFile(@fileName,"W")

  nextFlush:=flushAt

  repeat
    repeat while gps.RxCount>0
      c:=gps.CharIn
      sd.writeByte(c)
      'pc.Char(c)
      if (c=="$")
        outa[23]~~
      if (c==10)
        outa[23]~
        nextFlush--

    if (nextFlush<0)
      sd.flushData
      nextFlush:=flushAt
      !outa[22]

    'repeat while pc.RxCount>0
    '  gps.Char(pc.CharIn)
DAT
fileName      byte       "gps.log",0

