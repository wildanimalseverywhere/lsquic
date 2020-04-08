FROM ubuntu:18.04

RUN apt-get update && \
    apt-get install -y build-essential git cmake software-properties-common \
                       zlib1g-dev libevent-dev

RUN add-apt-repository ppa:gophers/archive && \
    apt-get update && \
    apt-get install -y golang-1.9-go && \
    cp /usr/lib/go-1.9/bin/go* /usr/bin/.

RUN uname -r
RUN sysctl net.ipv4.tcp_available_congestion_control
RUN cd /tmp/
RUN wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.4.13/linux-headers-5.4.13-050413_5.4.13-050413.202001171431_all.deb
RUN wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.4.13/linux-headers-5.4.13-050413-generic_5.4.13-050413.202001171431_amd64.deb
RUN wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.4.13/linux-headers-5.4.13-050413-lowlatency_5.4.13-050413.202001171431_amd64.deb
RUN wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.4.13/linux-image-unsigned-5.4.13-050413-generic_5.4.13-050413.202001171431_amd64.deb
RUN wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.4.13/linux-image-unsigned-5.4.13-050413-lowlatency_5.4.13-050413.202001171431_amd64.deb
RUN wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.4.13/linux-modules-5.4.13-050413-generic_5.4.13-050413.202001171431_amd64.deb
RUN wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.4.13/linux-modules-5.4.13-050413-lowlatency_5.4.13-050413.202001171431_amd64.deb
RUN dpkg -i *.deb
RUN reboot
RUN sysctl net.ipv4.tcp_available_congestion_control

RUN mkdir /src
WORKDIR /src

RUN mkdir /src/lsquic
COPY ./ /src/lsquic/

RUN git clone https://boringssl.googlesource.com/boringssl && \
    cd boringssl && \
    git checkout 49de1fc2910524c888866c7e2b0db1ba8af2a530 && \
    cmake . && \
    make

RUN cd /src/lsquic && \
    cmake -DBORINGSSL_DIR=/src/boringssl . && \
    make

RUN cd lsquic && make test && cp http_client /usr/bin/ && cp http_server /usr/bin
