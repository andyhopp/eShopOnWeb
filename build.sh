rm -rf bin/Release/netcoreapp2.2/linux-arm64/publish/*
dotnet publish -c Release -r linux-arm64
pushd bin/Release/netcoreapp2.2/linux-arm64/publish
zip -r eShopOnWeb.zip *
popd
scp -i ~/WorkDocs/andyhopp.pem bin/Release/netcoreapp2.2/linux-arm64/publish/eShopOnWeb.zip ubuntu@ec2-54-210-180-171.compute-1.amazonaws.com:~/eShopWeb/eShopOnWeb.zip

