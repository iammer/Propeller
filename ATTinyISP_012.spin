'' 
''  ATTinyISP.spin                                                     v0.00 
'' 
''   Author:            (c) 2011 "Cluso99" (Ray Rodrick)                     
''   Acknowledgements:  see relevant files for authors and acknowledgements  
'' 
''  Program to ptogram the Atmel ATTiny series micros by the ISP method (SPI)
'' 
'' RR20111016   000  commence
''              005  works for prog ena, read sig bytes, read lock/fuses/cal bytes
'' RR20111017   006  add read prog memory and eeprom
''              007  try programming - bug; add eeprom & mem display block/page
''              008  add erase chip - works
''              009  programming ok
''              010  programs & verifies but code does not work (erases chip first)
''              011  code tidy
''              012  new attiny code to flash leds (works)

'' Notes:
'' 1. Timing has not been done accurately - everything is much slower than required.
''     This was in order to get the programmer working.
'' 2. It would be nice to read the code from a hex file on the pc.

CON

  _xinfreq  = 5_000_000        
  _clkmode  = xtal1 + pll16x

'prop pins connected to the ATTiny84 ISP for programming (Cluso's AvrBlade pcb)
  ResetPin  = 4                 'ATTiny84-4
  SclkPin   = 6                 '        -9 (SCL)
  MosiPin   = 5                 '        -7 (SDA)
  MisoPin   = 7                 '        -8

  rxPin  = 31                   'serial
  txPin  = 30
  baud   = 115200

OBJ
  fdx    : "FullDuplexSerial"
  

VAR
  long  rd_byte1, rd_byte2, rd_byte3, rd_byte4
  long  _1us, _1ms, _1s         'set to 1us/1ms/1s
  long  ctime                   'set SCK half cycle time
  long  detail                  'display detail if true
  long  showread4               'display if true
  
PUB Main | i

  _1us := clkfreq / 1_000_000                            ' calc 1us for current xtal
  _1ms := clkfreq / 1_000
  _1s  := clkfreq
  ctime := _1us * 100           '10us works but fdx may cause problem!!!
  detail := true
  showread4 := false
  
  fdx.start(rxPin, txPin, 0, baud)                      ' init serial port
  waitcnt(_1s * 5 + cnt)
  fdx.tx(0)                                             ' cls
  fdx.str(string(13,"ATTiny ISP programmer v012",13,13))

  SPI_init

  fdx.str(string("Programming Enable...",13))
  SPI_Instr($AC,$53,$00,$00)                            ' programming enable
  SPI_Instr($AC,$53,$00,$00)                            ' programming enable

  detail := false

  'check we received the correct response
  if rd_byte3 == $53
    showread4 := true

    fdx.str(string(13,"Read Vendor/Family/PartNo/Lock/FuseL/FuseH/FuseX/Calibrate bytes...",13))
    SPI_Instr($30,$00,$00,$00)                          ' read vendor code
    SPI_Instr($30,$00,$01,$00)                          ' read family/flash
    SPI_Instr($30,$00,$02,$00)                          ' read partno
    SPI_Instr($58,$00,$00,$00)                          ' read lock bits
    SPI_Instr($50,$00,$00,$00)                          ' read fuse bits
    SPI_Instr($58,$08,$00,$00)                          ' read fuse high bits
    SPI_Instr($50,$08,$00,$00)                          ' read fuse extended bits
    SPI_Instr($38,$00,$00,$00)                          ' read calibration bits
    fdx.tx(13)
    
    showread4 := false

    fdx.str(string(13,"Read EEPROM memory...",13))
    repeat i from 0 to 15
      SPI_Read_Eeprom($00,$00 + (i << 4),16)            ' read 256B eeprom block
    repeat i from 0 to 15
      SPI_Read_Eeprom($01,$00 + (i << 4),16)            ' read 256B eeprom block

    fdx.str(string(13,"Read program memory...",13))
    SPI_ReadPage_ProgMem($00, $00)                      ' read a page
    SPI_ReadPage_ProgMem($00, $40)                      ' read a page
    SPI_ReadPage_ProgMem($00, $80)                      ' read a page
    SPI_ReadPage_ProgMem($00, $C0)                      ' read a page
