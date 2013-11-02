CON

  _clkmode        = xtal1
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

  nf=100
  r=10_000

  rc1=nf*693
  rc2=16*1000
  rc3=1000000000

VAR

  long rcTime

OBJ
  rc: "RCTIME"
  pst : "Parallax Serial Terminal"

PUB rcTest
  pst.start(300)
  rc.start(13,1,@rcTime)

  repeat
    pst.dec((rcTime*rc2/rc1*(rc3/clkfreq))-r)
    pst.NewLine
    waitcnt(clkfreq + cnt)
