VAR
  byte clock
  byte din
  byte dc
  byte cs
  byte rst
  byte led

  long bufferAddress
  long clockMask
  long dinMask
  long dcMask
  long csMask

PUB start(clock_pin,din_pin,dc_pin,cs_pin,rst_pin,led_pin,buffer_addr)

  clock:=clock_pin
  din:=din_pin
  dc:=dc_pin
  cs:=cs_pin
  rst:=rst_pin
  led:=led_pin
  bufferAddress:=buffer_addr

  clockMask:=1<<clock
  dinMask:=1<<din
  dcMask:=1<<dc
  csMask:=1<<cs


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

  outa[cs]~
  outa[dc]~
  cognew(@writeData, @bufferAddress)


PUB send(dataByte,isData) | waitTime

    dataByte&=$ff
    dataByte<-=25

    outa[clock]~
    outa[dc]:=isData
    outa[cs]~

    repeat 8
      outa[din]:=(dataByte & 1)
      outa[clock]~~
      dataByte<-=1
      outa[clock]~


    outa[cs]~~

PUB writeString(stringLoc,at)| c

  {c:=byte[stringLoc]
  repeat until c==0
    writeChar(at++,c)
    c:=byte[++stringLoc]}
  setCommand(cmdWriteString,stringLoc + (at << 16))
  waitCommand

PUB clearLine(lineToClear)
  longfill(bufferAddress+lineToClear*84,0,21)

PUB writeChar(loc,char)
  if loc<126
    long[bufferAddress][loc]:=long[@font4x8][char]

PUB writeHex(loc,value,digits)

  value <<= (8 - digits) << 2
  repeat digits
    writeChar(loc++,lookupz((value <-= 4) & $F : "0".."9", "A".."F"))

PUB writeDec(loc,value) | i, x

  x := value == NEGX                                                            'Check for max negative
  if value < 0
    value := ||(value+x)                                                        'If negative, make positive; adjust for max negative
    writeChar(loc++,"-")                                                                  'and output sign

  i := 1_000_000_000                                                            'Initialize divisor

  repeat 10                                                                     'Loop for 10 digits
    if value => i
      writeChar(loc++,value / i + "0" + x*(i == 1))                                        'If non-zero digit, output digit; adjust for max negative
      value //= i                                                               'and digit from value
      result~~                                                                  'flag non-zero found
    elseif result or i == 1
      writeChar(loc++,"0")                                                                 'If zero digit (or only digit) output it
    i /= 10

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

PUB setCommand(command,extra)
  long[bufferAddress][126]:=command | (extra << 9)

PUB waitCommand
  repeat while long[bufferAddress][126]==0

PUB setPoint(x,y,s) | a,b
  a:=x+84*(y>>3)
  b:=$80>>(y&7)
  if (a<bufferSize)
    if (s==0)
      byte[bufferAddress][a]&=!b
    else
      byte[bufferAddress][a]|=b

PUB line(x0,y0,x1,y1,s) | dx, dy, sx, sy, err, e2
  dx:=||(x1-x0)
  dy:=||(y1-y0)
  err:=dx-dy

  if (x0<x1)
    sx:=1
  else
    sx:=-1

  if (y0<y1)
    sy:=1
  else
    sy:=-1

  repeat until x0==x1 and y0==y1
    setPoint(x0,y0,s)
    e2:=err<<1
    if e2>-dy
      err-=dy
      x0+=sx
    if e2<dx
      err+=dx
      y0+=sy

  setPoint(x1,y1,s)

PUB scrollTextDown
  longmove(bufferAddress+84,bufferAddress,105)
  longfill(bufferAddress,0,21)

PUB scrollTextUp
  longmove(bufferAddress,bufferAddress+84,105)
  longfill(bufferAddress+420,0,21)

PUB clear
  longfill(bufferAddress,0,126)

CON

  bufferSize=504

DAT

              org 0

writeData     mov _i, par                       'load parameters
              rdlong bufferLocation, _i
              add _i, #4
              rdlong clockPin, _i
              add _i, #4
              rdlong dinPin, _i
              add _i, #4
              rdlong dcPin, _i
              add _i, #4
              rdlong csPin, _i

              mov stopAt, bufferLocation       'find start and end buffer locations
              add stopAt, #bufferSize
              mov readFrom, bufferLocation

              or dira, clockPin                'set dira
              or dira, dinPin
              or dira, dcPin
              or dira, csPin

writeLoop    rdlong longToWrite, readFrom     'get next long
              or outa, csPin                   'set cs high

              sub readFrom, stopAt wz, nr       'check if we reached the end
              muxnz outa, dcPin                 'set dcPin high if not at end
              if_nz jmp #notEnd                'jump if not at end

              mov readFrom, bufferLocation      'move pointer back to begining
              testn longToWrite, #0 wz          'check if we got a command
              if_z jmp #writeLoop              'if not refresh screen

              mov _i, longToWrite
              mov _x, mask
              shl _x, #23
              and _i, _x
              shr longToWrite, #9
              jmp _i

commandDone   wrlong zero, stopAt               'clear command

notEnd       andn outa, clockPin               'set clock low
              mov _i, #32                       'count 32 bits
              andn outa, csPin                  'set cs low
:writeBit     test longToWrite, #1 wz           'get next bit of long
              muxnz outa, dinPin                'write next bit to din
              or outa, clockPin                 'set clock high
              shr longToWrite, #1               'shift current long out
              sub _i,#1 wz                      'decrement counter and set z
              andn outa, clockPin               'set clock low
              if_nz jmp #:writeBit              'if more bits keep goin
              add readFrom, #4                  'else move to next address
              jmp #writeLoop                   'and get next long

cmdWriteString
              mov _y, mask
              shl _y, #16
              mov _x, longToWrite
              and _x, _y
              mov _y, longToWrite
              shl _y, #16
              add _y, bufferLocation             'x=string address, y=lcdBuf address
:loop         rdbyte _z,_x wz                     'z=char data
              if_z jmp #commandDone
              add _z, font4x8
              wrlong _y, _z
              add _x, #1
              add _y, #4
              cmp _y, stopAt wc
              if_ae jmp #commandDone
              jmp #:loop



zero          long 0
mask          long $ffff_ffff

_i             res
_x             res
_y             res
_z             res
readFrom      res
stopAt        res
longToWrite   res
'localCnt      res
'delay         res

bufferLocation res
clockPin res
dinPin res
dcPin res
csPin res

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

fit






























