'#define DEBUG
'#define STACK
CON

  initialBitrate = 9600
  lineInLength = 128
  stackLength = 64
  maxFields = 32

  'Calling object variable positions
  time = 0
  date = 4
  latitude = 8
  longitude = 12
  mslAltitude = 16
  geoidalSep = 20
  mode = 24
  satInfo = 28
  HDOP = 92
  PVDOP = 96
  speed = 100
  course = 104


  {{Calling object should define the following
  long time
  long date
  long latitude
  long longitude
  long mslAltitude
  long geoidalSep
  long mode
  long satInfo[16]
  long HDOP
  long PVDOP
  long speed
  long course
  }}

VAR

  long cog
  long linePos
  long stack[stackLength]
  long fields[maxFields]
  byte lineIn[lineInLength]
  long structPtr

OBJ

#ifdef STACK
  st: "Stack Length"
#endif

#ifdef DEBUG
  pst: "Parallax Serial Terminal"
#endif

  fds: "FullDuplexSerialExtended"

PUB start(rx, tx, bitMode, structPtrIn)
#ifdef STACK
  st.init(@stack,stackLength)
#endif

  structPtr:=structPtrIn

  stop
  result := cog := cognew(readLoop(rx,tx,bitMode), @stack) + 1

PUB stop
#ifdef STACK
  st.getLength(30,115200)
#endif

  if cog
    cogstop(cog~ - 1)

PRI readLoop(rx, tx, bitMode) | b

#ifdef DEBUG
  pst.start(115200)
  pst.str(string("readLoop Started"))
  pst.NewLine
#endif

  fds.start(rx, tx, bitMode, initialBitrate)
  linePos:=0

  repeat
     b:=fds.rx

     lineIn[linePos++]:=b

     if b==10
#ifdef DEBUG
      lineIn[linePos++]:=0
      pst.str(@lineIn)
#endif
      parseLine
#ifdef DEBUG
      pst.str(string("Values:"))
      pst.NewLine
      repeat b from time to course step 4
        pst.hex(long[structPtr + b],8)
        pst.char(" ")
        if (b & $f)==0
          pst.NewLine
      pst.NewLine
#endif

PRI parseLine | i, fieldCount, chkSum, correctSum, startParse
  if lineIn[0]=="$"

    i:=1
    fields[0]:=@lineIn[1]
    fieldCount:=1
    chkSum:=0

    repeat while lineIn[i]<>"*" and i<lineInLength
      chkSum^=lineIn[i]
      if lineIn[i]==","
        fields[fieldCount++]:=@lineIn[i+1]
        lineIn[i]:=0


      i++

    lineIn[i]:=0
    correctSum:=i+1

    repeat while lineIn[i]<>10 and i<lineInLength
      i++

    lineIn[i-1]:=0

    correctSum:=hexToLong(@lineIn[correctSum])

    if (correctSum==chkSum)
#ifdef DEBUG
      pst.str(string("Sum checks"))
      pst.NewLine
      pst.str(fields[0])
      pst.NewLine
      startParse:=cnt
#endif
      if strEqu(fields[0],@GPGGA)
        parseGPGGA
      elseif strEqu(fields[0],@GPGSA)
        parseGPGSA
      elseif strEqu(fields[0],@GPGSV)
        parseGPGSV
      elseif strEqu(fields[0],@GPRMC)
        parseGPRMC
      elseif strEqu(fields[0],@GPVTG)
        parseGPVTG
#ifdef DEBUG
      pst.str(string("Parse time: "))
      pst.dec(cnt-startParse)
      pst.NewLine
#endif

  linePos:=0

PRI parseGPGGA | i
#ifdef DEBUG
  pst.str(string("Parsing GPGGA"))
  pst.NewLine
