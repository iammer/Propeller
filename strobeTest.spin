CON

  _clkmode        = xtal1 + pll16x
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

OBJ
  qsb: "Quickstart Buttons"


PUB strobeTest

   dira[16..23]~~
   dira[12..13]~~

   'outa[12..13]~~

   ctra[30..26]:=%00100
   ctrb[30..26]:=%00100
   ctra[5..0]:=12
   ctrb[5..0]:=13

   frqa:=1610
   frqb:=1610

   repeat
    qsb.singleScan(clkfreq>>6)

    if qsb.testAndClear(1<<7)
      frqa+=53
      frqb+=53
    if qsb.testAndClear(1<<6)
      frqa-=53
      frqb-=53
    if qsb.testAndClear(1<<5)
      frqa+=530
      frqb+=530
    if qsb.testAndClear(1<<4)
      frqa-=530
      frqb-=530
    if qsb.testAndClear(1<<2)
      !dira[23..16]
    if qsb.testAndClear(1<<1)
      frqa++
      frqb++
    if qsb.testAndClear(1<<0)
      frqa--
      frqb--


    outa[23..16]:=frqa/53

