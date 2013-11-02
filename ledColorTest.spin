CON

  _clkmode        = xtal1 + pll16x
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

  scale           = $04040404

VAR

  long stack[32]

PUB ledColorTest | colorStep

  dira[8]~~
  dira[9]~~

  'outa[8..9]~~


  cognew(greenCog,@stack)

  ctra[30..26]:=%00110
  ctrb[30..26]:=%00110

  ctra[5..0]:=8
  ctrb[5..0]:=9

  colorStep:=0

  repeat
    frqa:=||($40 - colorStep & $7f) * scale
    frqb:=||($40 - colorStep >> 7 & $7f) * scale
    colorStep++
    waitcnt(cnt+clkfreq>>10)

PUB greenCog

  dira[10]~~

  ctra[30..26]:=%00110
  ctra[5..0]:=10

  frqa:=$8888_8888

  repeat
    waitcnt(0)

