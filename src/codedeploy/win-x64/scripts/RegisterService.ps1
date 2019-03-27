$ErrorActionPreference = 'Stop'
New-Service -Name eShopOnWeb -BinaryPathName c:\eShopOnWeb\Web.exe -DisplayName "eShopOnWeb Sample App" -StartupType Automatic 