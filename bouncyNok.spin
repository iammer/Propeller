CON
  _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
  _xinfreq        = 5_000_000
OBJ

  nok: "MyNokia5510"
  'pst: "Parallax Serial Terminal"

VAR
  long lcdBuffer[128]

  word points[24]
  word speeds[8]

CON

  xMin=0
  xMax=83
  yMin=0
  yMax=39

PUB start | loc, led, ledDir, i, s, random, j

  'pst.start(115200)
  nok.start(16,17,18,19,20,21,@lcdBuffer)

  random:=cnt
  repeat i from 0 to 7 step 2
    random?
    points[i]:=(random & 31)
    points[i+1]:=(random>> 6 & 31)
    speeds[i]:=(random >> 16) & 7 + 1
    speeds[i+1]:=(random >> 21) & 7 + 1

  repeat
    nok.clear

    nok.line(points[6],points[7],points[0],points[1],1)
    repeat i from 0 to 7 step 2
      j:=i+1
      nok.line(points[i],points[j],points[(i+2) & 7],points[(j+2) & 7],1)
      points[i]+=speeds[i]
      if (points[i]<xMin or points[i]>xMax)
        -speeds[i]
        points[i]+=speeds[i]

      points[j]+=speeds[j]
      if (points[j]<yMin or points[j]>yMax)
       -speeds[j]
       points[j]+=speeds[j]

    repeat j from 1 to 2
      nok.line(points[j*8+6],points[j*8+7],points[j*8],points[j*8+1],1)
      repeat i from 0 to 7 step 2
        nok.line(points[j*8 + ((i+6) & 7)],points[j*8 + ((i+7) & 7)],points[j*8+i],points[j*8+i+1],1)


    repeat i from 15 to 0
      points[i+8]:=points[i]

    waitcnt(cnt+clkfreq>>4)

  repeat
    waitcnt(0)

