FROM ubuntu:18.04

RUN apt-get update && \
    apt-get install -y build-essential git cmake software-properties-common \
                       zlib1g-dev libevent-dev

RUN apt-get install -y iperf 
RUN apt-get install -y ufw
RUN ufw disable
RUN ufw status verbose

RUN add-apt-repository ppa:gophers/archive && \
    apt-get update && \
    apt-get install -y golang-1.9-go && \
    cp /usr/lib/go-1.9/bin/go* /usr/bin/.

RUN uname -r

RUN mkdir /certs
RUN mkdir /src
WORKDIR /src

RUN mkdir /src/lsquic
COPY ./ /src/lsquic/
COPY ./certs /certs

RUN git clone https://boringssl.googlesource.com/boringssl && \
    cd boringssl && \
    git checkout 49de1fc2910524c888866c7e2b0db1ba8af2a530 && \
    cmake . && \
    make

RUN cd /src/lsquic && \
    cmake -DBORINGSSL_DIR=/src/boringssl . && \
    make

RUN cd lsquic && make test && cp http_client /usr/bin/ && cp http_server /usr/bin
