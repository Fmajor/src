#set term wxt dashed

#set term postscript landscape enhanced color "Text" 16

set term epscairo enhanced color dashed
#set output 'time.eps'


#set term pngcairo enhanced color
#set output 'time.png'
#set term xterm

set zeroaxis
set grid
set pointsize 1.0
set mxtics 10
set mytics 10
set macro
#set key autotitle columnhead


f(x0,x) = x0/x

####---------------macro 5 columns----------------
col7 = "u (column(x)*xscale):(column(1+shift)*yscale)   t columnhead(1+shift) w lp lc 1 lt 1 lw 4, \
     '' u (column(x)*xscale):(column(2+shift)*yscale)   t columnhead(2+shift) w lp lc 2 lt 1 lw 4, \
     '' u (column(x)*xscale):(column(3+shift)*yscale)   t columnhead(3+shift) w lp lc 3 lt 1 lw 4, \
     '' u (column(x)*xscale):(column(4+shift)*yscale)   t columnhead(4+shift) w lp lc 4 lt 1 lw 4, \
     '' u (column(x)*xscale):(column(5+shift)*yscale)   t columnhead(5+shift) w lp lc 5 lt 1 lw 4, \
     '' u (column(x)*xscale):(column(6+shift)*yscale)   t columnhead(6+shift) w lp lc 6 lt 1 lw 4, \
     '' u (column(x)*xscale):(column(7+shift)*yscale)   t columnhead(7+shift) w lp lc 7 lt 1 lw 4, \
         f(word(offset,2)*yscale,x) t '' w l lt 2 lw 2, \
         f(word(offset,3)*yscale,x) t '' w l lt 2 lw 2, \
         f(word(offset,4)*yscale,x) t '' w l lt 2 lw 2, \
         f(word(offset,5)*yscale,x) t '' w l lt 2 lw 2, \
         f(word(offset,6)*yscale,x) t '' w l lt 2 lw 2, \
         f(word(offset,7)*yscale,x) t '' w l lt 2 lw 2, \
         f(word(offset,8)*yscale,x) t '' w l lt 2 lw 2"


x = 1
shift = 1
xscale = 1
yscale = 1.0


####---------------plot total----------------------

filename = 'ttotal.0.txt'
offset = "`sed -n "2 p" ttotal.0.txt`"

set output 'ttotal.0.eps'

set logscale y
set logscale x 2
set xlabel 'N_{node}'
set ylabel 'T_{tot}/T_{NB} [s]'
set label 1 "Hydra (Garching) cluster specification per node:" at 1.1,51200
set label 2 " CPU: 20 Intel Ivy Bridge 2.8 GHz cores" at 1.1,25600
set label 3 " GPU: 2 Nvidia K20X" at 1.1,12800

plot [][2:100000] filename @col7

####---------------plot reg----------------------

reset
filename = 'treg.0.txt'
offset = "`sed -n "2 p" treg.0.txt`"

set output 'treg.0.eps'

set logscale y
set logscale x 2
set xlabel 'N_{node}'
set ylabel 'T_{reg}/T_{NB} [s]'

plot [][0.1:50000] filename @col7

####---------------plot irr----------------------

reset
filename = 'tirr.0.txt'
offset = "`sed -n "2 p" tirr.0.txt`"

set output 'tirr.0.eps'

set logscale y
set logscale x 2
set xlabel 'N_{node}'
set ylabel 'T_{irr}/T_{NB} [s]'

plot [][0.5:50000] filename @col7

set term wxt