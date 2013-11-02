CON

  _clkmode        = xtal1 + pll16x
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz
OBJ

  pst : "Parallax Serial Terminal"

VAR

  long hail[2*6]

PUB hailTest | i

  pst.start(115200)
  repeat i from 0 to 10 step 2
    hail[i]:=(i+1)*5000000-1
    hail[i+1]:=0
    doHail(@hail[i])

  'waitcnt(clkfreq + cnt)

  repeat i from 0 to 10 step 2
    pst.dec(hail[i])
    pst.NewLine
    pst.dec(hail[i+1])
    pst.NewLine





PUB doHail(vAddr) : cog_id
  cog_id:=COGNEW(@doHailAsm, vAddr)


DAT
              org 0
doHailAsm     cogid cid
              rdlong v, par
:loop         add c, #1
              and v, #1  wz, nr
        if_z  jmp #:even
:odd          mov t, v
              add v, v  wc
        if_nc add v, t  wc
        if_nc add v, #1 wc
        if_c  jmp #:end
              jmp #:loop
:even         shr v, #1
              sub v, #1 wz, nr
        if_nz jmp #:loop

:end          mov t, par
              add t, #4
              wrlong v, par
              wrlong c, t
              cogstop cid
cid long 0
v long 0
t long 0
c long 0
zero long 0
fit