'   SPI_ReadPage_ProgMem($01, $00)                      ' read a page
'   SPI_ReadPage_ProgMem($02, $40)                      ' read a page
'   SPI_ReadPage_ProgMem($03, $80)                      ' read a page
'   SPI_ReadPage_ProgMem($04, $C0)                      ' read a page


    fdx.str(string(13,"Erase Chip..."))
    SPI_Instr($AC,$80,$00,$00)                          ' erase chip
    delay(_1s)
    fdx.str(string("done.",13))

    fdx.str(string(13,"Read program memory...",13))
    SPI_ReadPage_ProgMem($00, $00)                      ' read a page
    SPI_ReadPage_ProgMem($00, $40)                      ' read a page
    SPI_ReadPage_ProgMem($00, $80)                      ' read a page
    SPI_ReadPage_ProgMem($00, $C0)                      ' read a page


    ctime := 100 * _1us         'make delay larger

    fdx.str(string(13,"Write program memory...",13))
    SPI_WritePage_ProgMem($00,$00,32)                   ' write a prog mem page
    SPI_WritePage_ProgMem($00,$20,32)                   ' write a prog mem page
    SPI_WritePage_ProgMem($00,$40,32)                   ' write a prog mem page

    
    ctime := _1us * 100         '10us works but fdx may cause problem!!!

    fdx.str(string(13,"Read back program memory...",13))
    SPI_ReadPage_ProgMem($00, $00)                      ' read a page
    SPI_ReadPage_ProgMem($00, $40)                      ' read a page
    SPI_ReadPage_ProgMem($00, $80)                      ' read a page
    SPI_ReadPage_ProgMem($00, $C0)                      ' read a page

    
  else
    fdx.str(string("...Failed!!!",13))

  SPI_Done                                              ' make all inputs
  fdx.str(string("End.",13))
  repeat                        '<+++++++++++++loop


PRI SPI_WritePage_ProgMem(addrh,addrl,len) | det        'max len 32 (32 words)
'' Write up to a page of program memory
'' The Program Memory page size for the ATTiny24 is 16 words, and the 44 & 84 is 32 words
  det := detail
  detail := false
  fdx.str(string("Load Program Memory ...",13))
  SPI_LoadRow_ProgMem(addrh,addrl,8)
  if len > 8
    SPI_LoadRow_ProgMem(addrh,addrl + $08,8)
  if len > 16
    SPI_LoadRow_ProgMem(addrh,addrl + $10,8)
  if len > 24
    SPI_LoadRow_ProgMem(addrh,addrl + $18,8)

  fdx.str(string("Write Page..."))
  SPI_Instr($4C,addrh,addrl,$00)                        ' write prog mem page
  delay(_1s)                                            ' delay for now!!!!!  (min 5ms)
  fdx.str(string("done.",13))
  detail := det


PRI SPI_LoadRow_ProgMem(addrh, addrl, len) | i, addr, tmp1, tmp2
  fdx.tx("$")
  fdx.hex(addrh,2)
  fdx.hex(addrl,2)
  fdx.str(string(": "))
  repeat i from 0 to len-1
''  addr := (addrh << 8) + ((addrl + i) * 2)            ' index to first byte
    addr := (addrl + i) * 2                             ' index to first byte
    tmp1 := hex[addr]
    addr := addr + 1                                    ' index to second byte
    tmp2 := hex[addr]
    fdx.hex(tmp1,2)
    fdx.tx(" ")
    fdx.hex(tmp2,2)
    fdx.tx(" ")
    SPI_Instr($40,addrh,addrl + i,tmp1)                  ' load low byte  (low byte MUST be first)
    SPI_Instr($48,addrh,addrl + i,tmp2)                  ' load high byte
  fdx.tx(13)

PRI SPI_ReadPage_ProgMem(addrh, addrl)
'   fdx.str(string("Read a program memory page...",13))
    SPI_Read_ProgMem(addrh,addrl + $00,8)               ' read a prog mem block
    SPI_Read_ProgMem(addrh,addrl + $08,8)               ' read a prog mem block
    SPI_Read_ProgMem(addrh,addrl + $10,8)               ' read a prog mem block
    SPI_Read_ProgMem(addrh,addrl + $18,8)               ' read a prog mem block
    SPI_Read_ProgMem(addrh,addrl + $20,8)               ' read a prog mem block
    SPI_Read_ProgMem(addrh,addrl + $28,8)               ' read a prog mem block
    SPI_Read_ProgMem(addrh,addrl + $30,8)               ' read a prog mem block
    SPI_Read_ProgMem(addrh,addrl + $38,8)               ' read a prog mem block

