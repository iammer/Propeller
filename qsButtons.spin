VAR
  byte scanVal
  long scanStack[12]

PUB start
  dira[16..23]~~
  scanVal:=0

  cognew(scanCog(clkfreq/100),@scanStack)

pub scanCog(delay) | pads

  repeat
    outa[0..7]~~
    dira[0..7]~~
    dira[0..7]~
    waitcnt(delay+cnt)
    pads := $ff & !ina[7..0]
    if pads<>0
      scanVal:=pads
      waitcnt((delay * 20) +cnt)
