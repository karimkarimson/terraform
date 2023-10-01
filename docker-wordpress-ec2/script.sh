#!/bin/bash
echo "######################"
echo "Updating"
echo "######################"
sudo apt update -y
sudo apt-get update -y
echo "######################"

echo "######################"
echo "Installing Docker"
echo "######################"
sudo apt install docker.io -y
echo "######################"

echo "######################"
echo "Installing Docker-Compose"
echo "######################"
sudo apt-get install docker-compose -y
echo "######################"

echo "######################"
echo "Cloning Repo"
echo "######################"
git clone https://github.com/karimkarimson/docker-revprox.git

echo "######################"
echo "Adding .env and .htpass to correct location"
echo "######################"
sudo mv /home/ubuntu/.env.docker.dev ./docker-revprox/.env.docker.dev
sudo mv /home/ubuntu/.htpass ./docker-revprox/reverseproxy/.htpass

echo "######################"
echo "######################"
echo "Starting Docker-Compose"
echo "######################"
echo "######################"
cd docker-revprox
sudo docker-compose --env-file ./.env.docker.dev up -d 

exit