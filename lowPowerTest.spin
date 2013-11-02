CON

  _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

OBJ

  clk: "Clock"

PUB lowPowerTest | i

  dira[12]~~
  dira[23..16]~~
  outa[12]~~

  clk.Init(5_000_000)

  repeat
      outa[12]~~
        waitcnt(clkfreq << 3 + cnt)
      outa[12]~
        waitcnt(clkfreq << 3 + cnt)

      i:=0
      outa[23]~~
            waitcnt(clkfreq << 3 +cnt)
      outa[23]~
      repeat while i < 500_000
        i++

      clk.setClock(xtal1)

      outa[22]~~
            waitcnt(clkfreq<<3 +cnt)
      outa[22]~
      i:=0
      repeat while i < 32_000
        i++

      clk.setClock(rcslow)

      outa[21]~~
        waitcnt(clkfreq << 3 +cnt)
      outa[21]~
      i:=0
      repeat while i < 100
        i++

      clk.setClock(xtal1 + pll16x)



