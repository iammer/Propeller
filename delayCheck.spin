CON

  _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

PUB DelayCheck | lastCnt, a, delay

  a := 37

  dira[16..23]~~

  outa[23..16]:=10

  waitcnt(clkfreq + cnt)

  repeat
    lastCnt:=cnt
    repeat 10
      a*=12
    delay:=(cnt-lastCnt)
    outa[23..16]:=delay
    waitcnt(clkfreq * 3 + cnt)
    outa[23..16]:=delay >> 8
    waitcnt(clkfreq * 3 + cnt)
    outa[23..16]:=delay >> 16
    waitcnt(clkfreq * 3 + cnt)

