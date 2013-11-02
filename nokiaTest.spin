'#define DEBUG
CON

  _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

VAR
  byte clock
  byte din
  byte dc
  byte cs
  byte rst
  byte led

PUB start | v
  clock:=12
  din:=13
  dc:=14
  cs:=15
  rst:=16
  led:=18

  outa[cs]~~
  outa[rst]~
  outa[led]~

  dira[rst]~~
  dira[clock]~~
  dira[din]~~
  dira[dc]~~
  dira[cs]~~
  dira[led]~~

  waitcnt(cnt+clkfreq >> 10)
  outa[rst]~~

  outa[led]~~

  send(%00100001,0)
  send(%11001000,0)
  send(%00000110,0)
  send(%00010011,0)
  send(%00100000,0)
  send(%00001100,0)

  v:=0
  repeat 504
    send(v,1)

  repeat
    !v
    repeat 504
      send(v,1)
      waitcnt(cnt+clkfreq>>6)

PUB send(dataByte,isData) | waitTime

    dataByte&=$ff
    dataByte<-=25

    outa[clock]~
    outa[dc]:=isData
    outa[cs]~

    {pst.dec(isData)
    pst.NewLine
    pst.NewLine}
    repeat 8
      {pst.dec(dataByte & 1)
      pst.NewLine
      dataByte<-=1}
      outa[din]:=(dataByte & 1)
      outa[clock]~~
      dataByte<-=1
      outa[clock]~


    outa[cs]~~






