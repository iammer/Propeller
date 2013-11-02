CON

  _clkmode        = xtal1 + pll16x
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

  cs=8
  din=9
  dout=10
  clk=11

  num_channels=8
  act_channels=1
  resolution=10
  adc_mode=1

  ftdi_rx=31
  ftdi_tx=30
  serial_mode=0
  baud=460800

OBJ

  adc: "ADC_INPUT_DRIVER"
  fds: "FullDuplexSerial"

VAR
  long adcState[8]
  long adcMax[8]
  long adcMin[8]
  long adcVal[8]

PUB start

  dira[12]~~
  ctra[30..26]:=%00100
  ctra[5..0]:=12
  frqa:=53687

  fds.start(ftdi_rx,ftdi_tx,serial_mode,baud)
  adc.start_pointed(din,dout,clk,cs,num_channels,act_channels,resolution,adc_mode,false,@adcState,@adcVal,@adcMax,@adcMin)


  repeat
    fds.tx(adcVal[0]>>2 & $ff)

