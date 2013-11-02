CON

  _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

  deviceAddr      = %0101_0000

VAR

  byte buf[64]

OBJ

  i2c: "I2C Driver"

PUB eepromTest | i

  dira[23..16]~~

  repeat i from 0 to 63 step 1
    buf[i]:=%11010010

  i2c.start(8,9,400_000)


  'repeat i from 0 to $7fc0 step 64
  '  i2c.write_page(deviceAddr,i,@buf,64)

  i2c.read_page(deviceAddr,1234,@buf,64)

  outa[23..16]:=buf[42]

  repeat
    waitcnt(0)
