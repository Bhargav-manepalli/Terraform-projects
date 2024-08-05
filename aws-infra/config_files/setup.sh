#!/bin/sh

sudo apt update -y && sudo apt install nginx unzip -y
mkdir /tmp && cd /tmp
wget https://www.tooplate.com/zip-templates/2106_soft_landing.zip
unzip 2106_soft_landing.zip
sudo cp -r 2106_soft_landing/* /var/www/html/
