set ns [new Simulator]

# The trace file: Necessary for computing the performance metrics
$ns trace-all [open /tmp/out.tr w]

# nam: You add here and elsewhere any commands necessary for nam animation
# nam trace file for network animations:
$ns namtrace-all [open /tmp/animation w]
$ns color 1 Blue


# nam: End of commands for nam

# The Inputs : b (input rate) in kbit/s
#              p (loss ratio)

set seed 0 
if {$argc > 0 } { set b [lindex $argv 0] }
if {$argc > 1 } { set p [lindex $argv 1] }
puts "Simulation with  b = $b ,  p = $p"


puts "Running simulation with b = $b and p = $p"


# Configuration of random number generator
set seed 21113944
global defaultRNG
$defaultRNG seed ; # The seed of the generator
                   # MUST MUST be your student id <<<<<<<<<<<




# Manual routung
$ns rtproto Manual

##############################################################

# Here you create the topology of your network model (nodes and links)

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
$ns queue-limit $n(0) $n(1) 1000000
$ns queue-limit $n(1) $n(2) 1000000
$ns queue-limit $n(1) $n(3) 1000000
$ns queue-limit $n(3) $n(4) 1000000
$ns queue-limit $n(4) $n(5) 1000000
$ns queue-limit $n(4) $n(6) 1000000


# Add here all entries of routing tables
# For the path 0-1-2-3-4-5
$n(0) add-route [$n(1) id] [$link01 head]
$n(1) add-route [$n(2) id] [$link12 head]
$n(2) add-route [$n(3) id] [$link23 head]
$n(3) add-route [$n(4) id] [$link34 head]
$n(4) add-route [$n(5) id] [$link45 head]

$n(0) add-route [$n(1) id] [$link01 head]
$n(1) add-route [$n(3) id] [$link13 head]
$n(4) add-route [$n(6) id] [$link46 head]







# Add here the uniform losses over links (1)--(2) and (2)--(3)
set losses [new ErrorModel]
$losses unit pkt
$losses set rate_ 1.0*$p  ;# Set loss probability to p
$losses ranvar [new RandomVariable/Uniform]


set nullAgent [new Agent/Null]  ;# Create a null agent to handle dropped packets
$ns attach-agent $n(2) $nullAgent  ;# Attach the null agent to a node
$ns attach-agent $n(3) $nullAgent 
$losses drop-target $nullAgent  ;# Assign the null agent as the drop target for the losses

# Inserting the losses into the specific links
$ns lossmodel $losses $n(1) $n(2)
$ns lossmodel $losses $n(2) $n(3)


# Create here agents for the UDP transport layer
#Creating the first Poisson Process
set udp1 [new Agent/UDP]
$udp1 set packetSize_ 1000
$udp1 set fid_ 1
$ns attach-agent $n(0) $udp1

set null1 [new Agent/Null]
$ns attach-agent $n(5) $null1
$ns connect $udp1 $null1


# Create here agents for the UDP transport layer
set udp2 [new Agent/UDP]
$udp2 set packetSize_ 1000
$udp2 set fid_ 2
$ns attach-agent $n(0) $udp2

set null2 [new Agent/Null]
$ns attach-agent $n(5) $null2
$ns connect $udp2 $null2




# Add here traffic generators for the application layer (Poisson) Through On-Off
set poisson1 [new Application/Traffic/Exponential]
$poisson1 attach-agent $udp1

set poisson2 [new Application/Traffic/Exponential]
$poisson2 attach-agent $udp2




# Poisson Traffic (Obtained from an ON/OFF Exponential traffic)
$poisson1 set rate_ 1000Mb     # To ensure sending one packet
$poisson1 set burst_time_ 0.0  # during the zero ON period
$poisson1 set idle_time_ [expr {1.0 / (32.0 / $b)}] # lambda in packets per second, adjusted expression
$poisson1 set packetSize_ 1000

$poisson2 set rate_ 1000Mb     # To ensure sending one packet
$poisson2 set burst_time_ 0.0  # during the zero ON period
$poisson2 set idle_time_ [expr {1.0 / (32.0 / (3 * $b))}] # lambda in packets per second, adjusted expression
$poisson2 set packetSize_ 1000



# Schedule here when to start sending traffic packets (at t=0)
$ns at 0.01 "$poisson1 start"
$ns at 0.01 "$poisson2 start"

# $ns at 10000.00 "$poisson stop" # no need to stop





# Schedule here when to stop the sending of traffic packets (at t=10000)
$ns at 10000.00 "$poisson1 stop"
$ns at 10000.00 "$poisson2 stop"



##############################################################

# Now stop the simulation
$ns at 10000.1 "$ns halt"

# Run the simulation
puts -nonewline "Starting ... "; flush stdout
$ns run
puts "End."
# The simulation is finished
