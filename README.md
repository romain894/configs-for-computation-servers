# Setup to run Jupyter Lab on the Swedish academic PC-cluster Alvis

This documentation explains how to run a Docker image with Apptainer on the cluster.

The Docker image must contain Jupyter Lab and the necessary libraries (CUDA, python dependencies...).

Jupyter Lab will run as an interactive job in an Apptainer container and will be accessible though an SSH tunnelling.

## Configure SSH (optional)

Add your public SSH key on the server (you can do it with the [web portal](https://portal.c3se.chalmers.se)).

On your computer, add the following configuration in `~/.ssh/config`:
```bash
Host alvis1
    HostName alvis1.c3se.chalmers.se
    Port 22
    User romaint

Host alvis2
    HostName alvis2.c3se.chalmers.se
    Port 22
    User romaint
```

Change the username `romaint` by your own username.

## Setup the container (Apptainer)

First we are going to configure the image needed to run our jobs in containers. We need to log in `alvis1.c3se.chalmers.se` with SSH.

We use a Docker image [romain894/bert_topic_modeling:latest](https://hub.docker.com/repository/docker/romain894/bert_topic_modeling) built from [this project](https://github.com/romain894/openalex-bert-topic-modeling).

Download an convert the Docker image on the cluster to an Apptainer image:

```bash
apptainer pull bert_topic_modeling.sif docker://romain894/bert_topic_modeling:latest
```

Test that the image is working with the GPU drivers:

```bash
apptainer exec --nv bert_topic_modeling.sif nvidia-smi
```

As we are logged in alvis1, running this command should show the 4 Tersla T4 GPU available in this node.

## Run the Jupyter Notebook

Documentation: [https://www.c3se.chalmers.se/documentation/](https://www.c3se.chalmers.se/documentation/)

Log in to Alvis2:

```bash
ssh alvis2
```

Create a file `start_jupyter_on_compute_node.sh`:

```bash
nano start_jupyter_on_compute_node.sh
```

And put the following code in it:

```bash
#!/usr/bin/env bash
GPU="T4"
N_GPU="1"

# This script is made to be run from the login node. It will then launch a Jupyter Lab instance on a compute node.

PROJECT_ID="NAISS2024-22-923"
USERNAME="romaint"
LOGIN_NODE="alvis2.c3se.chalmers.se"

# Select a random port on the login node from 8888 to 8988:
FREE_PORT_LOGIN=`comm -23 <(seq "8888" "8988" | sort) <(ss -Htan | awk '{print $4}' | cut -d':' -f2 | sort -u) | shuf -n 1`
# echo "JupyterLab URL: https://proxy.c3se.chalmers.se:${FREE_PORT_LOGIN}/`hostname`/"

# Launch the notebook on the compute node:
srun -A ${PROJECT_ID} -p alvis --gpus-per-node=${GPU}:${N_GPU} --pty run_jupyter.sh ${FREE_PORT_LOGIN} ${USERNAME} ${LOGIN_NODE}
```

Save and quit (`ctrl` + `x`and then `y`). 

Create another file `run_notebook.sh`:

```bash
nano run_jupyter.sh
```

And put the following code in it:

```bash
#!/usr/bin/env bash

# This script is made to be run on a compute node with the following arguments:
FREE_PORT_LOGIN=$1
USERNAME=$2
LOGIN_NODE=$3

echo "Running on the host: `hostname`"

# Select a random port from 8888 to 8988:
FREE_PORT_COMPUTE=`comm -23 <(seq "8888" "8988" | sort) <(ss -Htan | awk '{print $4}' | cut -d':' -f2 | sort -u) | shuf -n 1`

# Display the command to create the SSH tunnelling:
echo "Create an SSH tunnelling in another terminal: ssh -L ${FREE_PORT_COMPUTE}:localhost:${FREE_PORT_LOGIN} ${USERNAME}@${LOGIN_NODE} ssh -L ${FREE_PORT_LOGIN}:localhost:${FREE_PORT_COMPUTE} -N ${USERNAME}@`hostname`"

# Launch jupyter lab with apptainer
apptainer exec --nv bert_topic_modeling.sif jupyter lab --no-browser --port=$FREE_PORT_COMPUTE
```

Save and quit (`ctrl` + `x`and then `y`). 

Change the files mode to allow running them:

```bash
chmod +x start_jupyter_on_compute_node.sh run_jupyter
```

You can now start your notebook:

```bash
./start_jupyter_on_compute_node.sh
```

In another terminal, create the SSH tunnelling with the command idicated when you run the script, it should look like that:

```bash
ssh -L 8899:localhost:8928 romaint@alvis2.c3se.chalmers.se ssh -L 8928:localhost:8899 -N romaint@alvis2-03
```

You can now access Jupyter Lab in your local web browser!

Romain THOMAS 2024