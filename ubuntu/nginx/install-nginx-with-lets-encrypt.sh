#!/bin/bash
#------------------------------------------------------------
# This script will install Nginx and Let's Encrypt on
# Ubuntu 16.04
# NOTE: run as root
#------------------------------------------------------------

. ./install-nginx.sh

# Get environment configuration file
environment_config='./.env'
hostname=($(cat $environment_config | grep 'hostname' | awk '{print $2}'))
email=($(cat $environment_config | grep 'email' | awk '{print $2}'))
redirect_https=($(cat $environment_config | grep 'redirect_https' | awk '{print $2}'))

# Installing Certbot
yes | sudo apt-get clean
yes | sudo apt-get update
yes | sudo apt-get upgrade
yes | sudo add-apt-repository ppa:certbot/certbot
yes | sudo apt install python-certbot-nginx

# Allowing HTTPS Through the Firewall
sudo ufw allow 'Nginx Full'
sudo ufw delete allow 'Nginx HTTP'
echo 'y' | sudo ufw enable
sudo ufw status

# Obtaining an SSL Certificate
#echo "$email" | sudo certbot --nginx -d $hostname -d www.$hostname
#if you want to add www sub-domain:
#echo 'A' | sudo certbot --nginx -d $hostname -d www.$hostname -m $email --redirect
if [ "$redirect_https" = "true" ]
then
	#Automatically redirect all HTTP traffic to HTTPS
	echo 'A' | sudo certbot --nginx -d $hostname -m $email --redirect
else
	#Do not automatically redirect all HTTP traffic to HTTPS
	echo 'A' | sudo certbot --nginx -d $hostname -m $email --no-redirect
fi

# Verifying Certbot Auto-Renewal
sudo certbot renew --dry-run
