CON

  _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

  onPin=13
  offPin=12
  outputPin=14
OBJ

  'pst: "Parallax Serial Terminal"


PUB start | isPressed

  dira[outputPin]~~
  outa[outputPin]~
  dira[16..23]~~

  ctra[30..26]:=%11010
  ctra[5..0]:=onPin
  frqa:=1

  ctrb[30..26]:=%11010
  ctrb[5..0]:=offPin
  frqb:=1

  outa[onPin]~~
  outa[offPin]~~

  repeat
    dira[onPin]~~
    dira[offPin]~~
    dira[onPin]~
    dira[offPin]~
    phsa:=0
    phsb:=0
    waitcnt(cnt+clkfreq>>4)
    outa[19..16]:=(phsa>>9) & $f
    outa[23..20]:=(phsb>>9) & $f
    if (phsa>3_500)
      outa[outputPin]~~
    else
      if (phsb>3_500)
        outa[outputPin]~