PRI SPI_Read_ProgMem(addrh, addrl, len) | i, det        'max len 256 words (no overflow!)
'' Read a Program Memory block
  fdx.tx("$")
  fdx.hex(addrh,2)
  fdx.hex(addrl,2)
  fdx.str(string(": "))
  det := detail                                         ' save detail setting
  detail := false
  repeat i from 0 to len-1
    SPI_Instr($20,addrh,addrl+i,$00)                    ' read low byte
    fdx.hex(rd_byte4,2)
    fdx.tx(" ")
    SPI_Instr($28,addrh,addrl+i,$00)                    ' read high byte
    fdx.hex(rd_byte4,2)
    fdx.tx(" ")
  fdx.tx(13)
  detail := det                                         ' restore detail setting

PRI SPI_Read_Eeprom(addrh, addrl, len) | i, det         'max len 256 words (no overflow!)
'' Read an EEPROM Memory block
  fdx.tx("$")
  fdx.hex(addrh,2)
  fdx.hex(addrl,2)
  fdx.str(string(": "))
  det := detail                                         ' save detail setting
  detail := false
  repeat i from 0 to len-1
    SPI_Instr($A0,addrh,addrl+i,$00)                    ' read byte
    fdx.hex(rd_byte4,2)
    fdx.tx(" ")
  fdx.tx(13)
  detail := det                                         ' restore detail setting


PRI SPI_Init
'' Initialise ATTiny to enter program mode
  outa := 0                                             ' all low
  dira[mosiPin]~~                                       ' =1 (output)
  dira[sclkPin]~~                                       ' =1 (output)
  dira[resetPin]~~                                      ' =1 (output)
  delay(20 * _1ms)

PRI SPI_Instr(byte1, byte2, byte3, byte4)
' now perform serial instruction (we read into rd_byte concurrently as we write)
  rd_byte1 := SPI_Write(byte1)                          ' write
  rd_byte2 := SPI_Write(byte2)                          ' write (often addr msb)
  rd_byte3 := SPI_Write(byte3)                          ' write (often addr lsb)
  rd_byte4 := SPI_Write(byte4)                          ' write/read byte
  Display_SPI(byte1,byte2,byte3,byte4)
  
PRI Display_SPI(byte1, byte2, byte3, byte4)
  if detail
    fdx.hex(byte1,2)                                    ' display what we wrote
    fdx.tx(" ")
    fdx.hex(byte2,2)                                    ' display what we wrote
    fdx.tx(" ")
    fdx.hex(byte3,2)                                    ' display what we wrote
    fdx.tx(" ")
    fdx.hex(byte4,2)                                    ' display what we wrote
    fdx.str(string(" --> "))
    fdx.hex(rd_byte1,2)                                 ' display what we readback
    fdx.tx(" ")
    fdx.hex(rd_byte2,2)                                 ' display what we readback
    fdx.tx(" ")
    fdx.hex(rd_byte3,2)                                 ' display what we readback
    fdx.tx(" ")
    fdx.hex(rd_byte4,2)                                 ' display what we readback
    fdx.tx(13)
  if showread4
    fdx.tx("$")
    fdx.hex(rd_byte4,2)
    fdx.tx(" ")

PRI SPI_Done

  dira[ResetPin]~                                       'input
  dira[SclkPin]~                                        'input
  dira[MosiPin]~                                        'input

                                                            
PRI SPI_Write(Value) : tmp
'' Send byte out msb first and simultaneously read a byte in
  Value <<= 24                                          ' pre-align msb
  tmp := 0
  delay(ctime)
  repeat 8
    outa[mosiPin] := (Value <-= 1) & 1                  ' output data bit
    tmp := (tmp << 1) | ina[misoPin]                    ' input data bit
    delay(ctime)
    outa[sclkPin]~~                                     ' clock high
    delay(ctime)
    outa[sclkPin]~                                      ' clock low
    delay(ctime)

PRI delay(time)
  waitcnt(time + cnt)                                   ' timed delay    


