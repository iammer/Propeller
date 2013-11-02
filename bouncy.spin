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

  word points[24]
  word speeds[8]

CON

  xMin=0
  xMax=256
  yMin=0
  yMax=192

OBJ

  tv: "TV"
  gr: "Graphics"
  'rr: "RealRandom"

PUB start | i, j, random

  init

  random:=cnt
  repeat i from 0 to 7 step 2
    random?
    points[i]:=(random & $ff)
    points[i+1]:=(random >> 8) & $1f
    speeds[i]:=(random >> 16) & $1f + 1
    speeds[i+1]:=(random >> 21) & $1f + 1

  repeat
    gr.clear
    gr.colorwidth(1,0)

    gr.plot(points[6],points[7])

    repeat i from 0 to 7 step 2
      j:=i+1
      gr.line(points[i],points[j])
      points[i]+=speeds[i]
      if (points[i]<xMin or points[i]>xMax)
        -speeds[i]
        points[i]+=speeds[i]
        nextColor

      points[j]+=speeds[j]
      if (points[j]<yMin or points[j]>yMax)
       -speeds[j]
       points[j]+=speeds[j]
       nextColor

    repeat j from 1 to 2
      gr.color(j)

      gr.plot(points[j*8+6],points[j*8+7])
      repeat i from 0 to 7 step 2
        gr.line(points[j*8+i],points[j*8+i+1])

    repeat i from 15 to 0
      points[i+8]:=points[i]

    gr.copy(display_base)
    waitcnt(cnt+clkfreq/20)

PRI nextColor
  colors[0]:=(colors[0] + $1000) & $ffff + (colors[0] << 8) & $ffff0000

PRI init | i, j

  'start tv
  longmove(@tv_status, @tvparams, paramcount)
  tv_screen := @screen
  tv_colors := @colors
  tv.start(@tv_status)

  'init colors
  repeat i from 0 to 63
    colors[i] := $02380d02

  'init tile screen
  repeat i from 0 to tv_hc - 1
    repeat j from 0 to tv_vc - 1
      screen[j * tv_hc + i] := display_base >> 6 + j + i * tv_vc

  'rr.start

  'start and setup graphics
  gr.start
  gr.setup(16, 12, 0, 0, bitmap_base)


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
