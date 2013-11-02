CON

  _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

  deviceAddr      = %01000100

OBJ

  i2c: "i2cObject"

PUB i2cTest | i

  dira[23..16]~~

  i2c.Start
  i2c.init(13, 12, false)

  i2c.writeLocation(deviceAddr,$0c,%11111111,8,8)
  i2c.writeLocation(deviceAddr,$02,%11111111,8,8)
  i2c.writeLocation(deviceAddr,$01,%00000000,8,8)

  i:=0
  repeat
    outa[16..23]:=i2c.readLocation(deviceAddr,$12,8,8)
    i++
    i2c.writeLocation(deviceAddr,$13,i & $ff, 8,8)



  i2c.Stop

