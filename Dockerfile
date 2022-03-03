#
#	Author: Jorge Pereira <jpereira@freeradius.org>
#   Desc: A sandbox installing the FreeRADIUS v3.0.x/HEAD instance as "radiusd"
#   allowing basic authentication of user "bob" and password "bob"
#

FROM ubuntu:21.04

LABEL maintainer "Jorge Pereira <jpereira@freeradius.org>"
ARG DEBIAN_FRONTEND=noninteractive
ENV CC=gcc

#
#   Disable apt-get over ipv6
#
RUN echo 'Acquire::ForceIPv4 "true";' | tee /etc/apt/apt.conf.d/99force-ipv4

#
#  Install add-apt-repository
#
RUN sed 's/archive.ubuntu.com/br.archive.ubuntu.com/g' -i /etc/apt/sources.list
RUN apt-get update && \
    apt-get install -y software-properties-common aptitude apt-utils && \
    apt-get clean && \
    rm -r /var/lib/apt/lists/*

#
#   Update
#
RUN apt-get update

#
# 	Fix locale
#
RUN apt-get update && apt-get install -y locales apt-utils

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

ENV LANG en_US.UTF-8 

#
#	Usual commands.
#
RUN apt-get install -y screen vim wget ssl-cert gdb strace iputils-ping sudo lsof extrace \
                        dialog devscripts equivs git git-lfs quilt build-essential curl

#
#  Get a modern version of cmake.  We need 3.8.2 or later to build libkqueue rpms
#
RUN curl -f -o cmake.sh https://cmake.org/files/v3.22/cmake-3.22.2-linux-x86_64.sh
RUN sh cmake.sh --skip-license --prefix=/usr/local

#
#  Grab libkqueue and build
#
WORKDIR /opt/src
RUN git clone --branch master --depth=1 https://github.com/mheily/libkqueue.git

WORKDIR libkqueue
RUN cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_INSTALL_LIBDIR=lib ./ && \
    make && \
    cpack -G DEB && \
    dpkg -i --force-all ./libkqueue*.deb

#
#  Grab & Install OpenSSL 3.0x in /opt/openssl
#
ENV OPENSSL_VERSION=3.0.1

WORKDIR /opt/src
RUN wget https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz
RUN tar xzf openssl-${OPENSSL_VERSION}.tar.gz
WORKDIR openssl-${OPENSSL_VERSION}
RUN ./Configure --prefix=/opt/openssl --openssldir=.
RUN make -j `nproc` && make install

#
#
#  Shallow clone the FreeRADIUS source
#
WORKDIR /opt/src
ARG source=https://github.com/FreeRADIUS/freeradius-server.git
RUN git clone --depth 1 --no-single-branch ${source}
WORKDIR freeradius-server
RUN	git checkout v3.0.x
RUN	if [ -e ./debian/control.in ] ; then debian/rules debian/control ; fi ; echo 'y' | mk-build-deps -irt'apt-get -yV' debian/control
RUN make deb && sync
RUN dpkg -i ../freeradius_*.deb \
			../freeradius-common*.deb \
			../freeradius-config*.deb \
			../freeradius-utils*.deb \
 			../libfreeradius3*.deb

#
#
#   eapol_test dependencies
#
RUN apt-get install -y libnl-3-dev libnl-genl-3-dev

#
# It will fetch the HEAD from hostap.git, build and save the "eapol_test" in /opt/src/freeradius-server/scripts/ci/eapol_test
# then, we will create symbolik link to /usr/local/bin/eapol_test
#
WORKDIR /opt/src
RUN git clone http://w1.fi/hostap.git
WORKDIR hostap
RUN curl -o wpa_supplicant/.config https://raw.githubusercontent.com/FreeRADIUS/freeradius-server/v3.0.x/scripts/ci/eapol_test/config_linux

# Build /usr/local/bin/eapol_test-2.9
RUN git checkout hostap_2_9 && \
	make -C wpa_supplicant/ -j8 eapol_test && \
	cp -f wpa_supplicant/eapol_test /usr/local/bin/eapol_test-2.9

# Build /usr/local/bin/eapol_test-2.10
RUN git checkout hostap_2_10 && \
	make -C wpa_supplicant/ -j8 eapol_test && \
	cp -f wpa_supplicant/eapol_test /usr/local/bin/eapol_test-2.10

# Build /usr/local/bin/eapol_test-main
RUN git checkout main && \
	make -C wpa_supplicant/ -j8 eapol_test && \
	cp -f wpa_supplicant/eapol_test /usr/local/bin/eapol_test-main

#
#   Usual ports auth/accounting/coa
#
EXPOSE 1812/udp 1812/tcp 1813/udp 1813/tcp 3799/udp

#
#	Setup basic FreeRADIUS + EAP-FAST
#
COPY config/eap /etc/freeradius/mods-config/eap
COPY config/authorize /etc/freeradius/mods-config/files/authorize
COPY config/test-eap-fast.conf /root/test-eap-fast.conf

#
#   Default HOME
#
WORKDIR /root

CMD ["freeradius", "-Xx"]
