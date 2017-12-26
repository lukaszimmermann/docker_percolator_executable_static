FROM alpine

WORKDIR /
RUN apk add --no-cache cmake git g++ make  && \
    git clone https://github.com/percolator/percolator.git && \
    while read -r line; do \
      if (echo ${line} | grep -Eq ^.*executable.*$); then \
        echo '  SET(CMAKE_FIND_LIBRARY_SUFFIXES ".a")' && \
        echo '  SET(BUILD_SHARED_LIBRARIES OFF)' &&  \
        echo '  SET(CMAKE_EXE_LINKER_FLAGS "-static -static-libgcc -static-libstdc++")' && \
        echo '  add_executable(percolator main.cpp)' && \
        echo '  set_property(TARGET percolator PROPERTY LINK_SEARCH_END_STATIC TRUE)'\
      ; else \
        echo $line \
      ; fi; done < /percolator/src/CMakeLists.txt > /tmp/CMakeLists.txt && \
    mv /tmp/CMakeLists.txt percolator/src/CMakeLists.txt && \
    mkdir -p /percolator-build && \
    cd /percolator-build && \
    cmake -DTARGET_ARCH=x86_64 \
          -DCMAKE_BUILD_TYPE=Release \
          -DBUILD_SHARED_LIBS=OFF \
          -DCMAKE_INSTALL_PREFIX=/percolator-build \
          -DXML_SUPPORT=OFF \
          /percolator && \
   make percolator && \
   make install \

