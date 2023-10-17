#!/bin/bash
echo "############     Updating       #################" > /home/ubuntu/install.progress.txt
# sudo apt update -y
sudo apt-get update -y

echo "############ Done Updating    #################" >> /home/ubuntu/install.progress.txt

echo "############     Upgrading       #################" >> /home/ubuntu/install.progress.txt

sudo apt-get upgrade -y
echo "############    Done Upgrading       #################" >> /home/ubuntu/install.progress.txt
