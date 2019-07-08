#!/bin/bash
which dotnet

cd /lib/systemd/system  
cat > eshop.service <<EOF
[Unit]  
Description=eShop Demo App 
  
[Service]  
ExecStart=/opt/eShopOnWeb/Web
EnvironmentFile=/etc/environment
WorkingDirectory=/opt/eShopOnWeb/  
Restart=on-failure  
SyslogIdentifier=eshop-demo-app  
PrivateTmp=true  
  
[Install]  
WantedBy=multi-user.target 
EOF

systemctl daemon-reload  
systemctl enable eshop.service  

