CON

  _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

  startFrequency=55_000

OBJ

'  pst : "Parallax Serial Terminal"
  rr: "RealRandom"
  buttons: "Quickstart Buttons"

PUB soundTest | f

'  pst.start(115200)
  buttons.start
  rr.start

  ctra[30..26]:=%00100
  ctra[5..0]:=13

  frqa:=startFrequency

  dira[13]~~

  waitcnt(clkfreq+cnt)

  repeat
    f:=(rr.random&$1ff)-$fe
'    pst.dec(frqa)
'    pst.NewLine
    frqa:=(frqa+f)
    if frqa<10000
      frqa+=(frqa>>2)
    if frqa>100000
      frqa-=(frqa>>5)

    if buttons.scanVal>0
      frqa:=buttons.scanVal<<10
      buttons.clear

    'waitcnt(clkfreq/100+cnt)



