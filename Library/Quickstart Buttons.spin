'#define QSB_DEBUG
VAR
  long scanStack[12]
  byte iscanVal
  byte cog

#ifdef QSB_DEBUG
OBJ
  pst: "Parallax Serial Terminal"
#endif

PUB start
#ifdef QSB_DEBUG
  pst.Start(115200)
  pst.Str(string("Quickstart Buttons Debug"))
  pst.NewLine
#endif
  iscanVal:=0

  return cog:=cognew(scanCog(clkfreq/100),@scanStack)

PUB stop

'' Stop driver - frees a cog

  if cog>=0
    cogstop(cog)

PUB scanVal : val
  val:=iscanVal

PUB getPressed
  result:=>|iscanVal
  iscanVal:=0

PUB clear
  iscanVal:=0

PUB testAndClear(mask)
#ifdef QSB_DEBUG
 pst.Hex(mask,4)
 pst.Char(32)
#endif
  result:=(iscanVal & mask) > 0
  if result
#ifdef QSB_DEBUG
    pst.Str(string("true"))
    pst.Char(32)
    pst.Hex(iscanVal,4)
    pst.Char(32)
#endif
    iscanVal&=!mask
#ifdef QSB_DEBUG
  pst.Hex(iscanVal,4)
  pst.NewLine
#endif


PRI scanCog(delay) | pads

  repeat
    outa[0..7]~~
    dira[0..7]~~
    dira[0..7]~
    waitcnt(delay+cnt)
    pads := $ff & !ina[7..0]
    if pads<>0
      iscanVal|=pads
      waitcnt((delay * 20) +cnt)

PUB singleScan(delay) | pads
    outa[0..7]~~
    dira[0..7]~~
    dira[0..7]~
    waitcnt(delay+cnt)
    pads := $ff & !ina[7..0]
    if pads<>0
      iscanVal|=pads
      waitcnt((delay * 20) +cnt)
