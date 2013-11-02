'#define DEBUG
CON

  _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

OBJ

  nok: "MyNokia5510NC"

PUB main

  nok.start(8,9,10,11,12,13)

  nok.clear
  nok.writeString(0,string("I love Sarah!"))

  repeat
    waitcnt(0)
