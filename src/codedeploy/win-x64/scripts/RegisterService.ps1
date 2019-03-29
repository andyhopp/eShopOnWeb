$ErrorActionPreference = 'Stop'
New-Service -Name eShopOnWeb -BinaryPathName "c:\eShopOnWeb\Web.exe --service" -DisplayName "eShopOnWeb Sample App" -StartupType Automatic 