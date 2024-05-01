#  Create the main simulaton object that implements especially the event scheduler.
set ns [new Simulator]

# Trace file: 
$ns trace-all [open /tmp/out.tr w]

# nam trace file for network animations:
$ns namtrace-all [open /tmp/animation w]
$ns color 1 Blue

# Some input parameters: 
# the traffic rate and the random generator seed
set lambda 5 
set seed 0 
if {$argc > 0 } { set lambda [lindex $argv 0] }
if {$argc > 1 } { set seed [lindex $argv 1] }
puts "Simulation with  lambda = $lambda ,  seed = $seed"

global defaultRNG
$defaultRNG seed $seed; 

# Create nodes
set n(0) [$ns node]    ;$n(0) set X_ 30   ;$n(0) set Y_ 10 
set n(1) [$ns node]    ;$n(1) set X_ 40   ;$n(1) set Y_ 10
set n(2) [$ns node]    ;$n(2) set X_ 50   ;$n(2) set Y_ 10

# Create links
$ns simplex-link $n(0) $n(1) 512kb 100ms DropTail  ;$ns simplex-link-op $n(0) $n(1) label " 512kbits, 100ms"
$ns simplex-link $n(1) $n(2) 256kb 100ms DropTail  ;$ns simplex-link-op $n(1) $n(2) label " 256kbits, 100ms"

# Configure link queue limits 
$ns queue-limit $n(0) $n(1) 100   ;$ns simplex-link-op $n(0) $n(1) queuePos 0.5
$ns queue-limit $n(1) $n(2) 100   ;$ns simplex-link-op $n(1) $n(2) queuePos 0.5

# UDP
set udp [new Agent/UDP]
$udp set packetSize_ 1024     ;$udp set fid_ 1
$ns attach-agent $n(0) $udp
set null [new Agent/Null]
$ns attach-agent $n(2) $null
$ns connect $udp $null

set CBR [new Application/Traffic/CBR]
$CBR attach-agent $udp


# Setting CBR rate in bits per second
set bits_per_packet [expr $lambda * 1024 * 8]
$CBR set rate_ $bits_per_packet
$CBR set packetSize_ 1024


$ns at 0.01 "$CBR start" 
# $ns at 10000.00 "$CBR stop" # no need to stop

$ns at 10001.1 "$ns halt"
puts -nonewline "Running ...."; flush stdout
$ns run
puts " End."
puts "Trace file out.tr is in directory /tmp"
puts "Animation file animation is in directory /tmp"

