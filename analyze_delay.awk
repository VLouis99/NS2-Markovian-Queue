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
    time = $2 + 0;  // Ensure numerical operations by forcing type
    node_1 = $3;
    node_2 = $4;
    traffic = $5;
    flow_id = $8;
    node_1_address = $9;
    node_2_address = $10;
    seq_no = $11;
    packet_id = $12 + 0;  // Ensure packet_id is treated as a number

    simtime = time;
    if (packet_id > highest_packet_id) {
        highest_packet_id = packet_id;
    }

    if (action == "+" && node_1 == 0) {
        nsent++;
        start_time[packet_id] = time;
        traffictype[packet_id] = traffic;
        meanNbClients += nclients * (time - lasttime);  
        nclients++;
        lasttime = time;
    }

    if (action == "r" && node_2 == 4) {
        end_time[packet_id] = time;
        meanNbClients += nclients * (time - lasttime);
        nclients--;
        lasttime = time;
    } else if (action == "d") {
        end_time[packet_id] = -1;
        meanNbClients += nclients * (time - lasttime);
        nclients--;
        ndrops++;
        lasttime = time;
    }
}

END {
    for (packet_id = 0; packet_id <= highest_packet_id; packet_id++) {
        start = start_time[packet_id];
        end = end_time[packet_id];
        if (start < end && end != -1) {
            nrecvd++;
            packet_duration += end - start;
            packet_duration2 += (end - start) * (end - start);
        }
    }

    if (nrecvd > 0) {
        delay = packet_duration / nrecvd;
        jitter = 0;  // Initialize jitter
        if (packet_duration2 / nrecvd > (delay * delay)) {
            jitter = sqrt((packet_duration2 / nrecvd) - (delay * delay));
        }
        xe = 1024 * 8 * nsent / (1000 * simtime);
        xs = 1024 * 8 * nrecvd / (1000 * simtime);
        meanNbClients /= simtime;

        printf("%f %d %d %d %f %f %f %f %f\n", simtime, nsent, nrecvd, ndrops, xe, xs, delay, jitter, meanNbClients);
    }
}

