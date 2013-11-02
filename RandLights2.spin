CON

  _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

VAR
  byte scanVal
  long scanStack[12]

PUB blinken | rand, direction, out, bn, lastCnt, delay

  dira[16..23]~~
  scanVal:=0
  direction:=1

  cognew(scanCog(clkfreq/100),@scanStack)

  delay := clkfreq >> 2

  repeat
    waitcnt(clkfreq/32 + cnt)
    if scanVal & 1 == 1
      rand := cnt
      quit

  lastCnt:=cnt
  repeat
    ?rand

    repeat bn from 0 to 31
      if direction==1
        out<<=1
        out+=rand>>bn & 1
      else
        out>>=1
        out&=$7f
        out+=(rand>>bn & 1) << 7
      if scanVal & $80 == $80
        !direction
        scanVal:=0
      if scanVal & $10 == $10
        out:=0
        scanVal:=0
      if scanVal & $40 == $40
        delay<<=1
        scanVal:=0
      if scanVal & $20 == $20
        delay>>=1
        scanVal:=0
      outa[23..16]:=out
      lastCnt+=delay
      waitcnt(lastCnt)


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

