CON

  _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

  degScale = float(600_000)
  hundredFloat = float(100)

OBJ

  gps: "ultimateGPS"
  f32: "F32"
  fs:  "FloatString"
  pst: "Parallax Serial Terminal"

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

PUB gpsTest3 | i, t

  pst.start(115200)
  gps.start(8,9,0,@time)
  f32.start


  repeat
    waitcnt(cnt+clkfreq)
    pst.dec(time>>24)
    pst.char(":")
    pst.dec(time>>16 & $ff)
    pst.char(":")
    pst.dec(time & $ffff / 1000)
    pst.char(" ")

    pst.dec(date & $ffff)
    pst.char("-")
    pst.dec(date >> 16 & $ff)
    pst.char("-")
    pst.dec(date >> 24)
    pst.NewLine

    pst.char("(")
    pst.str(fs.floatToString(f32.FDiv(f32.FFloat(latitude),degScale)))
    pst.char(",")
    pst.str(fs.floatToString(f32.FDiv(f32.FFloat(longitude),degScale)))
    pst.char(",")
    pst.str(fs.floatToString(f32.FDiv(f32.FFloat(mslAltitude),hundredFloat)))
    pst.char(")")
    pst.NewLine
    pst.NewLine







