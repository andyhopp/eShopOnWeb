#!/bin/bash
systemctl stop eshop.service
systemctl disable eshop.service  
rm cd /lib/systemd/system/eshop.service
systemctl daemon-reload  
