CON

  _clkmode        = xtal1 + pll16x
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

VAR

  long rand
  long direction

PUB RandLights | bn, out

  dira[16..23]~~

  repeat
    outa[0]~~
    dira[0]~~
    dira[0]~
    waitcnt(clkfreq/100 + cnt)
    if not ina[0]
      rand:=cnt
      quit

  out:=0

  repeat
    ?rand

    repeat bn from 0 to 31
      out<<=1
      out+=rand>>bn & 1
      outa[23..16]:=out
      waitcnt(clkfreq/20 + cnt)


