CON
	_xinfreq = 5_000_000
	_clkmode = xtal1 + pll16x

	CLK = 8
	MISO = 9
	MOSI = 10
	RESET = 11

OBJ

	pst: "Unix Serial Terminal"

VAR
	word pageData[32]
	word buffer[4096]
	byte input[256]

PUB start | o, i, j, nc
	pst.start(115200)

	pst.str(string("ATTiny Programmer"))
	pst.newline

	outa[CLK]~
	outa[MOSI]~
	outa[RESET]~~
	dira[CLK]~~
	dira[MOSI]~~
	dira[RESET]~~

	outa[RESET]~
	waitcnt(cnt + (clkfreq >> 5))

	repeat
		pst.StrInMax(@input,255)
		pst.str(@input)
		pst.str(string("<<"))
		pst.newline

		if strcomp(@input,string("HEX"))
			i:=readHEX
			if i>0
				writeBuffer(i)
		elseif strcomp(@input,string("TEST"))
			runAndTest
		elseif strcomp(@input,string("ENABLE"))
			pst.str(string(">>ENABLE"))
			pst.newline
			programEnable
		elseif strcomp(@input,string("ERASE"))
			pst.str(string(">>ERASE"))
			chipErase
		{{
		elseif strcomp(@input,string("EEPROM")
			readEEPROM
			writeEEPROM
		elseif strcomp(@input,string("FUSE")
			loadFUSE
		elseif strcomp(@input,string("FUSEEXT")
			loadFUSEEXT
		elseif strcomp(@input,string("FUSEHIGH")
			loadFUSEHIGH
		}}


PUB writeBuffer(addr) 
	writeProgMem(0,@buffer,(addr>>5)+1)
	
	

PUB readHEX | byteCount, addr, recType, checksum, b, maxAddr
	pst.str(string(">>HEX"))
	pst.newline
	wordfill(@buffer,$ffff,4096)
	maxAddr:=0
	repeat
		if not pst.charIn==":"
			pst.str(string("INVALID"))
			return -1
		byteCount:=pst.hexInCount(2)
		addr:=pst.hexInCount(4)
		maxAddr #>= addr
		recType:=pst.hexInCount(2)
		checksum:=byteCount+(addr >> 8) + (addr & $ff) +recType
		pst.newline
		if recType==0
			repeat byteCount
				b:=pst.hexInCount(2)
				if addr & 1 == 0
					buffer[addr>>1]:=b
				else
					buffer[addr>>1]|=b<<8
				checksum+=b
				addr++
			checksum+=pst.hexInCount(2)
			if (checksum & $ff) <> 0 or (pst.charIn <> pst#NL)
				pst.str(string("BAD CHECKSUM: "))
				pst.hex(checksum,2)
				pst.newline
				return -1
			pst.hex(addr,4)
			pst.char(":")
			pst.hex(byteCount,2)
			pst.newline
		elseif recType==1
			pst.strInMax(@input,255)
			pst.str(string(">>HEXDONE"))
			return maxAddr




PUB runAndTest
	waitcnt(cnt+clkfreq>>2)
	dira[MOSI]~
	outa[RESET]~~

	repeat
		if ina[MOSI]
			pst.str(string("ON"))
		else
			pst.str(string("OFF"))
		pst.newline
		waitcnt(cnt+clkfreq>>2)



PUB dumpState | i, j
	pst.str(string("Program Memory"))
	pst.newline

	readProgMem(0,@buffer,4)
	repeat i from 0 to 3
		repeat j from 0 to 31
			pst.hex(buffer[i<<5 | j] & $ff,2)
			pst.hex(buffer[i<<5 | j] >> 8,2)
			if (j==15)
				pst.newline
		pst.newline
	
	pst.str(string("EEPROM"))
	pst.newline

	repeat i from 0 to 128
		pst.hex(readEEPROMPage(i<<2),8)
		if i & 7 == 7
			pst.newline
	
	pst.newline
		
	pst.str(string("Signature: "))
	pst.hex(readSignature,6)
	pst.newline

	pst.str(string("Lock: "))
	pst.hex(readLock, 2)
	pst.newline

	pst.str(string("Fuse: "))
	pst.hex(readFuse,2)
	pst.newline

	pst.str(string("Fuse High: "))
	pst.hex(readFuseHigh,2)
	pst.newline

	pst.str(string("Fuse Extended: "))
	pst.hex(readFuseExtended,2)
	pst.newline

	pst.str(string("Calibration: "))
	pst.hex(readCalibration,2)
	pst.newline
	
	{{repeat i from 0 to 64 step 32
		wordmove(@pageData,@program + (i<<1),32)
		writeProgMemPage(i)

	repeat i from 0 to 64 step 32
		readProgMemPage(i)
		pst.str(string(">>"))
		repeat j from 0 to 31
			pst.hex(pageData[j],4)
			pst.char(" ")
		pst.newline
	

	waitcnt(cnt+clkfreq>>2)
	dira[MOSI]~
	outa[RESET]~~

	repeat
		if ina[MOSI]
			pst.str(string("ON"))
		else
			pst.str(string("OFF"))
		pst.newline
		waitcnt(cnt+clkfreq>>2)
	}}
	
PUB programEnable
	logAndWrite($ac53 << 16)

PUB readProgMem(addr,buf,pageCount)
	repeat pageCount
		readProgMemPage(addr)
		wordmove(buf,@pageData,32)
		addr+=32
		buf+=64

PUB writeProgMem(addr,buf,pageCount)
	repeat pageCount
		wordmove(@pageData,buf,32)
		writeProgMemPage(addr)
		addr+=32
		buf+=64


PUB readProgMemPage(addr) | i
	repeat i from 0 to 31
		pageData[i]:=logAndWrite($20 << 24 | (addr+i) << 8) & $ff
		pageData[i]|=((logAndWrite($28 << 24 | (addr+i) << 8) & $ff) << 8)


PUB writeProgMemPage(addr) | i
	repeat i from 0 to 31 
		logAndWrite($40 << 24 | (addr+i) << 8 | (pageData[i] & $ff))
		logAndWrite($48 << 24 | (addr+i) << 8 | pageData[i] >> 8)
		
	logAndWrite($4c << 24 | (addr & $3f) << 8)
	waitReady

PUB chipErase
	logAndWrite($ac80 << 16)
	waitReady

PUB logAndWrite(d)
	'pst.hex(d,8)
	'pst.str(string(": "))
	result:=write(d)
	'pst.hex(result,8)
	'pst.newline


PUB write(d) | in
	in:=0
	
	repeat 32
		d<-=1
		outa[MOSI]:=d&1
		outa[CLK]~~
		in:=(in<<1)|ina[MISO]
		outa[CLK]~
	
	return in

PUB writeEEPROMPage(addr,val) | i
	repeat i from 0 to 3
		logAndWrite($c1 << 24 | i << 8 | (val & $ff))
		val >>= 8
	logAndWrite($c2 << 24 | (addr & $3c) << 8)
	waitReady

PUB readEEPROMPage(addr) | val, i
	val:=0
	addr&=$fc
	repeat i from 0 to 3
		val<<=8
		val|=readEEPROMByte(addr+i)
	return val

PUB writeEEPROMByte(addr,val)
	logAndWrite($c0 << 24 | addr << 8 | (val & $ff))
	waitReady

PUB readEEPROMByte(addr)
	return logAndWrite($a0 << 24 | addr << 8) & $ff

PUB readLock
	return logAndWrite($58 << 24) & $ff

PUB writeLock(val)
	logAndWrite($ace0 << 16 | (val & $ff))
	waitReady

PUB readSignature | i, val
	val:=0

	repeat i from 0 to 2
		val<<=8
		val|=logAndWrite($30 << 24 | i << 8) & $ff

	return val

PUB readFuse
	return logAndWrite($50 << 24) & $ff

PUB writeFuse(val)
	logAndWrite($aca0 << 16 | (val & $ff))
	waitReady
		
PUB readFuseHigh
	return logAndWrite($5808 << 16) & $ff

PUB writeFuseHigh(val)
	logAndWrite($aca8 << 16 | (val & $ff))
	waitReady
		
PUB readFuseExtended
	return logAndWrite($5008 << 16) & $ff

PUB writeFuseExtended(val)
	logAndWrite($aca4 << 16 | (val & $ff))
	waitReady
		
PUB readCalibration
	return logAndWrite($38 << 24) & $ff

PUB waitReady | status
	status:=1

	repeat until status==0
		'waitcnt(cnt + clkfreq >> 6)
		status:=logAndwrite($f0 << 24)&1
		

DAT
word
program     byte    $0E, $C0, $15, $C0, $14, $C0, $13, $C0, $12, $C0, $11, $C0, $10, $C0, $0F, $C0
			byte	$0E, $C0, $0D, $C0, $0C, $C0, $0B, $C0, $0A, $C0, $09, $C0, $08, $C0, $11, $24
			byte	$1F, $BE, $CF, $E5, $D2, $E0, $DE, $BF, $CD, $BF, $1E, $D0, $31, $C0, $E8, $CF
			byte	$CF, $93, $DF, $93, $00, $D0, $CD, $B7, $DE, $B7, $0F, $C0, $1A, $82, $19, $82

			byte	$06, $C0, $29, $81, $3A, $81, $2F, $5F, $3F, $4F, $3A, $83, $29, $83, $29, $81
			byte	$3A, $81, $29, $33, $31, $05, $A8, $F3, $81, $50, $81, $11, $EF, $CF, $0F, $90
			byte	$0F, $90, $DF, $91, $CF, $91, $08, $95, $B8, $9A, $C0, $9A, $8A, $EF, $E0, $DF
			byte	$8A, $EF, $DE, $DF, $8A, $EF, $DC, $DF, $8A, $EF, $DA, $DF, $18, $BA, $8A, $EF

			byte	$D7, $DF, $8A, $EF, $D5, $DF, $8A, $EF, $D3, $DF, $8A, $EF, $D1, $DF, $ED, $CF
			byte	$F8, $94, $FF, $CF
			long	0, 0, 0, 0,0,0,0, 0,0,0,0
