CON
	_clkmode		= xtal1 + pll16x			' Feedback and PLL multiplier
	_xinfreq		= 5_000_000

	speedOfSoundMMPerSec=343200
OBJ

	nok: "MyNokia5510"
	'pst: "Parallax Serial Terminal"

VAR
	long lcdBuffer[128]

PUB start | clksPerMM, led

	dira[8]~~
	dira[9]~
	led:=255

	'pst.start(115200)
	nok.start(7,6,5,4,3,2,@lcdBuffer)

	clksPerMM:=clkfreq/speedOfSoundMMPerSec

	frqa:=1
	ctra:=%0_01000_000_00000000_000000_000_001001

	frqb:=1
	ctrb:=%0_00100_000_00000000_000000_000_001000

	repeat
		phsa:=0
		repeat 4
			phsb:=-1200
			!led
			led&=$ff
			'nok.setLED(led)

			waitcnt(cnt+clkfreq>>2)

		nok.scrollTextDown
		nok.writeDec(0,(phsa/clksPerMM)>>3)

