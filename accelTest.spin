CON

  _clkmode        = xtal1 + pll16x
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

  adc_cs=8
  adc_din=9
  adc_dout=10
  adc_clk=11

  num_channels=8
  act_channels=3
  resolution=10
  adc_mode=1

  nok_led=12
  nok_rst=13
  nok_cs=14
  nok_dc=15
  nok_din=16
  nok_clk=17

  vin_num=33
  vin_denom=100

  gAScale=3
  gDScale=512

  dropMag=0.5

  calibrate=false
  default_min=384
  default_max=600
OBJ

  adc: "ADC_INPUT_DRIVER"
  nok: "MyNokia55102"
  f32: "F32"
  fs: "FloatString"
  qsb: "Quickstart Buttons"
  'pst: "Parallax Serial Terminal"

VAR
  long adcState[8]
  long adcMax[8]
  long adcMin[8]
  long adcVal[8]

  long gPlus[3]
  long gFMinus[3]

  long lcdBuffer[128]

PUB accelTest | i, v, vstr, m

  dira[23..18]~~

  adc.start_pointed(adc_din,adc_dout,adc_clk,adc_cs,num_channels,act_channels,resolution,adc_mode,false,@adcState,@adcVal,@adcMax,@adcMin)
  nok.start(nok_clk,nok_din,nok_dc,nok_cs,nok_rst,nok_led,@lcdBuffer)
  'pst.start(115200)
  if calibrate
    qsb.start

    nok.clear
    nok.writeString(string("Calibrating..."),0)
    longfill(@adcMax,NEGX,8)
    longfill(@adcMin,POSX,8)

    repeat while !qsb.testAndClear(1)

    f32.start

    nok.clear

    repeat i from 0 to 2
      nok.writeDec(i*21,adcMin[i])
      nok.writeDec(i*21+10,adcMax[i])
      gPlus[i]:=adcMax[i]+adcMin[i]
      gFMinus[i]:=f32.FFloat(adcMax[i]-adcMin[i])

    repeat while !qsb.testAndClear(1)

    qsb.stop
  else
    f32.start

    repeat i from 0 to 2
      gPlus[i]:=default_max+default_min
      gFMinus[i]:=f32.FFloat(default_max-default_min)

  repeat
    m:=f32.FFloat(0)
    repeat i from 0 to 2
      v:=f32.FDiv(f32.FFloat(adcVal[i]<<1-gPlus[i]),gFMinus[i])
      vstr:=fs.floatToString(v)
      m:=f32.FAdd(m,f32.FMul(v,v))
      nok.clearLine(i)
      nok.writeString(vstr,i*21)
      'pst.str(fs.floatToString(f32.FMul(f32.FFloat(adcVal[i]-gDScale),scale)))
      'pst.NewLine

    nok.writeString(fs.floatToString(m),84)
    if f32.FCmp(m,dropMag)=<0
      outa[23]~~
    else
      outa[23]~

    waitcnt(cnt+clkfreq>>3)

