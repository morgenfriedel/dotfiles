#! /bin/sh

# Linux
sudo apt update -y; sudo apt upgrade -y


# Apache

sudo apt install apache2 curl -y
printf "User-Agent: *\nDisallow: /\n" | sudo tee -a /var/www/html/robots.txt
sudo chown -R www-data:www-data /var/www/html
sudo vi /etc/apache2/mods-enabled/dir.conf
sudo a2enmod headers rewrite expires
sudo service apache2 restart


# Firewall Config

sudo ufw app list
sudo ufw allow OpenSSH
sudo ufw allow in "Apache Full"
sudo ufw enable
sudo ufw status


# MySQL

sudo apt install mysql-server -y
sudo mysql_secure_installation


#PHP

sudo apt install php7.2 libapache2-mod-php7.2 php7.2-mysql php7.2-curl php7.2-gd php7.2-mbstring php7.2-xml php7.2-xmlrpc php7.2-soap php7.2-intl php7.2-zip -y
sudo service apache2 restart

# Need to setup the VirtualHost .conf files for all sites before setting up HTTPS

# <VirtualHost *:80>
#    ServerAdmin admin@url.com
#    ServerName url.com
#    ServerAlias www.url.com
#    DocumentRoot /var/www/url.com
#    ErrorLog ${APACHE_LOG_DIR}/url.error.log
#    CustomLog ${APACHE_LOG_DIR}/url.access.log combined
# </VirtualHost>

# sudo a2dissite 000-default.conf


# HTTPS / SSL

sudo add-apt-repository ppa:certbot/certbot -y
sudo apt install python-certbot-apache -y
# sudo letsencrypt


# WordPress CLI

curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp
wp --info


