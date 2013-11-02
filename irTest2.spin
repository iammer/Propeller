CON

  _clkmode        = xtal1 + pll16x
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

OBJ

  ir: "ir_reader_rc5"
  pst: "Parallax Serial Terminal"

PUB irTest2 | code, scale

  scale:=$4444444

  dira[16]~~
  dira[17]~~
  dira[18]~~

  ctra[30..26]:=%00110
  ctra[5..0]:=16
  frqa:=0


  ir.init(12,0,6,0)
  pst.start(115200)

  repeat
    code:=ir.fifo_get
    if (code=>0)
      pst.hex(code,8)
      pst.NewLine
      if (code==16)
        frqa+=scale
      if (code==17)
        frqa-=scale

