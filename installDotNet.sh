#!/bin/bash
DOTNET_SDK_VERSION=2.2.102
DOTNET_SDK_DOWNLOAD_URL=https://dotnetcli.blob.core.windows.net/dotnet/Sdk/$DOTNET_SDK_VERSION/dotnet-sdk-$DOTNET_SDK_VERSION-linux-x64.tar.gz
curl -sSL $DOTNET_SDK_DOWNLOAD_URL --output dotnet.tar.gz
mkdir -p /usr/share/dotnet
tar -zxf dotnet.tar.gz -C /usr/share/dotnet
rm dotnet.tar.gz
if [ ! -L /usr/bin/dotnet ]; then
    ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet
fi

