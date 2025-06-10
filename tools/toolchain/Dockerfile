FROM docker.io/fedora:41

ARG CLANG_BUILD="SKIP"
ARG CLANG_ARCHIVES

WORKDIR /mnt
COPY . .
RUN echo install_weak_deps=False >> /etc/dnf/dnf.conf
RUN dnf -y update \
    && dnf -y install 'dnf-command(copr)' \
    && dnf -y install ccache \
    && dnf -y install libtool \
    && dnf -y install cmake \
    && dnf -y install autoconf \
    && dnf -y install automake \
    && dnf -y install gcc \
    && dnf -y install protobuf-compiler \
    && dnf -y install gcc-c++ \
    && dnf -y install pkgconf \
    && dnf -y install pkgconf-pkg-config \
    && dnf -y install libcurl-devel \
    && dnf -y install nlohmann-json-devel \
    && dnf -y install devscripts debhelper fakeroot file rpm-build \
    && ./install-grpc-cpp.sh \
    && ./install-dependencies.sh && dnf clean all \
    && rm -rf /root/.cache /root/.cargo \
    && echo 'ALL ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers \
    && cp ./tools/toolchain/system-auth /etc/pam.d \
    && echo 'Defaults !requiretty' >> /etc/sudoers
RUN mkdir -p /root/.m2/repository
ENV JAVA8_HOME=/usr/lib/jvm/java-1.8.0-openjdk
RUN ./tools/toolchain/optimized_clang.sh
CMD /bin/bash
