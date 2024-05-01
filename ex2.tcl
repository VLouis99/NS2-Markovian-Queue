#Set the simulator

set ns [new Simulator]

 

#Opening the network animation

set namf [open wired2.nam w]

$ns namtrace-all $namf

 

#open the file for tracing

set tracef [open wired2.tr w]

$ns trace-all $tracef

 

#creation of wired nodes

set n0 [$ns node]

set n1 [$ns node]

set n2 [$ns node]

set n3 [$ns node]

 

#establish the links between the nodes with bandwidth and delay

$ns duplex-link $n0 $n1 2MB 1ms DropTail

$ns duplex-link $n1 $n2 2.5MB 1ms RED

$ns duplex-link $n2 $n3 2MB 1.5ms DropTail

$ns duplex-link $n3 $n1 12MB 10ms DropTail

 

#creating the Tcp source and sink agents

set tcp [new Agent/TCP]

set sink [new Agent/TCPSink]

 

#attach the agents to the corresponding nodes

$ns attach-agent $n0 $tcp

$ns attach-agent $n2 $sink

 

#create the FTP Traffic

set ftp [new Application/FTP]

$ftp attach-agent $tcp

 

$ns connect $tcp $sink

 

#start the traffic

$ns at 1.0 “$ftp start”

 

#end the simulation

$ns at 3.0 “finish”

 

proc finish {} {

global ns namftracef

$ns flush-trace

close $namf

close $tracef

exec nam wired2.nam &

exit 0

}

 

$ns run
