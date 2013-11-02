CON

  _clkmode        = rcslow           ' Feedback and PLL multiplier
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

OBJ

  qsb: "Quickstart Buttons2"

PUB qsb2Test

  dira[23..16]~~
  qsb.start

  repeat
    outa[23..16]:=qsb.getState & $ff
