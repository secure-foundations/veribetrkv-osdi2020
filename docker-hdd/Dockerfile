FROM ubuntu:latest

# https://askubuntu.com/questions/909277/avoiding-user-interaction-with-tzdata-when-installing-certbot-in-a-docker-contai
ARG DEBIAN_FRONTEND=noninteractive

# Load mono keys so we can install PPA to get a recent version (ubuntu ships
# with 4.x; we want 6.x)
RUN apt-get update
RUN apt-get install -y ca-certificates gnupg2
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A6A19B38D3D831EF

COPY mono-official-stable.list /etc/apt/sources.list.d/

RUN apt-get update
RUN apt-get install -y mono-runtime mono-mcs mono-devel git make wget unzip
RUN apt-get install -y vim emacs
RUN apt-get install -y python3-pip time
RUN apt-get install -y clang
RUN apt-get install -y libc++-dev
RUN apt-get install -y libc++abi-dev
RUN apt-get install -y libdb5.3-stl-dev
RUN apt-get install -y libdb-dev libdb++-dev
RUN apt-get install -y sloccount graphviz
RUN apt-get install -y texlive texlive-pictures

RUN pip3 install toposort
RUN pip3 install numpy
RUN pip3 install matplotlib

COPY install-dafny.sh /home/root/install-dafny.sh
WORKDIR /home/root
RUN ./install-dafny.sh
RUN rm ./install-dafny.sh
ENV PATH="/home/root/dafny/bin/:${PATH}"

COPY src/veribetrkv-dynamic-frames /home/root/veribetrkv-dynamic-frames
COPY src/veribetrkv-linear /home/root/veribetrkv-linear

RUN ln -s /home/root/dafny /home/root/veribetrkv-dynamic-frames/.dafny
RUN ln -s /home/root/dafny /home/root/veribetrkv-linear/.dafny

WORKDIR /home/root/veribetrkv-dynamic-frames
RUN make elf
RUN make build/VeribetrfsYcsb
RUN make build/KyotoYcsb
RUN make build/BerkeleyYcsb
RUN make build/RocksYcsb
RUN make build/bench/run-mutable-map
RUN make build/bench/run-mutable-btree

WORKDIR /home/root/veribetrkv-linear
RUN ln -s /home/root/veribetrkv-dynamic-frames/vendor /home/root/veribetrkv-linear/vendor
RUN make ycsb
RUN make elf
RUN make build/bench/run-mutable-map
RUN make build/bench/run-mutable-btree

WORKDIR /home/root
