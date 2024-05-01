BEGIN {
        highest_packet_id = 0;
        nrecvd = 0;
        nsent = 0;
        ndrops = 0;
        simtime = 0;
        startsim = 0.01;
        meanNbClients = 0.0;
        nclients = 0;
        lasttime = startsim;
}

{
        action = $1;
        time = $2;
        node_1 = $3;
        node_2 = $4;
        traffic = $5;
        flow_id = $8;
        node_1_address = $9;
        node_2_address = $10;
        seq_no = $11;
        packet_id = $12;

        split($2, a, ".");
	time = a[1] "," a[2];
	simtime = time;
        if ( packet_id > highest_packet_id )
                highest_packet_id = packet_id;

        if ( action == "+" && node_1 == 0 ) {
                nsent++;
                start_time[packet_id] = time;
                traffictype[packet_id] = traffic;
                meanNbClients = 1.0*meanNbClients + 1.0*nclients*(time-lasttime);
                #printf("%d %f %f\n", nclients, nclients*(time-lasttime), meanNbClients);
                nclients++;
                lasttime = time;
        }
        if ( action != "d" ) {
                if ( action == "r" && node_2 == 2) {
                        end_time[packet_id] = time;
                        meanNbClients = 1.0*meanNbClients + 1.0*nclients*(time-lasttime);
                        #printf("%d %f %f\n", nclients, nclients*(time-lasttime), meanNbClients);
                        nclients--;
                        lasttime = time;
                }
        } else {
                meanNbClients = 1.0*meanNbClients + 1.0*nclients*(time-lasttime);
                #printf("%d %f %f\n", nclients, nclients*(time-lasttime), meanNbClients);
                nclients--;
                end_time[packet_id] = -1;
                ndrops++;
        }
}
END {
        for ( packet_id = 0; packet_id <= highest_packet_id; packet_id++ ) {
                start = start_time[packet_id];
                end = end_time[packet_id];
                if(start < end) {
                        nrecvd++;
                        packet_duration += end - start;
                        packet_duration2 += (end-start)^2;
                        #printf("%d %f\n", packet_id, end-start);
                }
        }
        if(nrecvd) {
                delay = packet_duration/nrecvd;
                if((packet_duration2/nrecvd)-(packet_duration/nrecvd)^2.0>0) {
                        jitter = sqrt((packet_duration2/nrecvd)-(packet_duration/nrecvd)^2.0);
                } else {
                        jitter = 0;
                }
                xe = 1.0*1024*8*nsent/(1000*simtime);
                xs = 1.0*1024*8*nrecvd/(1000*simtime);
                meanNbClients = 1.0*meanNbClients/simtime;
#SimTime NbOfSentPackets NbofRecvdPackets NbDrops InputRate OutputRate Delay Jitter
                printf("%f %d %d %d %f %f %f %f %f\n", simtime, nsent, nrecvd, ndrops, xe, xs, delay, jitter, meanNbClients);
        }
}




