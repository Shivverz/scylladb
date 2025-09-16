FROM docker.io/fedora:41

ARG CLANG_BUILD="SKIP"
ARG CLANG_ARCHIVES

WORKDIR /mnt
COPY install-dependencies.sh ./
COPY tools/cqlsh/requirements.txt tools/cqlsh/requirements.txt
COPY seastar/install-dependencies.sh seastar/install-dependencies.sh
COPY tools/toolchain/system-auth tools/toolchain/system-auth
COPY tools/toolchain/optimized_clang.sh tools/toolchain/optimized_clang.sh
RUN echo install_weak_deps=False >> /etc/dnf/dnf.conf
RUN dnf -y update \
    && dnf -y install 'dnf-command(copr)' \
    && dnf -y install ccache \
    && dnf -y install devscripts debhelper fakeroot file rpm-build \
    && ./install-dependencies.sh \
    && rm -rf /root/.cache /root/.cargo \
    && echo 'ALL ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers \
    && cp ./tools/toolchain/system-auth /etc/pam.d \
    && echo 'Defaults !requiretty' >> /etc/sudoers
RUN mkdir -p /root/.m2/repository
ENV JAVA8_HOME=/usr/lib/jvm/java-1.8.0-openjdk
RUN ./tools/toolchain/optimized_clang.sh

RUN git clone https://github.com/open-telemetry/opentelemetry-cpp.git && \
    cd opentelemetry-cpp && \
    mkdir build-static && cd build-static && \
    cmake .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/usr/local/opentelemetry-static \
      -DBUILD_SHARED_LIBS=OFF \
      -DBUILD_STATIC_LIBS=ON \
      -DWITH_OTLP=ON \
      -DWITH_OTLP_GRPC=ON \
      -DWITH_EXPORTERS=ON \
      -DWITH_LOGS_PREVIEW=ON \
      -DWITH_METRICS_PREVIEW=ON \
      -DBUILD_TESTING=OFF \
      -DWITH_TEST=OFF \
      -DWITH_BENCHMARK=OFF \
      -DWITH_EXAMPLES=OFF && \
    make -j$(nproc) && \
    make install && \
    cd .. && \
    mkdir build-shared && cd build-shared && \
    cmake .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/usr/local/opentelemetry-shared \
      -DBUILD_SHARED_LIBS=ON \
      -DBUILD_STATIC_LIBS=OFF \
      -DWITH_OTLP=ON \
      -DWITH_OTLP_GRPC=ON \
      -DWITH_EXPORTERS=ON \
      -DWITH_LOGS_PREVIEW=ON \
      -DWITH_METRICS_PREVIEW=ON \
      -DBUILD_TESTING=OFF \
      -DWITH_TEST=OFF \
      -DWITH_BENCHMARK=OFF \
      -DWITH_EXAMPLES=OFF && \
    make -j$(nproc) && \
    make install
CMD ["/bin/bash"]
