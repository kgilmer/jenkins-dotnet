FROM jenkins/jenkins:latest
MAINTAINER Swire Chen<idoop@msn.cn>

#----Install .Net Core SDK & Nuget & Python3----#
USER root
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    python3-dev \
    python3-pip \
	    libc6 \
        libgcc1 \
        libgssapi-krb5-2 \
        libicu57 \
        liblttng-ust0 \
        libssl1.0.2 \
        libstdc++6 \
        zlib1g \
    apt-transport-https \
    && rm -rf /var/lib/apt/lists/* \
    && git config --global credential.helper store \
    && rm /usr/bin/python && ln -s /usr/bin/python3.5 /usr/bin/python \
    && ln -s /usr/bin/pip3 /usr/bin/pip \
    && pip install setuptools wheel \
    && pip install paramiko==2.4.1 \
                pyapi-gitlab==7.8.5 \
                python-jenkins==1.0.1 \
                urllib3==1.22 \
                requests==2.18.4 \
                kubernetes==6.0.0 \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-stretch-prod stretch main" > /etc/apt/sources.list.d/microsoft.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends powershell \
    && rm -rf /var/lib/apt/lists/* \
    && git config --global credential.helper store
    
 
# Install .NET Core SDK
ENV DOTNET_SDK_VERSION 2.1.300

RUN curl -SL --output dotnet.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/Sdk/$DOTNET_SDK_VERSION/dotnet-sdk-$DOTNET_SDK_VERSION-linux-x64.tar.gz \
    && dotnet_sha512='80a6bfb1db5862804e90f819c1adeebe3d624eae0d6147e5d6694333f0458afd7d34ce73623964752971495a310ff7fcc266030ce5aef82d5de7293d94d13770' \
    && echo "$dotnet_sha512 dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf dotnet.tar.gz -C /usr/share/dotnet \
    && rm dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet

# Trigger the population of the local package cache
ENV DOTNET_RUNNING_IN_CONTAINER=true \
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    NUGET_XMLDOC_MODE=skip
# ASPNETCORE_URLS=http://+:80 

# Set Timezone with CST
RUN /bin/cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
  && echo 'Asia/Shanghai' >/etc/timezone
  
USER jenkins
