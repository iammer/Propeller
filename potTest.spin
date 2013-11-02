CON

  _clkmode        = xtal1 + pll16x
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

OBJ

  ad: "AD5220"

PUB potTest | r

  ad.start(12,14,13)
  dira[16..23]~~

  repeat
    repeat r from 0 to 7
      outa[16..24]:=1<<r
      ad.resist(r << 3)
      waitcnt(clkfreq<<2+cnt)

    repeat r from 8 to 1
      outa[16..24]:=1<<r
      ad.resist(r << 3)
      waitcnt(clkfreq<<2+cnt)

