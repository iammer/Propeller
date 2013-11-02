CON

  _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

OBJ

  rpi: "Parallax Serial Terminal"
  pc: "Parallax Serial Terminal"

PUB raspiTest | c

  pc.start(115200)
  rpi.startRxTx(12,13,%0100,115200)

  repeat
    repeat while rpi.RxCount>0
      pc.Char(rpi.CharIn)

    repeat while pc.RxCount>0
      rpi.Char(pc.CharIn)
