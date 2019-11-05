# Install Nginx With Let's Encrypt

Automatically install Nginx with Let's Encrypt.

## Getting Started

This script will automatically install Nginx and Let's Encrypt on Ubuntu 16.04.
You only need to set a .env configuration file and just run the shell script.

### Prerequisites

You need to prepare :
1. A Ubuntu server (16.4)
2. A Domain Name



### Installing

Clone this repository on your server.

```
git clone https://github.com/JamesShieh0510/setup-machine.git
```

Set your parameters in .env file

```
cd ./setup-machine/ubuntu/nginx/
nano .env
```

.env:

```
metadata
    description: nginx environment configuration
parameter:
    hostname: <YOUR DOMAIN NAME>
    email: <YOUR EMAIL>
    redirect_https: <false|true> #If true Then Make all requests redirect to secure HTTPS access.
```


## Running the script


### Only install Nginx

If you want to install Nginx without Let's Encrypt:

```
. ./install-nginx.sh
```

### Install Nginx with Let's Encript.sh

If you want to install Nginx with Let's Encrypt:

```
. ./install-nginx-with-lets-encrypt.sh
```
