CON

  _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

OBJ

  sd: "SD-MMC_FATEngine"

PUB fatTest | counter

  ctra[30..26]:=%00100
  ctra[5..0]:=16

  frqa:=640

  dira[23..16]~~

  outa[23]~~
  sd.FATEngineStart(24,25,26,27,-1,-1,0,0,0)
  outa[22]~~
  sd.mountPartition(0)
  outa[21]~~
  'sd.newFile(string("test.txt"))
  sd.openFile(string("test.txt"),"A")
  outa[20]~~
  repeat 100
    !outa[19]
    counter:=cnt
    sd.writeLong(counter)
  sd.closeFile
  outa[18]~~
  sd.FATEngineStop
  outa[17]~~
  waitcnt(clkfreq << 2 + cnt)

