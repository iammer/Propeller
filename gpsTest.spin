CON

  _clkmode        = xtal1 + pll16x
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz
OBJ

  gps: "Parallax Serial Terminal"
  pc: "Parallax Serial Terminal"

PUB gpsTest | c

  pc.start(115200)
  gps.startRxTx(9,8,0,9600)

  repeat
    repeat while gps.RxCount>0
      pc.Char(gps.CharIn)

    repeat while pc.RxCount>0
      gps.Char(pc.CharIn)
