CON

  _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

OBJ

  rpi: "Parallax Serial Terminal"
  pc: "Parallax Serial Terminal"

CON

  lineMax=64
  skipBoot=true
  skipLogin=true


VAR

  byte lineIn[lineMax+1]

PUB raspiServer | op, s, e, stringStart

  setup

  repeat
    rpi.StrInMax(@lineIn,lineMax)
    stringStart:=@lineIn
    if lineIn[0]==$0A
      stringStart++

    op:=StrToBase(stringStart+1,8,16)

    pc.Char(lineIn)
    pc.NewLine
    pc.Hex(op,8)
    pc.NewLine

    case byte[stringStart]
      "D":
        s:=op&$ff
        e:=(op>>8) & $ff
        dira[s..e]:=op>>16
      "O":
        s:=op&$ff
        e:=(op>>8) & $ff
        outa[s..e]:=op>>16
      "I":
        rpi.Hex(ina,8)
        rpi.NewLine
      "C":
        ctra:=op
      "c":
        ctrb:=op
      "F":
        frqa:=op
      "f":
        frqb:=op
      "P":
        phsa:=op
      "p":
        phsb:=op
      "Q":
        rpi.Hex(frqa,8)
        rpi.NewLine
      "q":
        rpi.Hex(frqb,8)
        rpi.NewLine
      "H":
        rpi.Hex(phsa,8)
        rpi.NewLine
      "h":
        rpi.Hex(phsb,8)
        rpi.NewLine
      "N":
        rpi.Hex(cnt,8)
        rpi.NewLine


PUB setup

  pc.start(115200)
  rpi.startRxTx(12,13,%0100,115200)

  ifnot skipBoot
    waitPrompt(@bootDonePrompt)
  rpi.NewLine

  ifnot skipLogin
    waitPrompt(@loginPrompt)
    rpi.RxFlush
    rpi.str(@username)
    rpi.NewLine

    waitPrompt(@passwordPrompt)
    rpi.RxFlush
    rpi.str(@password)
    rpi.NewLine

  waitPrompt(@commandPrompt)
  rpi.str(@command)
  rpi.NewLine

  waitcnt(cnt+clkfreq>>4)
  rpi.RxFlush

PUB waitPrompt(prompt) | c,foundTo

  foundTo:=0

  repeat while byte[prompt][foundTo]<>0
    c:=rpi.CharIn
    if (c==byte[prompt][foundTo])
      foundTo++
    else
      foundTo:=0

  pc.str(string("Found prompt: "))
  pc.str(prompt)
  pc.NewLine

PRI StrToBase(stringptr, count, base) : value | chr, index
{Converts a zero terminated string representation of a number to a value in the designated base.
Ignores all non-digit characters (except negative (-) when base is decimal (10)).}

  value := index := 0
  repeat until ((chr := byte[stringptr][index++]) == 0) or index>count
    chr := -15 + --chr & %11011111 + 39*(chr > 56)                              'Make "0"-"9","A"-"F","a"-"f" be 0 - 15, others out of range
    if (chr > -1) and (chr < base)                                              'Accumulate valid values into result; ignore others
      value := value * base + chr
  if (base == 10) and (byte[stringptr] == "-")                                  'If decimal, address negative sign; ignore otherwise
    value := - value

DAT

bootDonePrompt byte "Debian GNU/Linux wheezy/sid raspberrypi ttyAMA0",0
loginPrompt   byte "raspberrypi login: ", 0
passwordPrompt byte "Password: ",0
commandPrompt byte "michael@raspberrypi:~$ ",0
username byte "michael",0
password byte "hexais10",0
command byte "stty icrnl -echo; nc -klU /var/tmp/propSocket",0
