CON

  _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

PUB mosTest

dira[23..16]~~
dira[12]~~
ctra[30..26]:=%11000
ctra[14..9]:=8
ctra[5..0]:=10

frqa:=1
phsa:=0

'repeat
'  !outa[13]
'  !outa[16]
'  waitcnt(clkfreq*8+cnt)
  repeat
    !outa[12]
    waitcnt(clkfreq/30+cnt)
    outa[23..16]:=phsa & $ff


