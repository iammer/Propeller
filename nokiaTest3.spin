'#define DEBUG
CON

  _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

OBJ

  nok: "MyNokia5510"
  'pst: "Parallax Serial Terminal"

VAR
  long lcdBuffer[128]

PUB start | loc, led, ledDir, i, s

  'pst.start(115200)
  nok.start(16,17,18,19,20,21,@lcdBuffer)

  {loc:=1
  led:=1
  ledDir:=1

  repeat
    ?loc
    nok.writeString(string("I love Sarah!"), ||(loc//126))
    nok.setLED(led)
    led+=ledDir
    if (led==0 or led==255)
      -ledDir
      lcdBuffer[126]:=(led & $80) + $30
    waitcnt(cnt+clkfreq>>5)}



  nok.setLED(200)
  nok.writeString(string("I love Sarah!"),0)
  s:=1
  repeat
    repeat s from 1 to 0
      repeat i from 21-s*21 to s*21 step 3
        nok.line(10+i,10+i,10+i,20+i,s)
        nok.line(10+i,20+i,20+i,20+i,s)
        nok.line(20+i,20+i,20+i,10+i,s)
        nok.line(20+i,10+i,10+i,10+i,s)
        waitcnt(cnt+clkfreq>>1)


  {repeat
    repeat i from 0 to $ffff step 8
      nok.writeHex(0,long[i],8)
      nok.writeHex(9,long[i+4],8)
      waitcnt(cnt+clkfreq>>6)
      nok.scrollTextDown}

  {loc:=0
  repeat
    longmove(@lcdBuffer,loc,126)
    loc+=504
    loc&=$ffff
    waitcnt(cnt+clkfreq>>2)

  }































