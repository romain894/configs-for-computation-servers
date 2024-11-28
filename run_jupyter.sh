#!/usr/bin/env bash

# This script is made to be run on a compute node with the following arguments:
FREE_PORT_LOGIN=$1
USERNAME=$2
LOGIN_NODE=$3

echo "Running on the host: `hostname`"

# Select a random port from 8888 to 8988:
FREE_PORT_COMPUTE=`comm -23 <(seq "8888" "8988" | sort) <(ss -Htan | awk '{print $4}' | cut -d':' -f2 | sort -u) | shuf -n 1`

# Display the command to create the SSH tunneling:
echo "Create an SSH tunneling in another terminal: ssh -L ${FREE_PORT_COMPUTE}:localhost:${FREE_PORT_LOGIN} ${USERNAME}@${LOGIN_NODE} ssh -L ${FREE_PORT_LOGIN}:localhost:${FREE_PORT_COMPUTE} -N ${USERNAME}@`hostname`"

# Launch jupyter lab with apptainer
apptainer exec --nv python_jupyter_cuda.sif jupyter lab --no-browser --port=$FREE_PORT_COMPUTE