DAT
{{
'A simple led flasher for the ATTiny84 on PortA 0&1
Hex     byte  $10,$C0,$17,$C0,$16,$C0,$15,$C0,$14,$C0,$13,$C0,$12,$C0,$11,$C0   ' :10000000  54
        byte  $10,$C0,$0F,$C0,$0E,$C0,$0D,$C0,$0C,$C0,$0B,$C0,$0A,$C0,$09,$C0   ' :10001000  7C
        byte  $08,$C0,$11,$24,$1F,$BE,$CF,$E5,$D2,$E0,$DE,$BF,$CD,$BF,$02,$D0   ' :10002000  95
        byte  $35,$C0,$E6,$CF,$0F,$93,$1F,$93,$DF,$93,$CF,$93,$00,$D0,$00,$D0   ' :10003000  4E
        byte  $00,$D0,$CD,$B7,$DE,$B7,$1A,$82,$19,$82,$8A,$E3,$90,$E0,$2F,$E0   ' :10004000  A4
        byte  $FC,$01,$20,$83,$8B,$E3,$90,$E0,$23,$E0,$FC,$01,$20,$83,$88,$EB   ' :10005000  0C
        byte  $9B,$E0,$9C,$83,$8B,$83,$8B,$81,$9C,$81,$8C,$01,$C8,$01,$01,$97   ' :10006000  D1
        byte  $F1,$F7,$8C,$01,$1C,$83,$0B,$83,$8B,$E3,$90,$E0,$FC,$01,$10,$82   ' :10007000  71
        byte  $88,$EB,$9B,$E0,$9E,$83,$8D,$83,$8D,$81,$9E,$81,$8C,$01,$C8,$01   ' :10008000  CE
        byte  $01,$97,$F1,$F7,$8C,$01,$1E,$83,$0D,$83,$DC,$CF,$F8,$94,$FF,$CF   ' :10009000  1D
'        byte                                                                   ' :00000001  FF
}}
'' A simple led flasher for the ATTiny84 on PORTA bits 0 & 1 
Hex     byte  $10,$C0,$17,$C0,$16,$C0,$15,$C0,$14,$C0,$13,$C0,$12,$C0,$11,$C0   '  :10000000     54
        byte  $10,$C0,$0F,$C0,$0E,$C0,$0D,$C0,$0C,$C0,$0B,$C0,$0A,$C0,$09,$C0   '  :10001000     7C
        byte  $08,$C0,$11,$24,$1F,$BE,$CF,$E5,$D2,$E0,$DE,$BF,$CD,$BF,$02,$D0   '  :10002000     95
        byte  $3E,$C0,$E6,$CF,$DF,$93,$CF,$93,$00,$D0,$00,$D0,$CD,$B7,$DE,$B7   '  :10003000     80
        byte  $1A,$82,$19,$82,$1C,$82,$1B,$82,$8A,$E3,$90,$E0,$2F,$E0,$FC,$01   '  :10004000     55
        byte  $20,$83,$8B,$E3,$90,$E0,$23,$E0,$FC,$01,$20,$83,$1A,$82,$19,$82   '  :10005000     45
        byte  $09,$C0,$87,$E3,$90,$E0,$9C,$83,$8B,$83,$89,$81,$9A,$81,$01,$96   '  :10006000     04
        byte  $9A,$83,$89,$83,$89,$81,$9A,$81,$FF,$E7,$8F,$3F,$9F,$07,$89,$F7   '  :10007000     58
        byte  $8B,$E3,$90,$E0,$FC,$01,$10,$82,$1A,$82,$19,$82,$09,$C0,$87,$E3   '  :10008000     99
        byte  $90,$E0,$9C,$83,$8B,$83,$89,$81,$9A,$81,$01,$96,$9A,$83,$89,$83   '  :10009000     DE
        byte  $89,$81,$9A,$81,$FF,$E7,$8F,$3F,$9F,$07,$89,$F7,$D2,$CF,$F8,$94   '  :1000A000     24
        byte  $FF,$CF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF   '  :0200B000     80
'        byte                                                                   '  :00000001 FF
'' Source C code for the flasher (immediately above hex code)
{{------------------------------------------------------------------------------
/*
 * AVRtest003.c
 *
 * Created: 17/10/2011 6:37:33 PM
 *  Author: Ray
 */ 

#include <avr/io.h>

int main(void)
{
  int i = 0;
  int k = 0;

    // set PORTA:0-3 for output
    DDRA = 0x0F;
    while(1)
    {
                PORTA = 0x03;
                for ( i = 0; i < 32767; i++)
                {
                        k=55;
                }
                PORTA = 0x00;
                for ( i = 0; i < 32767; i++)
                {
                        k=55;
                }
                
    }
        return(1);
}
------------------------------------------------------------------------------}}

DAT
{{

                                                   TERMS OF USE: MIT License                                                                                                              

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation     
files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    
modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software
is furnished to do so, subject to the following conditions:                                                                   
                                                                                                                              
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
                                                                                                                              
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          
WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         

}} 