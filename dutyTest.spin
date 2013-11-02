#define DEBUG
CON

  _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz


  HIGHMASK = 1 << 31

OBJ
  qsb: "Quickstart Buttons"
#ifdef DEBUG
  pst: "Parallax Serial Terminal"
#endif

PUB dutyTest | scale, fa, fb

#ifdef DEBUG
  pst.start(115200)
  pst.str(string("dutyTest"))
  pst.NewLine
#endif

  dira[12]~~
  'outa[12]~~
  scale:=$11111111
  ctra[30..26]:=%00110
  'ctrb[30..26]:=%00110
  ctra[5..0]:=12
  'ctrb[5..0]:=16

  frqa:=0

  qsb.start

  'outa[13]~~
  repeat
    if qsb.testAndClear(1 << 7)
      '!outa[13]
      frqa+=scale
#ifdef DEBUG
      pst.str(string("up - "))
      pst.Hex(frqa,8)
      pst.NewLine
#endif

    if qsb.testAndClear(1 << 6)
      frqa-=scale
#ifdef DEBUG
      pst.str(string("down - "))
      pst.Hex(frqa,8)
      pst.NewLine
#endif


    waitcnt(clkfreq >> 4 + cnt)


