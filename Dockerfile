FROM ubuntu:22.04 as base

SHELL ["/bin/bash", "-c"]

ENV PS3DEV=/usr/local/ps3dev \
    PSL1GHT=/usr/local/ps3dev \
    PATH=${PATH}:/usr/local/ps3dev/bin:/usr/local/ps3dev/ppu/bin:/usr/local/ps3dev/spu/bin:/usr/local/ps3dev/portlibs/ppu/bin \
    PKG_CONFIG_PATH=/usr/local/ps3dev/portlibs/ppu/lib/pkgconfig \
    DEBIAN_FRONTEND=noninteractive \
    PYTHON_VERSION=3.10 \
    PYENV_ROOT=/root/.pyenv \
    PIP_ROOT_USER_ACTION=ignore

ENV PATH=${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:${PATH}

RUN apt update -y && \
    apt --no-install-recommends install -y \
        autoconf \
        automake \
        bison \
        build-essential \
        bzip2 \
        ca-certificates \
        cmake \
        flex \
        gettext-base \
        git \
        libelf-dev \
        libgmp3-dev \
        libncurses5-dev \
        libssl-dev \
        libtool \
        libtool-bin \
        make \
        patch \
        pkg-config \
        texinfo \
        wget \
        xz-utils \
        zlib1g-dev \
        # Multimedia libs
        libjpeg-dev \
        libpng-dev \
        libfreetype6-dev \
        libsdl2-dev && \
    echo 'ca_certificate=/etc/ssl/certs/ca-certificates.crt' >> /etc/wgetrc && \
    if [ "$(uname -m)" = "x86_64" ]; then \
        apt install -y nvidia-cg-toolkit; \
    fi && \
    apt --no-install-recommends install -y \
        zlib1g-dev \
        libbz2-dev \
        libreadline-dev \
        libsqlite3-dev \
        llvm \
        libncursesw5-dev \
        tk-dev \
        libxml2-dev \
        libxmlsec1-dev \
        libffi-dev \
        liblzma-dev \
        curl && \
    apt -y clean autoclean autoremove && \
    rm -rf /var/lib/apt/lists/*

RUN echo 'cacert=/etc/ssl/certs/ca-certificates.crt' >> ~/.curlrc && \
    git config --global http.sslverify 'false' && \
    curl https://pyenv.run | bash && \
    pyenv update && \
    pyenv install $PYTHON_VERSION && \
    pyenv global $PYTHON_VERSION && \
    pyenv rehash && \
    pip install pycrypto

FROM base as builder

RUN mkdir -p ${PS3DEV} ${PSL1GHT}

WORKDIR /opt
RUN git clone https://github.com/aleffita/ps3toolchain-updated ps3toolchain

WORKDIR /opt/ps3toolchain

RUN ./toolchain.sh 1
RUN ./toolchain.sh 2
RUN ./toolchain.sh 3
RUN ./toolchain.sh 4
RUN ./toolchain.sh 5
RUN ./toolchain.sh 6
RUN ./toolchain.sh 7
RUN ./toolchain.sh 8

# Add PSL1GHT build
RUN git clone https://github.com/ps3dev/PSL1GHT.git /opt/PSL1GHT && \
    cd /opt/PSL1GHT && \
    make -j12 && make install

FROM base as runtime

ENV PS3DEV=/usr/local/ps3dev \
    PSL1GHT=/usr/local/ps3dev \
    PATH=${PATH}:/usr/local/ps3dev/bin:/usr/local/ps3dev/ppu/bin:/usr/local/ps3dev/spu/bin:/usr/local/ps3dev/portlibs/ppu/bin \
    PKG_CONFIG_PATH=/usr/local/ps3dev/portlibs/ppu/lib/pkgconfig

COPY --from=builder ${PS3DEV} ${PS3DEV}