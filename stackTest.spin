CON

  _clkmode        = xtal1 '+ pll16x           ' Feedback and PLL multiplier
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

VAR
  long stack[7*7]

OBJ

  stackLength: "Stack Length"

PUB startCogs | cog
  repeat
    repeat cog from 0 to 6
      cognew(cogTest(cog+17),@stack[cog*7])

    cogTest(16)

    waitcnt(clkfreq/10 + cnt)

PUB cogTest(pin)
  dira[pin]~~
  repeat 100
    !outa[pin]
    waitcnt(clkfreq/pin + cnt)


