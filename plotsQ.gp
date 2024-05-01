# Set output properties for average number of clients (Q)
set title 'Average Number of Clients (Q) as a Function of {/Symbol l}'
set xlabel '{/Symbol l}'
set ylabel 'Average Number of Clients (Q)'

set term postscript eps enhanced color "Times-Roman" 22
set output 'AverageNumberOfClients_Q.eps'

set style line 1 lc rgb 'red' pt 7 ps 1.5 lw 2 lt 1  # Red for CBR
set style line 2 lc rgb 'green' pt 5 ps 1.5 lw 2 lt 1 # Green for ON/OFF
set style line 3 lc rgb 'blue' pt 9 ps 1.5 lw 2 lt 1  # Blue for Poisson
set style line 4 lc rgb 'magenta' pt 11 ps 1.5 lw 2 lt 1 # Magenta for Theoretical MM1K, you can choose a different color if needed

# Use these line styles in the plot command
plot "res1CBR" using 1:10 with linespoints linestyle 1 title 'Q CBR', \
     "res1_onofffinal" using 1:10 with linespoints linestyle 2 title 'Q ON/OFF', \
     "res1_poisson" using 1:10 with linespoints linestyle 3 title 'Q Poisson', \
     "theoretical_MM1K.dat" using 1:4 with lines linestyle 4 title 'Q Theoretical MM1K'