#endif

  long[structPtr + time]:=parseTime(fields[1])
  long[structPtr + latitude]:=parseLat(fields[2],fields[3])
  long[structPtr + longitude]:=parseLong(fields[4],fields[5])
  long[structPtr + mode]&=$00ffff00
  long[structPtr + mode]|=(strToLong(fields[6]) << 24 | strToLong(fields[7]))
  long[structPtr + HDOP]:=parseDec(fields[8],2)
  long[structPtr + mslAltitude]:=parseDec(fields[9],2)
  long[structPtr + geoidalSep]:=parseDec(fields[11],2)

PRI parseGPGSA | i, s
#ifdef DEBUG
  pst.str(string("Parsing GPGSA"))
  pst.NewLine
#endif

  long[structPtr + mode]&=$ff0000ff
  long[structPtr + mode]|=byte[fields[1]]<<24 | strToLong(fields[2])
  {repeat i from 0 to 12
    s:=structPtr + satInfo + (i*4)
    long[s]:=long[s] & $01ffffff | strToLong(fields[3+i]) << 25
  }
  long[structPtr + HDOP]:=parseDec(fields[16],2)
  long[structPtr + PVDOP]:=parseDec(fields[15],2) << 16 | parseDec(fields[17],2)




PRI parseGPGSV | m, i
#ifdef DEBUG
  pst.str(string("Parsing GPGSV"))
  pst.NewLine
#endif

  m:=strToLong(fields[2])
  long[structPtr + mode]&=$ffffff00
  long[structPtr + mode]|=strToLong(fields[3])

  repeat i from 0 to 3
    long[structPtr + satInfo + ((m-1)<<2 + i) <<2]:= {
}     strToLong(fields[4 + i<<2]) << 25 | {
}     strToLong(fields[5 + i<<2]) << 16 | {
}     strToLong(fields[6 + i<<2]) << 8  | {
}     strToLong(fields[7 + i<<2])


PRI parseGPRMC
#ifdef DEBUG
  pst.str(string("Parsing GPRMC"))
  pst.NewLine
#endif

  long[structPtr + speed]:=parseDec(fields[7],2)
  long[structPtr + course]:=parseDec(fields[8],2)
  long[structPtr + date]:=parseDate(fields[9])

PRI parseGPVTG
#ifdef DEBUG
  pst.str(string("Parsing GPVTG"))
  pst.NewLine
#endif


PRI parseTime(ptr)
  result:=strToLong2(ptr,2)<<24 | strToLong2(ptr+2,2) << 16 | parseDec(ptr+4,3)

PRI parseDate(ptr)
  result:=strToLong2(ptr,2)<<24 | strToLong2(ptr+2,2) << 16 | (strToLong2(ptr+4,2) + 2000)

PRI parseLat(ptr,indic)
  result:=strToLong2(ptr,2)*600_000
  result+=parseDec(ptr+2,4)
  if byte[indic]=="S"
    -result

PRI parseLong(ptr,indic)
  result:=strToLong2(ptr,3)*600_000
  result+=parseDec(ptr+3,4)
  if byte[indic]=="W"
    -result

PRI strToLong(ptr)

  result:=0

  repeat while byte[ptr]<>0
    result*=10
    result+=byte[ptr++]-"0"

PRI strToLong2(ptr,len)

  result:=0

  repeat len
    result*=10
    result+=byte[ptr++]-"0"

PRI hexToLong(ptr) | b

  result:=0

  repeat while (b:=byte[ptr++])<>0
    result<<=4
    b-="0"
    if b>9
      b-=7
    if b>15
      b-=32
    result+=b


PRI strEqu(ptr1, ptr2)

  repeat while byte[ptr1]==byte[ptr2]
    if byte[ptr1]==0
      return true
    ptr1++
    ptr2++
  return false

PRI parseDec(ptr,precision)

  result:=0

  repeat while byte[ptr]<>"."
    result*=10
    result+=byte[ptr++]-"0"

  ptr++

  repeat while precision>0
    result*=10
    if byte[ptr]<>0
      result+=byte[ptr++]-"0"
    precision--

DAT

GPGGA   byte  "GPGGA",0
GPGSA   byte  "GPGSA",0
GPGSV   byte  "GPGSV",0
GPRMC   byte  "GPRMC",0
GPVTG   byte  "GPVTG",0


