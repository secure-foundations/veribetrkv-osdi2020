Welcome to the VeriBetrKV (also known as VeriSafeKV) artifact for our OSDI'20 submission,

 Storage Systems are Distributed Systems (So Verify Them That Way!)

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

You can either download the GitHub release, `osdi2020-artifact`, and load the image with

    docker load -i veribetrkv-artifact.tgz

or build it yourself with,

    cd docker
    docker build -t veribetrkv-artifact .

# Evaluating this artifact

To fully evaluate the artifact, our benchmark suite needs to be run twice, once for
the 'dynamic-frames' version and once for the 'linear' version. 

Furthermore, some of these benchmarks are very sensitive to memory capacity and
to the type of underlying hardware. Thus, to obtain results similar to the ones in our
paper, the right memory configuration must be used.

However, some of the other operations require higher memory limits.

Therefore, the recommended way to evaluate this artifact is
to run these scripts (from outside the Docker container).

    ./run-experiments-in-docker-dynamic-frames.sh results-df
    ./run-experiments-in-docker-linear.sh         results-linear

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

The second script will do the same, but for the 'linear' version.

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
