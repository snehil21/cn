set ns [new Simulator]
set tf [open 4.tr w]
$ns trace-all $tf
set nf [open 4.nam w]
$ns namtrace-all $nf
$ns color 1 Blue
set n0 [$ns node]
set n1 [$ns node]
$n0 label "Server"
$n1 label "Client"
$ns duplex-link $n0 $n1 0.3Mb 10ms DropTail
set tcp [new Agent/TCP]
$ns attach-agent $n0 $tcp
$tcp set packetSize_ 1500
set sink [new Agent/TCPSink]
$ns attach-agent $n1 $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 0.1 "$ftp start"
$ns at 12.0 "finish"
proc finish {} {
 global ns tf nf cwind
 $ns flush-trace
 close $tf
 close $nf
 exec nam 4.nam &
 exec awk -f 4transfer.awk 4.tr &
 exec awk -f 4convert.awk 4.tr > convert.tr &
 exec xgraph convert.tr -geometry 800*400 -t "bytes_client" -x "time" -y "bytes_in_bps" &
 exit 0
}
$ns run

BEGIN {
count=0; 
time=0;
total_bytes_sent =0; 
total_bytes_received=0;
}
{
if ( $1 == "r" && $4 == 1 && $5 == "tcp")
total_bytes_received += $6;
if($1 == "+" && $3 == 0 && $5 == "tcp")
total_bytes_sent += $6;
}
END {
system("clear");
printf("\n Transmission time required to transfer the file is %f",$2); 
printf("\n Actual data sent from the server is %f
Mbps",(total_bytes_sent)/1000000);
printf("\n Data Received by the client is %f 
Mbps\n",(total_bytes_received)/1000000);
}
ex5convert.awk
# AWK Script to convert the downloaded file into MB 
BEGIN {
count=0; 
time=0;
}
{
if ( $1 == "r" && $4 == 1 && $5 == "tcp")
{
count += $6; 
time=$2;
printf("\n%f\t%f",time,(count)/1000000);
}
}
END {
}