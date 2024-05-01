# Set output properties for mean response time (R)
set title 'Mean Response Time (R) as a Function of {/Symbol l}'
set xlabel '{/Symbol l}'
set ylabel 'Mean Response Time (R)'

set term postscript eps enhanced color "Times-Roman" 22
set output 'MeanResponseTime_R.eps'

set style line 1 lc rgb 'red' pt 7 ps 1.5 lw 2 lt 1  # Red for CBR
set style line 2 lc rgb 'green' pt 5 ps 1.5 lw 2 lt 1 # Green for ON/OFF
set style line 3 lc rgb 'blue' pt 9 ps 1.5 lw 2 lt 1  # Blue for Poisson
set style line 4 lc rgb 'magenta' pt 11 ps 1.5 lw 2 lt 1 # Magenta for Theoretical MM1K

# Use these line styles in the plot command for R
plot "res1CBR" using 1:8 with linespoints linestyle 1 title 'R CBR', \
     "res1_onofffinal" using 1:8 with linespoints linestyle 2 title 'R ON/OFF', \
     "res1_poisson" using 1:8 with linespoints linestyle 3 title 'R Poisson', \
     "theoretical_MM1K.dat" using 1:3 with lines linestyle 4 title 'R Theoretical MM1K'

