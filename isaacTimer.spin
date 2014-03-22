CON

  _clkmode        = xtal1
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz


  scale=4_473_924 ' 2^32 / (60<<4)

PUB isaacTimer | i

  dira[16..23]~~

  repeat i from 16 to 22 step 2
    outa[i]~
    outa[i+1]~~

  repeat i from 16 to 20 step 2
    outa[i]~
    outa[i+1]~
    fadeMin(i,i+1)
    outa[i]~~
    outa[i+1]~

  outa[22]~~
  outa[23]~

  repeat
    waitcnt(0)

PRI fadeMin(pinStart,pinEnd) | i

  ctra[30..26]:=%00111
  ctra[5..0]:=pinStart
  ctra[14..9]:=pinEnd

  repeat i from 0 to 60<<4
    frqa:=i*scale
    waitcnt(cnt+clkfreq>>4)
