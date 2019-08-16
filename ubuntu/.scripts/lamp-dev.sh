#! /bin/sh

# Create local environment for LAMP/WordPress dev

# Add Chrome to repo source list
sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list'
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -

# Add VSCodium to repo source list
echo 'deb https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/repos/debs/ vscodium main' | sudo tee --append /etc/apt/sources.list
wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | sudo apt-key add -

# Install packages
sudo apt update
sudo apt upgrade -y
sudo apt install git vim google-chrome-stable firefox vscodium

sudo ufw allow OpenSSH
sudo ufw enable

sudo apt install apache2 mysql-server
sudo mysql_secure_installation
sudo chown -R user:user /var/www
sudo apt install php7.2 libapache2-mod-php7.2 php7.2-mysql

# move index.php to first in line:
sudo vi /etc/apache2/mods-enabled/dir.conf

# change AllowOverride to All for /var/www
sudo vi /etc/apache2/apache2.conf

sudo service apache2 restart

# MySQL root without sudo and no password
sudo service mysql start
cd /var/run
sudo cp -rp ./mysqld ./mysqld.bak
sudo service mysql stop
sudo mysqld_safe --skip_grant_tables --skip_networking &
mysql -u root -e "use mysql; update user set authentication_string=password('') where user='root'; update user set plugin='mysql_native_password' where User='root'; flush privileges;"

# install more php packages
sudo apt install php7.2-curl php7.2-gd php7.2-mbstring php7.2-xml php7.2-xmlrpc php7.2-soap php7.2-intl php7.2-zip

# enable apache modules
sudo a2enmod rewrite
sudo a2enmod headers

sudo service apache2 restart

