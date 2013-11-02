CON

  _clkmode        = xtal1 + pll16x
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

VAR
  byte moveEnablePin
  byte forwardPin
  byte backwardPin
  byte steerEnablePin
  byte leftPin
  byte rightPin

  long moveDuty
  long steerDuty

  long stack[32]

PUB start(moveEnable,forwardx,backwardx,steerEnable,leftx,rightx,dutyMode)

  moveEnablePin:=moveEnable
  forwardPin:=forwardx
  backwardPin:=backwardx
  steerEnablePin:=steerEnable
  leftPin:=leftx
  rightPin:=rightx

  dira[forwardPin]~~
  dira[backwardPin]~~
  dira[leftPin]~~
  dira[rightPin]~~

  if dutyMode
    moveDuty:=0
    steerDuty:=0

    cognew(handleDuty,@stack)

  else
    dira[moveEnablePin]~~
    dira[steerEnablePin]~~

    outa[moveEnablePin]~~
    outa[steerEnablePin]~~


PUB handleDuty

  dira[moveEnablePin]~~
  dira[steerEnablePin]~~

  ctra[30..26]:=%00110
  ctra[5..0]:=moveEnablePin
  ctrb[30..26]:=%00110
  ctrb[5..0]:=steerEnablePin


  repeat
    frqa:=moveDuty
    frqb:=steerDuty
    waitcnt(cnt+clkfreq>>3)

PUB stop

  outa[forwardPin]~
  outa[backwardPin]~

PUB setSpeed(speed)
  moveDuty:=(speed<<27)-1 + (3<<30)

PUB forward
  outa[backwardPin]~
  outa[forwardPin]~~

PUB backward
  outa[forwardPin]~
  outa[backwardPin]~~

PUB setSteerSpeed(speed)
  steerDuty:=(speed<<27)-1 + (3<<30)

PUB center
  outa[leftPin]~
  outa[rightPin]~

PUB left
  outa[rightPin]~
  outa[leftPin]~~

PUB right
  outa[leftPin]~
  outa[rightPin]~~


