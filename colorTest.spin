CON
  _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
  _xinfreq        = 5_000_000
  _stack = ($3000 + $3000 + 100) >> 2   'accomodate display memory and stack

  x_tiles = 16
  y_tiles = 12

  paramcount = 14
  bitmap_base = $2000
  display_base = $5000
VAR
  long  tv_status     '0/1/2 = off/visible/invisible           read-only
  long  tv_enable     '0/? = off/on                            write-only
  long  tv_pins       '%ppmmm = pins                           write-only
  long  tv_mode       '%ccinp = chroma,interlace,ntsc/pal,swap write-only
  long  tv_screen     'pointer to screen (words)               write-only
  long  tv_colors     'pointer to colors (longs)               write-only
  long  tv_hc         'horizontal cells                        write-only
  long  tv_vc         'vertical cells                          write-only
  long  tv_hx         'horizontal cell expansion               write-only
  long  tv_vx         'vertical cell expansion                 write-only
  long  tv_ho         'horizontal offset                       write-only
  long  tv_vo         'vertical offset                         write-only
  long  tv_broadcast  'broadcast frequency (Hz)                write-only
  long  tv_auralcog   'aural fm cog                            write-only

  word  screen[x_tiles * y_tiles]
  long  colors[64]

  byte  colorStr[3]

OBJ

  tv: "TV"
  gr: "Graphics"
  rr: "RealRandom"

PUB start | i, dx, dy, k, random, color

  'start tv
  longmove(@tv_status, @tvparams, paramcount)
  tv_screen := @screen
  tv_colors := @colors
  tv.start(@tv_status)

  'init colors
  colors[0] :=$2b060c02
  repeat i from 1 to 63
    colors[i] := $00001010 * (i+4) & $F + $2B060C02

  'init tile screen
  repeat dx from 0 to tv_hc - 1
    repeat dy from 0 to tv_vc - 1
      screen[dy * tv_hc + dx] := display_base >> 6 + dy + dx * tv_vc

  rr.start

  'start and setup graphics
  gr.start
  gr.setup(16, 12, 128, 96, bitmap_base)

  colorStr[2]:=0
  color:=$0c

  repeat
    color+=$10
    color&=$ff

    colors[0]&=$ff00ffff
    colors[0]|=color<<16

    gr.clear
    gr.color(2)
    gr.box(-100,-100,200,200)

    gr.color(0)
    Hex(color,@colorStr)
    gr.text(-10,-10,@colorStr)
    gr.finish
    gr.copy(display_base)
    waitcnt(cnt+clkfreq)

PUB Hex(value,location) | i

  value <<= 24
  repeat i from 0 to 1
    byte[location][i] :=lookupz((value <-= 4) & $F : "0".."9", "A".."F")

DAT

tvparams                long    0               'status
                        long    1               'enable
                        long    %001_0101       'pins
                        long    %0000           'mode
                        long    0               'screen
                        long    0               'colors
                        long    x_tiles         'hc
                        long    y_tiles         'vc
                        long    10              'hx
                        long    1               'vx
                        long    0               'ho
                        long    0               'vo
                        long    0               'broadcast
                        long    0               'aura
