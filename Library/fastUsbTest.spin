CON

  _clkmode        = xtal1 + pll16x
  _xinfreq        = 5_000_000

OBJ

  fds: "FullDuplexSerial"

PUB fastUsbTest

  dira[23..16]~~
  waitcnt(cnt+clkfreq<<2)
  outa[16]~~

  fds.start(31,30,0,460800)

  repeat
    fds.tx(48)
    fds.tx(49)


