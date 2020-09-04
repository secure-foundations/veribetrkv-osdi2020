#!/bin/bash

##### This script runs verification and benchmarks on the veribetrkv-dynamic-frames
##### codebase.  It creates a volume, `veribetrkv-dynamic-frames-build` so that
##### build data persists across docker runs.

if [ -z "$1" ]; then
  echo "Usage: ./run-experiments-in-docker-dynamic-frames.sh OUTDIR"
  echo "    OUTDIR: Directory where build results will go."
  echo "        This directory is mounted into the container so that"
  echo "        build results will persist across runs."
  echo "        This is also where database images will be built"
  echo "        during benchmarks."
  exit 1
fi

set -e

# demand absolute path
OUTDIR=`realpath "$1"`

set -x

##### Build executables.

docker run --rm \
  -v $OUTDIR:/home/root/veribetrkv-dynamic-frames/build \
  -w=/home/root/veribetrkv-dynamic-frames \
  veribetrkv-artifact:latest \
  make elf ycsb

##### Run verification. Will take several hours:
##### use as many cores as you can.

docker run --rm \
  -v $OUTDIR:/home/root/veribetrkv-dynamic-frames/build \
  -w=/home/root/veribetrkv-dynamic-frames \
  veribetrkv-artifact:latest \
  make status -j4

##### Run key-value store benchmarks with an appropriate memory limit.

# Veribetrkv benchmarks

docker run --rm \
  -v $OUTDIR:/home/root/veribetrkv-dynamic-frames/build \
  -w=/home/root/veribetrkv-dynamic-frames \
  --memory=2g \
  veribetrkv-artifact:latest \
  make build/VeribetrfsYcsb.data

# RocksDB benchmarks

docker run --rm \
  -v $OUTDIR:/home/root/veribetrkv-dynamic-frames/build \
  -w=/home/root/veribetrkv-dynamic-frames \
  --memory=2g \
  veribetrkv-artifact:latest \
  make build/RocksYcsb.data

# BerkeleyDB benchmarks

docker run --rm \
  -v $OUTDIR:/home/root/veribetrkv-dynamic-frames/build \
  -w=/home/root/veribetrkv-dynamic-frames \
  --memory=2g \
  veribetrkv-artifact:latest \
  make build/BerkeleyYcsb.data

##### Run benchmarks of our verified in-memory data structures.
##### We DO NOT set a memory limit here.

# Hash table

docker run --rm \
  -v $OUTDIR:/home/root/veribetrkv-dynamic-frames/build \
  -w=/home/root/veribetrkv-dynamic-frames \
  veribetrkv-artifact:latest \
  make build/mutable-map-benchmark.csv

# In-memory B-tree

docker run --rm \
  -v $OUTDIR:/home/root/veribetrkv-dynamic-frames/build \
  -w=/home/root/veribetrkv-dynamic-frames \
  veribetrkv-artifact:latest \
  make build/mutable-btree-benchmark.csv

# Run line-counting routines and put it all together into a pdf.
# Note: you can skip all of the above steps and just run this, if you want,
# since everything above is a dependency via make, but if you do that,
# you won't get the best docker config for each step.

docker run --rm \
  -v $OUTDIR:/home/root/veribetrkv-dynamic-frames/build \
  -w=/home/root/veribetrkv-dynamic-frames \
  veribetrkv-artifact:latest \
  make build/osdi20-artifact/paper.pdf
