# Set output properties for throughput (X)
set title 'Output Rate (X) as a Function of {/Symbol l}'
set xlabel '{/Symbol l}'
set ylabel 'Output Rate (X)'

set term postscript eps enhanced color "Times-Roman" 22
set output 'Throughput_X.eps'

set style line 1 lc rgb 'red' pt 7 ps 1.5 lw 2 lt 1  # Red for CBR, with point type 7, point size 1.5, line width 2
set style line 2 lc rgb 'green' pt 5 ps 1.5 lw 2 lt 1 # Green for ON/OFF, with point type 5, point size 1.5, line width 2
set style line 3 lc rgb 'blue' pt 9 ps 1.5 lw 2 lt 1  # Blue for Poisson, with point type 9, point size 1.5, line width 2

# Use these line styles in the plot command
plot "res1CBR" using 1:7 with linespoints linestyle 1 title 'X CBR', \
     "res1_onofffinal" using 1:7 with linespoints linestyle 2 title 'X ON/OFF', \
     "res1_poisson" using 1:7 with linespoints linestyle 3 title 'X Poisson', \
     "theoretical_MM1K.dat" using 1:2 with lines linestyle 4 title 'X Theoretical MM1K'

