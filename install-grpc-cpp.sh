#!/bin/bash -e

export MY_INSTALL_DIR=/root/.local
export PATH="$MY_INSTALL_DIR/bin:$PATH"

# Build and install Protobuf first
git clone --depth=1 --branch v25.1 https://github.com/protocolbuffers/protobuf.git
cd protobuf
git submodule update --init --recursive
cmake -DCMAKE_CXX_STANDARD=17 -DCMAKE_INSTALL_PREFIX=$MY_INSTALL_DIR .
make -j$(nproc)
make install
cd ..

# Now build and install gRPC
git clone --recurse-submodules -b v1.72.0 --depth 1 --shallow-submodules https://github.com/grpc/grpc
cd grpc
mkdir -p cmake/build
pushd cmake/build
cmake -DgRPC_INSTALL=ON \
      -DgRPC_BUILD_TESTS=OFF \
      -DCMAKE_CXX_STANDARD=17 \
      -DCMAKE_PREFIX_PATH=$MY_INSTALL_DIR \
      -DCMAKE_INSTALL_PREFIX=$MY_INSTALL_DIR \
      ../..
make -j$(nproc)
make install
popd

# Register custom lib path
echo "$MY_INSTALL_DIR/lib" >> /etc/ld.so.conf.d/grpc.conf
echo "$MY_INSTALL_DIR/lib64" >> /etc/ld.so.conf.d/grpc.conf
ldconfig

