cd /var/cw/systeam/
wget https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.zip
unzip ioncube_loaders_lin_x86-64.zip 
cd ioncube
cd /usr/lib/php/20190902
/var/cw/systeam/ioncube/ioncube_loader_lin_7.4.so .
php -i | grep 'additional .ini files'
cd /etc/php/7.4/cli/conf.d
cd /var/cw/systeam/ioncube
cp ioncube_loader_lin_7.4.so-bk /usr/local/ioncube/
cp ioncube_loader_lin_7.4.so /usr/local/ioncube/
/etc/init.d/php7.4-fpm restart
php -v
