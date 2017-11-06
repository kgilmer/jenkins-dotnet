FROM jenkins/jenkins:2.73.2
MAINTAINER Swire <idoop@msn.cn>

#----Install .Net Core SDK & Nuget & Python3----#
USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libc6 \
        libcurl3 \
        libgcc1 \
        libgssapi-krb5-2 \
        libicu57 \
        liblttng-ust0 \
        libssl1.0.2 \
        libstdc++6 \
        libunwind8 \
        libuuid1 \
        python3 \
        zlib1g \
        nuget \
        g++ \
        make \
        cmake \
        libtool \
        libssl-dev \
        zlib1g-dev \
        python3-dev \
    && rm -rf /var/lib/apt/lists/*
    
# install Python3 setuptools
ENV PY_SETUPTOOLS_VERSION 36.6.0
ENV PY_SETUPTOOLS_URL https://github.com/pypa/setuptools/archive/v${PY_SETUPTOOLS_VERSION}.tar.gz

RUN curl -SL ${PY_SETUPTOOLS_URL} --output v${PY_SETUPTOOLS_VERSION}.tar.gz \
    && tar -zxf v${PY_SETUPTOOLS_VERSION}.tar.gz \
    && cd setuptools-${PY_SETUPTOOLS_VERSION} \
    && python3 bootstrap.py \
    && python3 setup.py install \
    && cd ../ && rm -rf setuptools-${PY_SETUPTOOLS_VERSION} v${PY_SETUPTOOLS_VERSION}.tar.gz

# Install .NET Core SDK
ENV DOTNET_SDK_VERSION 2.0.2
ENV DOTNET_SDK_DOWNLOAD_URL https://dotnetcli.blob.core.windows.net/dotnet/Sdk/$DOTNET_SDK_VERSION/dotnet-sdk-$DOTNET_SDK_VERSION-linux-x64.tar.gz
ENV DOTNET_SDK_DOWNLOAD_SHA 1242E8B72911A868E4F6C5D1112A64AD094223FA146DF04058160D25FABD44E4D1C50D076F3655C91613D32BC43D0514D3BAC7C3D112C23A670B5DA3676076F8

RUN curl -SL $DOTNET_SDK_DOWNLOAD_URL --output dotnet.tar.gz \
    && echo "$DOTNET_SDK_DOWNLOAD_SHA dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf dotnet.tar.gz -C /usr/share/dotnet \
    && rm dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet

# Trigger the population of the local package cache
ENV NUGET_XMLDOC_MODE skip
RUN mkdir warmup \
    && cd warmup \
    && dotnet new \
    && cd .. \
    && rm -rf warmup \
    && rm -rf /tmp/NuGetScratch
USER jenkins
