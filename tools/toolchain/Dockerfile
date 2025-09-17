FROM docker.io/fedora:41

ARG CLANG_BUILD="SKIP"
ARG CLANG_ARCHIVES

WORKDIR /mnt

# Copy scripts and Abseil source
COPY install-dependencies.sh ./
COPY tools/cqlsh/requirements.txt tools/cqlsh/requirements.txt
COPY seastar/install-dependencies.sh seastar/install-dependencies.sh
COPY tools/toolchain/system-auth tools/toolchain/system-auth
COPY tools/toolchain/optimized_clang.sh tools/toolchain/optimized_clang.sh
COPY abseil/ /mnt/absl

# Base system setup
RUN echo install_weak_deps=False >> /etc/dnf/dnf.conf \
    && dnf -y update \
    && dnf -y install 'dnf-command(copr)' \
    && dnf -y install ccache devscripts debhelper fakeroot file rpm-build \
    && ./install-dependencies.sh \
    && rm -rf /root/.cache /root/.cargo \
    && echo 'ALL ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers \
    && cp ./tools/toolchain/system-auth /etc/pam.d \
    && echo 'Defaults !requiretty' >> /etc/sudoers

RUN mkdir -p /root/.m2/repository
ENV JAVA8_HOME=/usr/lib/jvm/java-1.8.0-openjdk

# Setup optimized Clang
RUN ./tools/toolchain/optimized_clang.sh

# Remove system Abseil to avoid conflicts
RUN dnf -y remove abseil abseil-devel \
    && rm -rf /usr/lib64/cmake/absl

# Install OpenTelemetry build dependencies
RUN dnf -y install \
    git cmake gcc-c++ make grpc-devel protobuf-devel zlib-devel openssl-devel \
    c-ares-devel libcurl-devel pkgconfig \
    && dnf clean all

# Build and install local Abseil
RUN cd /mnt/absl && mkdir build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/mnt/absl/install && \
    make -j$(nproc) && make install

# Ensure only local Abseil is used
ENV CMAKE_PREFIX_PATH=/mnt/absl/install:$CMAKE_PREFIX_PATH

# Build OpenTelemetry using the local Abseil
RUN git clone https://github.com/open-telemetry/opentelemetry-cpp.git && \
    cd opentelemetry-cpp && \
    \
    mkdir build-static && cd build-static && \
    cmake .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_CXX_FLAGS="-Wno-deprecated-builtins" \
      -DCMAKE_INSTALL_PREFIX=/opt/opentelemetry \
      -Dabsl_DIR=/mnt/absl/install/lib/cmake/absl \
      -DBUILD_SHARED_LIBS=OFF \
      -DBUILD_STATIC_LIBS=ON \
      -DWITH_OTLP=ON \
      -DWITH_OTLP_GRPC=ON \
      -DWITH_EXPORTERS=ON \
      -DWITH_LOGS_PREVIEW=ON \
      -DWITH_METRICS_PREVIEW=ON \
      -DBUILD_TESTING=OFF -DWITH_TEST=OFF -DWITH_BENCHMARK=OFF -DWITH_EXAMPLES=OFF \
      -DWITH_ABSEIL=OFF && \
    make -j$(nproc) && make install && \
    cd .. && \
    mkdir build-shared && cd build-shared && \
    cmake .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_CXX_FLAGS="-Wno-deprecated-builtins" \
      -DCMAKE_INSTALL_PREFIX=/opt/opentelemetry \
      -Dabsl_DIR=/mnt/absl/install/lib/cmake/absl \
      -DBUILD_SHARED_LIBS=ON \
      -DBUILD_STATIC_LIBS=OFF \
      -DWITH_OTLP=ON \
      -DWITH_OTLP_GRPC=ON \
      -DWITH_EXPORTERS=ON \
      -DWITH_LOGS_PREVIEW=ON \
      -DWITH_METRICS_PREVIEW=ON \
      -DBUILD_TESTING=OFF -DWITH_TEST=OFF -DWITH_BENCHMARK=OFF -DWITH_EXAMPLES=OFF \
      -DWITH_ABSEIL=OFF && \
    make -j$(nproc) && make install

CMD ["/bin/bash"]

