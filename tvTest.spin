CON
  _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
  _xinfreq        = 5_000_000

OBJ

  text: "TV_Text"

PUB tvTest

  text.start(12)
  repeat
    text.str(string("I love Sarah"))
    waitcnt(clkfreq/10 + cnt)
