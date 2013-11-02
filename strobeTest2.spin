CON

  _clkmode        = xtal1 + pll16x
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

OBJ

  qsb: "Quickstart Buttons"

PUB strobeTest2 | pulseLength, hz, waitTime, nextTime

  dira[12..13]~~
  qsb.start

  ctra[30..26]:=%00100
  ctrb[30..26]:=%00100
  ctra[5..0]:=12
  ctrb[5..0]:=13
  frqa:=1
  frqb:=1

  pulseLength:=clkfreq>>10
  hz:=1
  waitTime:=clkfreq
  nextTime:=waitTime+cnt

  repeat
    phsa:=-pulseLength
    phsb:=-pulseLength

    if qsb.testAndClear(1<<7)
      hz+=1
      waitTime:=clkfreq/hz
    if qsb.testAndClear(1<<6)
      hz-=1
      waitTime:=clkfreq/hz
    if qsb.testAndClear(1<<5)
      waitTime-=800_000
    if qsb.testAndClear(1<<4)
      waitTime+=800_000
    if qsb.testAndClear(1<<3)
      waitTime-=80_000
    if qsb.testAndClear(1<<2)
      waitTime+=80_000
    if qsb.testAndClear(1<<1)
      pulseLength<<=1
    if qsb.testAndClear(1<<0)
      pulseLength>>=1

    waitcnt(nextTime)
    nextTime:=waitTime+nextTime

