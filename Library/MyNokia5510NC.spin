VAR
  byte clock
  byte din
  byte dc
  byte cs
  byte rst
  byte led


PUB start(clock_pin,din_pin,dc_pin,cs_pin,rst_pin,led_pin)

  clock:=clock_pin
  din:=din_pin
  dc:=dc_pin
  cs:=cs_pin
  rst:=rst_pin
  led:=led_pin

  outa[cs]~~
  outa[rst]~
  outa[led]~

  dira[rst]~~
  dira[clock]~~
  dira[din]~~
  dira[dc]~~
  dira[cs]~~
  dira[led]~~

  waitcnt(cnt+clkfreq >> 10)
  outa[rst]~~

  outa[led]~~

  send(%00100001,0)
  send(%11000000,0)
  send(%00000110,0)
  send(%00010011,0)
  send(%00100000,0)
  send(%00001100,0)


PUB send(dataByte,isData) | waitTime

    dataByte&=$ff
    dataByte<-=25

    outa[clock]~
    outa[dc]:=isData
    outa[cs]~

    repeat 8
      outa[din]:=dataByte
      outa[clock]~~
      dataByte<-=1
      outa[clock]~


    outa[cs]~~

PUB writeString(at,stringLoc)| c

  setPos(at)

  c:=byte[stringLoc]
  repeat until c==0
    writeNextChar(c)
    c:=byte[++stringLoc]

PUB clearLine(lineToClear)
  setPos(lineToClear*21)
  repeat 21
    writeNextChar(" ")

PUB writeChar(loc,char)

  setPos(loc)

  writeNextChar(char)

PUB setPos(loc)
  send((loc//21) << 2 | %10000000,0)
  send((loc/21) | %01000000,0)


PUB writeNextChar(char) | d

  d:=long[@font4x8][char]><32


  repeat 4
    d<-=8
    send(d & $ff,1)

PUB writeHex(loc,value,digits)

  setPos(loc)

  value <<= (8 - digits) << 2
  repeat digits
    writeNextChar(lookupz((value <-= 4) & $F : "0".."9", "A".."F"))

PUB writeDec(loc,value) | i, x

  setPos(loc)

  x := value == NEGX                                                            'Check for max negative
  if value < 0
    value := ||(value+x)                                                        'If negative, make positive; adjust for max negative
    writeNextChar("-")                                                                  'and output sign

  i := 1_000_000_000                                                            'Initialize divisor

  repeat 10                                                                     'Loop for 10 digits
    if value => i
      writeNextChar(value / i + "0" + x*(i == 1))                                        'If non-zero digit, output digit; adjust for max negative
      value //= i                                                               'and digit from value
      result~~                                                                  'flag non-zero found
    elseif result or i == 1
      writeNextChar("0")                                                                 'If zero digit (or only digit) output it
    i /= 10

PUB writeDecPad(loc,value,len) | oVal, c
  setPos(loc)

  oVal:=value

  if value==0
    len--

  repeat while value>0
    len--
    value/=10

  if len>0
    repeat len
      writeNextChar("0")

  writeDec(loc+len,oVal)


PUB setLED(brightness)
  if (brightness==0)
    outa[led]~
    ctra:=0
  elseif (brightness==$ff)
    ctra:=0
    outa[led]~~
  else
    outa[led]~
    ctra[30..26]:=%00110
    ctra[5..0]:=led
    frqa:=brightness << 21 + $20000000

PUB clear
  setPos(0)
  repeat 126
    writeNextChar(" ")

DAT
font4x8 long  $00000000, $387c3810, $2a552a00, $ff24f800
        long  $149fa0f8, $0aafa040, $0a1f10f0, $78487800
        long  $24742400, $f12f40f0, $0fe810e0, $00f01010
        long  $001f1010, $101f0000, $10f00000, $10ff1010
        long  $40404000, $20202000, $10101000, $08080800
        long  $04040400, $10ff0000, $00ff1010, $08f80808
        long  $080f0808, $00ff0000, $462a1200, $122a4600
        long  $7c407c40, $68382c28, $8ca87e24, $00100000
        long  $00000000, $00007a00, $00600060, $007e247e
        long  $002cd324, $00621846, $005aa65c, $00006000
        long  $00423c00, $00003c42, $00543854, $00107c10
        long  $00000601, $00101010, $00000600, $00601806
        long  $003c523c, $00027e22, $00324a26, $006c5244
        long  $007e2818, $004c5274, $004c523c, $00704e40
        long  $002c522c, $003c4a32, $00002400, $00002402
        long  $00221408, $00282828, $00081422, $00304a20
        long  $0032423c, $003e483e, $002c527e, $0024423c
        long  $003c427e, $0052527e, $0050507e, $002c423c
        long  $007e107e, $00427e42, $007c0204, $006e107e
        long  $0002027e, $007e207e, $007c183e, $003c423c
        long  $0030487e, $003a463c, $0036487e, $002c5224
        long  $00407e40, $007e027e, $007c027c, $007e047e
        long  $006e106e, $00601e60, $00625a46, $00427e00
        long  $00061860, $00007e42, $00204020, $01010101
        long  $00002040, $001e2a24, $000c127e, $0022221c
        long  $007e120c, $001a2a1c, $00503e10, $003e2519
        long  $000e107e, $00025e12, $005e1101, $0016087e
        long  $00007e00, $003e103e, $001e203e, $001c221c
        long  $0018243f, $003f2418, $0020201e, $00242a12
        long  $00107e10, $003e023e, $003c023c, $003e043e
        long  $00360836, $003e0539, $00322a26, $00826c10
        long  $0000ee00, $00106c82, $00103020, $00000000
































