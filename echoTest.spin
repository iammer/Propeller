CON
	_xinfreq = 5_000_000
	_clkmode = xtal1 + pll16x

	speedOfSoundMMPerSec=343200

OBJ

	pst: "Unix Serial Terminal"

VAR

PUB start | clksPerMM, avg, dist

	clksPerMM:=clkfreq/speedOfSoundMMPerSec

	dira[8]~~
	dira[9]~

	pst.start(115200)
	pst.str(string("Echo Tester"))
	pst.newline

	frqa:=1
	ctra:=%0_01000_000_00000000_000000_000_001001

	frqb:=1
	ctrb:=%0_00100_000_00000000_000000_000_001000

	repeat
		phsa:=0
		repeat 4
			phsb:=-1200

			waitcnt(cnt+clkfreq>>2)

		pst.dec((phsa/clksPerMM)>>3)
		pst.newline

		
