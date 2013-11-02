CON

  _clkmode        = xtal1 + pll16x
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

  ticksMax        = 3000
  scale           = $ffffffff>>1/ticksMax>>1

OBJ

  ping: "Ping"
  pst: "Parallax Serial Terminal"

PUB ledColorTest | avg

  pst.start(115200)

  dira[8]~~
  dira[9]~~

  ctra[30..26]:=%00111

  ctra[5..0]:=8
  ctra[14..9]:=9

  avg:=0

  repeat
    avg*=7
    avg+=ping.Ticks(10)<#ticksMax
    avg>>=3
    pst.Dec(avg)
    pst.NewLine
    frqa:=avg*scale
    waitcnt(cnt+clkfreq>>4)
