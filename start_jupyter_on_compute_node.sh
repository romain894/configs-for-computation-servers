#!/usr/bin/env bash
GPU="V100"
N_GPU="1"
MAX_RUN_TIME="2:00:00"

# This script is made to be run from the login node. It will then launch a Jupyter Lab instance on a compute node.

PROJECT_ID="NAISS2024-XX-XXX"
USERNAME="myusername"
LOGIN_NODE="alvis2.c3se.chalmers.se"

# Select a random port on the login node from 8888 to 8988:
FREE_PORT_LOGIN=`comm -23 <(seq "8888" "8988" | sort) <(ss -Htan | awk '{print $4}' | cut -d':' -f2 | sort -u) | shuf -n 1`
# echo "JupyterLab URL: https://proxy.c3se.chalmers.se:${FREE_PORT_LOGIN}/`hostname`/"

# Launch the notebook on the compute node:
srun -A ${PROJECT_ID} -p alvis -t ${MAX_RUN_TIME} --gpus-per-node=${GPU}:${N_GPU} --pty run_jupyter.sh ${FREE_PORT_LOGIN} ${USERNAME} ${LOGIN_NODE}
