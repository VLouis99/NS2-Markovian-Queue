#  Create the main simulaton object that implements especially the event scheduler.
set ns [new Simulator]

# Trace file: 
$ns trace-all [open /tmp/out.tr w]

# nam trace file for network animations:
$ns namtrace-all [open /tmp/animation w]
$ns color 1 Blue
$ns color 2 Red

# Some input parameters: 
# the traffic rate and the random generator seed

set seed 21113944 
if {$argc > 0 } { set b [lindex $argv 0] }
if {$argc > 1 } { set p [lindex $argv 1] }
puts "Simulation with  b = $b ,  p = $p"

global defaultRNG
$defaultRNG seed $seed; 


# Create nodes
set n(0) [$ns node]    ;$n(0) set X_ 30   ;$n(0) set Y_ 10
set n(1) [$ns node]    ;$n(1) set X_ 40   ;$n(1) set Y_ 10
set n(2) [$ns node]    ;$n(2) set X_ 45   ;$n(2) set Y_ 20
set n(3) [$ns node]    ;$n(3) set X_ 50   ;$n(3) set Y_ 10
set n(4) [$ns node]    ;$n(4) set X_ 60   ;$n(4) set Y_ 10 # Extra node for the packet limit on 3
set n(5) [$ns node]    ;$n(5) set X_ 70   ;$n(5) set Y_ 20 # Destination For First poisson process
set n(6) [$ns node]    ;$n(6) set X_ 70   ;$n(6) set Y_ 10 # For second poisson process


# Create links
$ns simplex-link $n(0) $n(1) 800kb 0ms DropTail  ;$ns simplex-link-op $n(0) $n(1) label " 800kbits"
$ns simplex-link $n(1) $n(2) 100kb 0ms DropTail  ;$ns simplex-link-op $n(1) $n(2) label " 100kbits"
$ns simplex-link $n(1) $n(3) 200kb 0ms DropTail  ;$ns simplex-link-op $n(1) $n(3) label " 200kbits"
$ns simplex-link $n(2) $n(3) 100kb 0ms DropTail  ;$ns simplex-link-op $n(2) $n(3) label " 100kbits"
$ns simplex-link $n(3) $n(4) 512kb 0ms DropTail  ;$ns simplex-link-op $n(3) $n(4) label " 512kbits limit 64 Packets"
$ns simplex-link $n(4) $n(5) 1000kb 0ms DropTail  ;$ns simplex-link-op $n(4) $n(5) label " Dummy link"
$ns simplex-link $n(4) $n(6) 1000kb 0ms DropTail  ;$ns simplex-link-op $n(4) $n(6) label " Dummy link"



#Defining Links to get head after
set link01 [$ns link $n(0) $n(1)]
set link12 [$ns link $n(1) $n(2)]
set link13 [$ns link $n(1) $n(3)]
set link23 [$ns link $n(2) $n(3)]
set link34 [$ns link $n(3) $n(4)]
set link45 [$ns link $n(4) $n(5)]
set link46 [$ns link $n(4) $n(6)]




# Configure here the size of all link queues ("infinite")
$ns queue-limit $n(0) $n(1) 5
$ns queue-limit $n(1) $n(2) 5
$ns queue-limit $n(1) $n(3) 5
$ns queue-limit $n(3) $n(4) 5
$ns queue-limit $n(4) $n(5) 5
$ns queue-limit $n(4) $n(6) 5


# Add here all entries of routing tables
$ns rtproto Manual

$n(0) add-route [$n(5) id] [$link01 head]
$n(0) add-route [$n(6) id] [$link01 head]

$n(1) add-route [$n(5) id] [$link12 head]
$n(1) add-route [$n(6) id] [$link13 head]

$n(2) add-route [$n(5) id] [$link23 head]


$n(3) add-route [$n(5) id] [$link34 head]
$n(3) add-route [$n(6) id] [$link34 head]

$n(4) add-route [$n(5) id] [$link45 head]
$n(4) add-route [$n(6) id] [$link46 head]




# Add here the uniform losses over links (1)--(2) and (2)--(3)


# Create an error model and configure it
set losses [new ErrorModel]
$losses set rate_ $p       ;
$losses unit pkt           ;
$losses ranvar [new RandomVariable/Uniform] ;
$losses drop-target [new Agent/Null] ;

set losses2 [new ErrorModel]
$losses2 set rate_ $p       ;
$losses2 unit pkt           ;
$losses2 ranvar [new RandomVariable/Uniform] ;
$losses2 drop-target [new Agent/Null] ;


# Attach the error model to specific links
$ns lossmodel $losses $n(1) $n(2)
$ns lossmodel $losses2 $n(2) $n(3)






# UDP
# Create here agents for the UDP transport layer
#Creating the first Poisson Process
set udp1 [new Agent/UDP]
$udp1 set packetSize_ 1000
$udp1 set fid_ 1
$ns attach-agent $n(0) $udp1

set null1 [new Agent/Null]
$ns attach-agent $n(5) $null1
$ns connect $udp1 $null1


set udp2 [new Agent/UDP]
$udp2 set packetSize_ 1000
$udp2 set fid_ 2
$ns attach-agent $n(0) $udp2


set null2 [new Agent/Null]
$ns attach-agent $n(6) $null2
$ns connect $udp2 $null2


# Add here traffic generators for the application layer (Poisson) Through On-Off
set poisson1 [new Application/Traffic/Exponential]
$poisson1 attach-agent $udp1

set poisson2 [new Application/Traffic/Exponential]
$poisson2 attach-agent $udp2



# Poisson Traffic (Obtained from an ON/OFF Exponential traffic)
$poisson1 set rate_ 1000Mb     # To ensure sending one packet
$poisson1 set burst_time_ 0.0  # during the zero ON period
$poisson1 set idle_time_ [expr 32.0 / $b ] # lambda in packets per second
$poisson1 set packetSize_ 1000


$poisson2 set rate_ 1000Mb     # To ensure sending one packet
$poisson2 set burst_time_ 0.0  # during the zero ON period
$poisson2 set idle_time_ [expr 32.0 / (3.0 * $b)] # lambda in packets per second
$poisson2 set packetSize_ 1000








# Schedule here when to stop the sending of traffic packets (at t=10000)
$ns at 0.01 "$poisson1 start" 
$ns at 10000.00 "$poisson1 stop"

$ns at 0.01 "$poisson2 start" 
$ns at 10000.00 "$poisson2 stop"

$ns at 10001.1 "$ns halt"
puts -nonewline "Running ...."; flush stdout

$ns run
puts " End."
puts "Trace file out.tr is in directory /tmp"
puts "Animation file animation is in directory /tmp"

