CON

  _clkmode        = xtal1 + pll4x           ' Feedback and PLL multiplier
  _xinfreq        = 5_000_000

OBJ

  qsb: "Quickstart Buttons"
  pst: "Parallax Serial Terminal"

VAR

  WORD resultCount[8]

PUB quickButtonTest | light, i

  qsb.start

  pst.start(115200)
  pst.str(string("quickButtonTest"))
  pst.NewLine

  dira[23..16]~~

  light:=-1

  repeat
    if ina[13]==0
      resultCount[light]++
    else
      light+=1
      light//=8
      outa[23..16]:=1<<light

    if qsb.testAndClear(1)
      repeat i from 0 to 7
        pst.dec(resultCount[i])
        pst.NewLine
    waitcnt(cnt+clkfreq/300)

