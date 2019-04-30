#!/bin/bash
# Abort if we find the path to dotnet has already been installed by this script
if grep -L "###+DOTNET2.2" ~/.bash_profile; then exit 0; fi
sudo yum -y update
sudo yum -y install libunwind
# Go fetch the binary package for the 2.2 SDK
wget -O dotnet-2.2.sdk.tgz https://download.visualstudio.microsoft.com/download/pr/7d8f3f4c-9a90-42c5-956f-45f673384d3f/14d686d853a964025f5c54db237ff6ef/dotnet-sdk-2.2.105-linux-x64.tar.gz
# Copy everything to the install folder ($HOME/dotnet)
mkdir -p $HOME/dotnet
tar zxf dotnet-2.2.sdk.tgz -C $HOME/dotnet
# Add dotnet SDK to the profile path
echo $'###+DOTNET2.2\nexport PATH=$HOME/dotnet:$PATH\n###-DOTNET2.2\n' >> ~/.bash_profile
# Clean up after ourselves!
rm dotnet-2.2.sdk.tgz
