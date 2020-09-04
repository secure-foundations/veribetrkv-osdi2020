Welcome to the VeriBetrKV (also known as VeriSafeKV) artifact for our OSDI'20 submission,

_Storage Systems are Distributed Systems (So Verify Them That Way!)_

This artifact is distributed as a Docker container based on an Ubuntu image and includes,

 * Two versions of the VeriBetrKV source tree, one with Dafny's standard 'dynamic frames'
   reasoning, and one with 'linear' reasoning.
 * A fork of the Dafny codebase, which supports:
    * Linear reasoning
    * C++ backend
 * All dependencies of Dafny
 * The YCSB benchmark suite
 * BerkeleyDB and RocksDB, for comparison purposes.

All source is distributed under their projects' respective licenses.

# Obtaining the Docker image

You have a choice of obtaining an image for SSD-optimized VeriBetrKV or
HDD-optimized VeriBetrKV. 

## Obtaining the HDD-optimized Docker image

You can either download the GitHub release, `veribetrkv-artifact-hdd`, and load the image with

    docker load -i veribetrkv-artifact-hdd.tgz

or build it yourself with,

    cd docker-hdd
    docker build -t veribetrkv-artifact-hdd .

## Obtaining the SSD-optimized Docker image

You can either download the GitHub release, `veribetrkv-artifact-ssd`, and load the image with

    docker load -i veribetrkv-artifact-ssd.tgz

or build it yourself with,

    cd docker-ssd
    docker build -t veribetrkv-artifact-ssd .

# Evaluating this artifact

There are two versions of Veribetrkv, one optimised for hdds and one optimized
for ssds. The only difference is the size of the B-epsilon tree nodes.

In our paper, SSD-reported numbers are done using the SSD-optimized version,
and HDD-reported numbers are done using the HDD-optimized version. (The exact hardware
specs we used can be found in Section 7.2 of our paper.)

We show commands for evaluating on hdds in this README. Replace `hdd` with `ssd`
to use the SSD-optimzed version.

To fully evaluate the artifact on the chosen hardware (HDD or SSD),
our benchmark suite needs to be run twice, once for
the 'dynamic-frames' version and once for the 'linear' version. 

Furthermore, some of these benchmarks are very sensitive to the available memory capacity.
Thus, to obtain to results similar to the ones in our paper,
the right memory configurations must be used for certain experiments.

On the other hand, some of the other operations will fail if they
are not given _enough_ memory.

Therefore, the recommended way to evaluate this artifact is
to run these scripts (from outside the Docker container).

    ./run-experiments-in-docker-dynamic-frames.sh results-df     hdd
    ./run-experiments-in-docker-linear.sh         results-linear hdd

The first script will launch Docker containers and,

 * Run Dafny verification on the VeriBetrKV codebase.
 * Run all benchmarks with correctly configured memory limits.
 * The containers will bind the build directory within the container,
   `/home/root/veribetrkv-dynamic-frames/build/`
   to the host directory supplied as the command line argument.
   You'll be able to see the results here.
 * When benchmarks (VeriBetrKV, BerekeleyDB, and RocksDB) run, the
   database images will also be saved to this directory. _If you want to run
   the experiments on a particular device, be sure to supply a directory
   on that device._
 * When complete, it will summarize all results into a file,
   `results-df/artifact/paper.pdf`.

The second script will do the same, but for the 'linear' version. (The only other
difference is that it will not re-run the BerkeleyDB or RocksDB experiments
again, as it would be redundant to run them twice. Those two experiments
are not affected by changed to VeriBetrKV source code.)
It will likewise summarize all results into a file, `results-linear/artifact/paper.pdf`.

Together, these two output pdfs should reproduce the results from our paper.

# More detailed explanation

If you want to explore the container, you can launch it in the background with,

    docker run --name veribetrkv-c -dit veribetrkv-artifact /bin/bash

and get shell it in with,

    docker exec -it veribetrkv-c /bin/bash

The home directory in the container contains three directories,

 * `dafny/dafny` contains the Dafny source code, with our modifications.
 * `veribetrkv-dynamic-frames` contains the VeriBetrKV source tree using
   Dafny's traditional 'dynamic frames' reasoning.
 * `veribetrkv-linear` contains the VeriBetrKV source tree updated to use
   linear reasoning in some places.

Inside either one of the two veribetrkv directories, you can:

 * Build our code.
 * Verify our code.
 * Run benchmarks.
 * Compile a summary pdf with all the results.

Strictly speaking, you can do all this with a single `make` invocation, but
as explained above, some of the benchmarks are intended for different memory
configurations.

Here's a breakdown of what you can do (from either the `veribetrkv-dynamic-frames`
directory of the `veribetrkv-linear` directory):

 * `make elf` - Builds a standalone binary `./build/Veribetrfs` with a few (tiny)
    built-in benchmarks.
 * `make ycsb` - Builds binaries for YCSB benchmarks
 * `make build/VeribetrfsYcsb.data` - Run YCSB benchmarks for VeriBetrKV.
 * `make build/RocksYcsb.data` - Run YCSB benchmarks for RocksDB.
 * `make build/BerkeleyYcsb.data` - Run YCSB benchmarks for BerkeleyDB.
 * `make status -j4` - Run verification on all code. When it's finished, check
    `build/Impl/Bundle.i.status.pdf` for a summary of the results. Green means
    successful verification.
 * `make build/mutable-map-benchmark.data` - Run microbenchmark for in-memory hash table.
 * `make build/mutable-btree-benchmark.data` - Run microbenchmark for in-memory B-tree.
 * `make build/verification-times.pdf` - Build a summary pdf of verification times.
 * `make` - (Depends on all of the above) Produce a file `osdi20-artifact/paper.pdf`.
