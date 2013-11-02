VAR
  long scanStack[12]
  byte iscanVal

PUB start
  dira[16..23]~~
  iscanVal:=0

  cognew(scanCog(clkfreq/100),@scanStack)

PUB scanVal : val
  val:=iscanVal

PUB clear
  iscanVal:=0

pub scanCog(delay) | pads

  repeat
    outa[0..7]~~
    dira[0..7]~~
    dira[0..7]~
    waitcnt(delay+cnt)
    pads := $ff & !ina[7..0]
    if pads<>0
      iscanVal:=pads
      waitcnt((delay * 20) +cnt)

