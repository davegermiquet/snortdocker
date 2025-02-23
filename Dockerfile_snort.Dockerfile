FROM debian:bookworm-slim

MAINTAINER dgermiquet

RUN apt-get update && \
    apt-get install -y \
        git \
        python3-setuptools \
        python3-pip \
        python3-dev \
        wget \
        automake \
        build-essential \
        bison \
        flex \
        cmake \
        g++ \
        libhwloc-dev \
        libluajit-5.1-dev \
        libssl-dev \
        #libdumbnet-dev \
        libdumbnet-dev \
        libpcap-dev \
        libpcre2-dev\
        libpcre3-dev \
        libdumbnet-dev \
        zlib1g-dev \
        liblzma-dev \
        libnetfilter-queue1 \
        tcpdump \
        unzip \ 
        git \
	iproute2 \
        inetutils-ping \
        libmnl-dev


WORKDIR /opt

RUN git clone --depth 1 --branch 3.6.3.0 https://github.com/snort3/snort3.git snort
RUN git clone --depth 1 --branch v3.0.18 https://github.com/snort3/libdaq.git libdaq
# Set version variables for DAQ and Snort
# Copy the downloaded tarballs into the Docker image

# ENV DAQ_VERSION 3.0.8
RUN    cd libdaq \
    && autoreconf -vif; ./configure; make; make install

ENV INSTALLPATH /
RUN export my_path=${INSTALLPATH}

# ENV SNORT_VERSION 3.1.40.0
RUN    cd snort \
    && ./configure_cmake.sh --prefix=${INSTALLPATH} \
    && cd build \
    && make install

RUN ldconfig

RUN mkdir -p /var/log/snort

# Deploy a custom configuration
COPY etc/ ${INSTALLPATH}/etc/snort/
RUN apt-get -y install iptables ethtool
# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    /opt/v${SNORT_VERSION}.tar.gz /opt/v${DAQ_VERSION}.tar.gz

# Specify the working directory
WORKDIR /tmp
#COPY start2.sh /bin/start.sh
#RUN chmod +x /bin/start.sh
# Test the validity of the installation
#CMD ["snort", "--daq", "afpacket", "--daq-mode", "inline","-Q", "-c", "/etc/snort/snort.lua", "-R", "/etc/snort/rules/local.rules", "-l", "/var/log/snort", "-i", "eth0","-s","65535"]
CMD ["snort", "--daq", "nfq","--daq-var","device=eth0","--daq-var","queue=1",  "-Q", "-c", "/etc/snort/snort.lua", "-R", "/etc/snort/rules/local.rules", "-l", "/var/log/snort" ]
#CMD ["snort","-Q", "-q", "-c", "/etc/snort/snort.lua", "-R", "/etc/snort/rules/local.rules", "-l", "/var/log/snort", "-i", "eth0:eth1"]

#CMD /bin/start.sh
