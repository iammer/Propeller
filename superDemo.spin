CON

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

OBJ

  'seven: "SingingDemoSeven"
  bouncy: "bouncy"

VAR

  long stack1[64]
  long sevenCog

PUB superDemo

  cognew(startBouncy, @stack1)

  'seven.start

PUB startBouncy
  bouncy.start


