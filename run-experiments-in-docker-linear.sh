#!/bin/bash

##### This script runs verification and benchmarks on the veribetrkv-linear
##### codebase.  It creates a volume, `veribetrkv-linear-build` so that
##### build data persists across docker runs.

if [ "$#" -ne 2 ]; then
  echo "Usage: ./run-experiments-in-docker-linear.sh OUTDIR ssd|hdd"
  echo "    OUTDIR: Directory where build results will go."
  echo "        This directory is mounted into the container so that"
  echo "        build results will persist across runs."
  echo "        This is also where database images will be built"
  echo "        during benchmarks."
  echo "    ssd: Run in the docker artifact named veribetrkv-artifact-ssd."
  echo "    hdd: Run in the docker artifact named veribetrkv-artifact-hdd."
  exit 1
fi

set -e

# demand absolute path
OUTDIR=`realpath "$1"`
HARDWARE=$2

set -x

##### Build executables.

docker run --rm \
  -v $OUTDIR:/home/root/veribetrkv-linear/build \
  -w=/home/root/veribetrkv-linear \
  veribetrkv-artifact-$HARDWARE:latest \
  make elf ycsb

##### Run verification. Will take several hours:
##### use as many cores as you can.

docker run --rm \
  -v $OUTDIR:/home/root/veribetrkv-linear/build \
  -w=/home/root/veribetrkv-linear \
  veribetrkv-artifact-$HARDWARE:latest \
  make status -j4

##### Run key-value store benchmarks with an appropriate memory limit.

# Veribetrkv benchmarks

docker run --rm \
  -v $OUTDIR:/home/root/veribetrkv-linear/build \
  -w=/home/root/veribetrkv-linear \
  --memory=2g --memory-swappiness=0 \
  veribetrkv-artifact-$HARDWARE:latest \
  make build/VeribetrfsYcsb.data

# Skip the Rocks and Berekeley benchmarks here.
# They would be redundant with the same runs from
# the other script.

##### Run benchmarks of our verified in-memory data structures.
##### We DO NOT set a memory limit here.

# Hash table

docker run --rm \
  -v $OUTDIR:/home/root/veribetrkv-linear/build \
  -w=/home/root/veribetrkv-linear \
  veribetrkv-artifact-$HARDWARE:latest \
  make build/mutable-map-benchmark.csv

# In-memory B-tree

docker run --rm \
  -v $OUTDIR:/home/root/veribetrkv-linear/build \
  -w=/home/root/veribetrkv-linear \
  veribetrkv-artifact-$HARDWARE:latest \
  make build/mutable-btree-benchmark.csv

# Run line-counting routines and put it all together into a pdf.
# Note: you can skip all of the above steps and just run this, if you want,
# since everything above is a dependency via make, but if you do that,
# you won't get the best docker config for each step.

docker run --rm \
  -v $OUTDIR:/home/root/veribetrkv-linear/build \
  -w=/home/root/veribetrkv-linear \
  veribetrkv-artifact-$HARDWARE:latest \
  make build/osdi20-artifact/paper.pdf
