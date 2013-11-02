CON
  _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
  _xinfreq        = 5_000_000

OBJ

  text: "TV_Text"
  ay: "AYCog"
  sd : "fsrw"

VAR

  byte buffer[16]

PUB start | i

  text.start(12)
  ay.start(10,11)
  sd.mount(0)

  sd.popen(string("cybernet.ym"), "r")  ' Open tune
  sd.pread(@buffer, 62)

  i:=0
  repeat
    waitcnt(cnt + (clkfreq/50))   ' Wait one VBL
    sd.pread(@buffer, 16)               ' Read 16 bytes from SD card
    ay.updateRegisters(@buffer)         ' Write 16 byte to AYcog
    'if i++&7==0
    '  text.str(string("I love Sarah"))
