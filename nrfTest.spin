CON
	_xinfreq = 5_000_000
	_clkmode = xtal1 + pll16x

OBJ

	'pst: "Parallax Serial Terminal"

VAR

PUB start

	dira[16]~~
	repeat
		!outa[16]
		waitcnt(cnt+clkfreq >> 2)
		
