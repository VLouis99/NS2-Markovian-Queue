# To generate a new figure, modify the title, 
# xlabel and ylabel and comment/uncomment the adequate instructions.

set title 'Average Delay as a functon of b with limited queue'
set xlabel '{b}'
set ylabel 'R'
set style line 1 lt 2 lw 2 pt 3 ps 0.5

set term postscript eps enhanced color "Times-Roman" 22
set output 'Average_b_delay_changed_queue.eps'

# plot the 7th field of the file res1 as a function of the 1st field

plot "res1_changedqueue" using 1:8 t "R" w lp 





