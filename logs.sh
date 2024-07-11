#Create logs directory
mkdir /var/cw/systeam/logs

#Recent 100 lines of syslog
tail -100 /var/log/syslog > /var/cw/systeam/logs/syslog.txt

#Recent 100 lines of Apache logs
tail -100 /home/master/applications/$1/logs/apache*.cloudwaysapps.com.access.log > /var/cw/systeam/logs/apache-$1.access.log

#df output
df -h > /var/cw/systeam/logs/disk-usage.txt

#df putput (Inodes)
df -i > /var/cw/systeam/logs/inodes-usage.txt

#du output
du -hd3 *  --total --exclude='proc' --exclude='sys' --exclude='var/ossec' --exclude='usr/share' --exclude='boot' --exclude='dev' --exclude='run' --exclude='/var/spool' --exclude='etc' --exclude='bin' --exclude='usr/lib/locale' > /var/cw/systeam/logs/du-output.txt

#Recent 100 lines of Nginx logs
tail -100 /home/master/applications/$1/logs/nginx*.cloudwaysapps.com.access.log > /var/cw/systeam/logs/nginx-$1.access.log

#Recent 100 lines of PHP Slow logs
tail -100 /home/master/applications/$1/logs/php-app.slow.log > /var/cw/systeam/logs/php-$1.slow.log

#MySQL Slow Logs
tail -100 /var/log/mysql/slow-query.log > /var/cw/systeam/logs/mysql-slow-query.txt

#Processes
top -b -n1 > /var/cw/systeam/logs/top-output.txt

#PHPFPM logs
cat /var/log/php$(php -v | head -n 1 | cut -d " " -f2 | cut -d "." -f1,2)-fpm.log > /var/cw/systeam/logs/php$(php -v | head -n 1 | cut -d " " -f2 | cut -d "." -f1,2)-fpm.txt

#APM Traffic output
apm -s $1 traffic -l1h --json > /var/cw/systeam/logs/apm-traffic.txt

#APM MySQL output
apm -s $1 mysql -l1h --json > /var/cw/systeam/logs/apm-mysql.txt

#Elastic Search Status
service elasticsearch status > /var/cw/systeam/logs/elastic-search-status.txt

#Nginx Status
service nginx status > /var/cw/systeam/logs/nginx-status.txt

#Apache Status
service apache2 status > /var/cw/systeam/logs/apache-status.txt

#Varnish Status
service varnish status > /var/cw/systeam/logs/varnish-status.txt

#MySQL Status
service mysql status > /var/cw/systeam/logs/mysql-status.txt

#Redis Status
service redis-server status > /var/cw/systeam/logs/redis-status.txt
