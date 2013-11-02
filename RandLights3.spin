CON

  _clkmode        = xtal1 '+ pll16x           ' Feedback and PLL multiplier
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

  HIGHMASK = 1 << 31

OBJ
  qsb: "Quickstart Buttons"

VAR
  byte scanVal
  long scanStack[12]

PUB blinken | rand, direction, out, bn, lastCnt, delay, startLevel, fa, fb

  qsb.start

  dira[16..23]~~
  direction:=TRUE
  rand:=3161982
  ?rand
  delay:=clkfreq >> 4
  lastCnt:=cnt
  startLevel:=1 << 30 -1

  ctra[30..26]:=%00110
  ctrb[30..26]:=%00110
  ctra[5..0]:=23
  ctrb[5..0]:=16

  fa:=startLevel
  fb:=startLevel
  frqa:=fa | HIGHMASK
  frqb:=fb | HIGHMASK

  repeat
    ?rand

    repeat bn from 0 to 31
      if direction
        out<<=1
        out+=rand>>bn & 1
      else
        out>>=1
        out&=$1f
        out+=(rand>>bn & 1) << 5
      if qsb.testAndClear(1 << 5)
        out:=0
      outa[22..17]:=out
      if qsb.testAndClear(1 << 2)
        not direction
      if qsb.testAndClear(1 << 3)
        delay<<=1
      if qsb.testAndClear(1 << 4)
        delay>>=1
      if qsb.testAndClear(1 << 7)
        fa<<=1
        fa+=1
        frqa:=fa | HIGHMASK
      if qsb.testAndClear(1 << 6)
        fa>>=1
        frqa:=fa | HIGHMASK
      if qsb.testAndClear(1 << 1)
        fb<<=1
        fb+=1
        frqb:=fb | HIGHMASK
      if qsb.testAndClear(1)
        fb>>=1
        frqb:=fb | HIGHMASK
      lastCnt+=delay
      waitcnt(lastCnt)


