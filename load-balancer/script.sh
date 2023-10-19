#!/bin/bash
echo "############     Updating       #################" > /home/ubuntu/install.progress.txt
sudo apt-get update -y

echo "############ Done Updating    #################" >> /home/ubuntu/install.progress.txt

echo "############     Upgrading       #################" >> /home/ubuntu/install.progress.txt

sudo apt-get upgrade -y
echo "############    Done Upgrading       #################" >> /home/ubuntu/install.progress.txt

echo "" >> /home/ubuntu/install.progress.txt
echo "############     Installing nginx       #################" >> /home/ubuntu/install.progress.txt
sudo apt install nginx -y

echo "" >> /home/ubuntu/install.progress.txt
echo "############     Checking nginx status       #################" >> /home/ubuntu/install.progress.txt
sudo systemctl status nginx >> /home/ubuntu/install.progress.txt

echo "" >> /home/ubuntu/install.progress.txt
echo " ########### fetching public ip #################" >> /home/ubuntu/install.progress.txt
curl -s http://169.254.169.254/latest/meta-data/public-ipv4 >> /home/ubuntu/install.progress.txt

echo "" >> /home/ubuntu/install.progress.txt
echo "############    Creating index.html       #################" >> /home/ubuntu/install.progress.txt
echo "<h1>Deployed via Terraform at IP: $INSTANCE_IP</h1>" > /var/www/html/index.html
curl -s http://169.254.169.254/latest/meta-data/public-ipv4 >> /var/www/html/index.html
echo "<p> with the local IP: </p>" >> /var/www/html/index.html
hostname -I >> /var/www/html/index.html
