CON

  _clkmode        = xtal1 + pll16x
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

  moveEnable=8
  steerEnable=13
  forward=10
  backward=9
  left=12
  right=11

  adc_clk=14
  adc_dout=15
  adc_din=16
  adc_cs=17

  num_channels=8
  act_channels=8
  resolution=12
  adc_mode=1

OBJ

  car: "rcCar"
  adc: "ADC_INPUT_DRIVER"
  pst: "Parallax Serial Terminal"

VAR

  long adcState[8]
  long adcMax[8]
  long adcMin[8]
  long adcVal[8]

CON

  carSpeed=3
  steerSpeed=8

PUB rcCarTest | fStart

  dira[18..23]~~

  adc.start_pointed(adc_din,adc_dout,adc_clk,adc_cs,num_channels,act_channels,resolution,adc_mode,false,@adcState,@adcVal,@adcMax,@adcMin)
  car.start(moveEnable,forward,backward,steerEnable,left,right,true)
  pst.start(115200)

  car.setSpeed(carSpeed)
  car.setSteerSpeed(steerSpeed)

  repeat
    outa[18]~~
    outa[20]~
    car.stop

    waitcnt(cnt+clkfreq)
    outa[19]~~
    car.center
    car.forward

    fstart:=cnt

    repeat while adcVal[4]<1000
      pst.dec(adcVal[4])
      pst.NewLine
      if cnt-fStart>clkfreq>>1
        outa[18]~
        car.setSpeed(1)

    car.stop
    outa[19]~

    waitcnt(cnt+clkfreq<<1)

    outa[20]~~
    car.left
    waitcnt(cnt+clkfreq>>2)

    car.setSpeed(carSpeed)
    car.backward

    waitcnt(cnt+clkfreq)


