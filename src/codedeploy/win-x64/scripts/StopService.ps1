$ErrorActionPreference = 'Stop'
Stop-Service eShopOnWeb
sc.exe delete eShopOnWeb