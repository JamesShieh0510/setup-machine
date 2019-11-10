#!/bin/bash
#------------------------------------------------------------
# This script will install Nginx
# Ubuntu 16.04
# NOTE: run as root
#------------------------------------------------------------

#Managing the Nginx
#------------------------------------------------------------

#sudo systemctl stop nginx
#sudo systemctl start nginx
#sudo systemctl restart nginx
#sudo systemctl reload nginx
#sudo systemctl disable nginx
#sudo systemctl enable nginx

#------------------------------------------------------------


# Get environment configuration file
environment_config='./.env'
hostname=($(cat $environment_config | grep 'hostname' | awk '{print $2}'))

# Installing Nginx
yes | sudo apt update
yes | sudo apt install nginx

# Adjusting the Firewall
sudo ufw app list
sudo ufw allow 'Nginx HTTP'
sudo ufw status

# Checking your Web Server
# systemctl status nginx
ip addr show
curl -4 http://$hostname

# Setting Up Server Blocks
# server blocks類似apache的virtual hosts,
# 讓我們可以在一台server下定義多個domain
sudo mkdir -p /var/www/$hostname/html
sudo chown -R $USER:$USER /var/www/$hostname/html
sudo chmod -R 755 /var/www/$hostname
# create index.html for testing
sudo touch /var/www/$hostname/html/index.html
sudo cat <<EOF | sudo tee /var/www/$hostname/html/index.html
<html>
    <head>
        <title>Welcome to $hostname</title>
    </head>
    <body>
        <h1>Success!  The $hostname server block is working!</h1>
    </body>
</html>
EOF
touch /etc/nginx/sites-available/$hostname
sudo cat <<EOF | sudo tee /etc/nginx/sites-available/$hostname
server {
        listen 80;
        listen [::]:80;

        root /var/www/$hostname/html;
        index index.html index.htm index.php index.nginx-debian.html;

        server_name $hostname;

        location / {
                try_files \$uri \$uri/ =404;
        }
}
EOF
sudo ln -s /etc/nginx/sites-available/$hostname /etc/nginx/sites-enabled/
cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.old

sed -e 's/# server_names_hash_bucket_size/server_names_hash_bucket_size/g' \
/etc/nginx/nginx.conf.old > /etc/nginx/nginx.conf

sudo nginx -t

sudo systemctl restart nginx