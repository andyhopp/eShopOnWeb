#!/bin/bash
if [ -f README.md ]; then
  rm README.md
fi
yum update -y
yum install -y docker git
su ec2-user
git config --global credential.helper '!aws codecommit credential-helper $@'
git config --global credential.UseHttpPath true
exit
curl -s https://s3.amazonaws.com/malx-workshop/v0.1/assets.zip -o assets.zip
if [ -d assets/]; then
  rm -rf assets/
fi
unzip assets.zip
rm assets.zip
echo "Script completed succesfully!"
echo "Open the 'assets' folder and right-click 'Preview' on 'workshop-instructions.md' to continue..."
