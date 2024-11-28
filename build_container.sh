#!/usr/bin/env bash

# Build the Apptainer container based on the definition in the file python_jupyter_cuda.def

apptainer build python_jupyter_cuda.sif python_jupyter_cuda.def
