CON

  _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

  degScale = float(600_000)
  hundredFloat = float(100)

  flushEvery=10

OBJ

  nok: "MyNokia5510NC"
  gps: "ultimateGPS"
  f32: "F32"
  fs:  "FloatString"
  sd: "SD-MMC_FATEngine"
  adc: "ADC_INPUT_DRIVER"


VAR

  long time
  long date
  long latitude
  long longitude
  long mslAltitude
  long geoidalSep
  long mode
  long satInfo[16]
  long HDOP
  long PVDOP
  long speed
  long course

  long flushCountdown

  long chanstate[8]
  long chanval[8]
  long chanmax[8]
  long chanmin[8]

PUB gpsNok | c, i

  gps.start(15,14,0,@time)
  nok.start(8,9,10,11,12,13)
  f32.start
  sd.FATEngineStart(24,25,26,27,-1,-1,0,0,0)
  adc.start_pointed(6,7,5,4,8,8,12,1,false,@chanstate,@chanval,@chanmax,@chanmin)

  sd.mountPartition(0)
  sd.openFile(@fileName,"W")
  flushCountdown:=flushEvery

  nok.clear
  nok.setLED(256)

  c:=cnt

  dira[16]~~

  repeat
    c+=clkfreq
    waitcnt(c)
    nok.writeDecPad(0,time>>24,2)
    nok.writeChar(2,":")
    nok.writeDecPad(3,time>>16 & $ff,2)
    nok.writeChar(5,":")
    nok.writeDecPad(6,time & $ffff / 1000,2)
    nok.writeChar(8," ")

    nok.writeDecPad(10,date & $ffff,4)
    nok.writeChar(14,"-")
    nok.writeDecPad(15,date >> 16 & $ff,2)
    nok.writeChar(17,"-")
    nok.writeDecPad(18,date >> 24,2)

    nok.clearLine(1)
    nok.writeString(21,fs.floatToString(f32.FDiv(f32.FFloat(latitude),degScale)))
    nok.writeString(31,fs.floatToString(f32.FDiv(f32.FFloat(longitude),degScale)))

    nok.clearLine(2)
    nok.writeDec(42, getmGs(5))
    nok.writeDec(49, getmGs(6))
    nok.writeDec(56, getmGs(7))
    nok.writeDec(63, chanVal[0]/248)

    sd.writeLong(date)
    sd.writeLong(time)
    sd.writeLong(latitude)
    sd.writeLong(longitude)
    sd.writeLong(mslAltitude)
    sd.writeLong(HDOP)
    sd.writeLong(PVDOP)
    repeat i from 0 to 7
      sd.writeLong(chanval[i])
    sd.writeLong($ffffffff)
    if flushCountdown-- == 0
      sd.flushData
      flushCountdown:=flushEvery
      outa[16]~~
    else
      outa[16]~

PRI getmGs(chan)
  result:=(chanval[chan] * 5) >> 1 - 5000

DAT
fileName      byte       "gps.log",0
