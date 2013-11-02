VAR
  long scanVal
  byte cog

PUB start
  return cog:=cognew(@startAsm, @scanVal)

PUB stop

  if cog
    cogstop(cog~ - 1)

PUB getState
  return scanVal

DAT
              org 0
startAsm      mov scanValAddr, par
              rdlong delay, #0
              mov lastCnt, cnt
              shr delay, #5
              add lastCnt, delay
:loop         or outa, #$ff
              or dira, #$ff
              and dira, ff_inv
              waitcnt lastCnt, delay
              mov asmScanVal, ina
              xor asmScanVal, #$ff
              and asmScanVal, #$ff
              wrlong asmScanVal, scanValAddr
              jmp #:loop


scanValAddr word 0
asmScanVal long 0
ff_inv long $ffff_ff00
lastCnt long 0
delay long 0
