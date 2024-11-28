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
    User myusername

Host alvis2
    HostName alvis2.c3se.chalmers.se
    Port 22
    User myusername
```

Change the username `myusername` by your own username.

## Working directory

It is strongly advised to not work in your home directory: the storage is slow and building you container image there will result in poor performances.

Instead of the home directory, you should use the Mimer storage for both your code, container image and data.
During the following step, we will assume that you are running the commands from a directory located on Mimer.

## Setup the container (Apptainer)

### Build your own image

First we are going to configure the image needed to run our jobs in containers. We need to log in `alvis1.c3se.chalmers.se` with SSH.

We are going to compile our own container image based in the definition in `python_jupyter_cuda_tensorflow.def`

You can run the following command to build the image:
```bash
./build_container.sh
```

Note that if you need other python packages, those need to be added in `requirements.txt` before building the image.

### Alternative: pull an existing image

In the example we are going to use the Docker image [romain894/bert_topic_modeling:latest](https://hub.docker.com/repository/docker/romain894/bert_topic_modeling) built from [this project](https://github.com/romain894/openalex-bert-topic-modeling).

Download an convert the Docker image on the cluster to an Apptainer image:

```bash
apptainer pull python_jupyter_cuda_tensorflow.sif docker://romain894/bert_topic_modeling:latest
```

### Test the image

Test that the image is working with the GPU drivers:

```bash
apptainer exec --nv python_jupyter_cuda_tensorflow.sif nvidia-smi
```

As we are logged in alvis1, running this command should show the 4 Tersla T4 GPU available in this node.

## Run the Jupyter Notebook

Documentation: [https://www.c3se.chalmers.se/documentation/](https://www.c3se.chalmers.se/documentation/)

Log in to Alvis2:

```bash
ssh alvis2
```

Add the files `start_jupyter_on_compute_node.sh` and `run_notebook.sh`.

Make sure the files mode allow running them:

```bash
chmod +x start_jupyter_on_compute_node.sh run_jupyter
```

You can now start your notebook:

```bash
./start_jupyter_on_compute_node.sh
```

In another terminal, create the SSH tunnelling with the command idicated when you run the script, it should look like that:

```bash
ssh -L 8899:localhost:8928 myusername@alvis2.c3se.chalmers.se ssh -L 8928:localhost:8899 -N myusername@alvis2-03
```

You can now access Jupyter Lab in your local web browser!

Romain THOMAS 2024
