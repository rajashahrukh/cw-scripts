#Create logs directory
mkdir /var/cw/systeam/logs

#Recent 100 lines of syslog
cp -r /var/log/syslog > /var/cw/systeam/logs/syslog

#Recent 100 lines of Apache logs
cp -r /home/master/applications/$1/logs/apache*.cloudwaysapps.com.access.log > /var/cw/systeam/logs/apache-$1.access.log

#df output
df -h > /var/cw/systeam/logs/disk-usage.txt

#df putput (Inodes)
df -i > /var/cw/systeam/logs/inodes-usage.txt

#du output
du -hd3 /  --total --exclude='proc' --exclude='sys' --exclude='var/ossec' --exclude='usr/share' --exclude='boot' --exclude='dev' --exclude='run' --exclude='/var/spool' --exclude='etc' --exclude='bin' --exclude='usr/lib/locale' > /var/cw/systeam/logs/du-output.txt

#Recent 100 lines of Nginx logs
cp -r /home/master/applications/$1/logs/nginx*.cloudwaysapps.com.access.log > /var/cw/systeam/logs/nginx-$1.access.log

#Recent 100 lines of PHP Slow logs
cp -r /home/master/applications/$1/logs/php-app.slow.log > /var/cw/systeam/logs/php-app.slow.log

#MySQL Slow Logs
cp -r /var/log/mysql/slow-query.log > /var/cw/systeam/logs/slow-query.log

#Processes
top -b -n1 > /var/cw/systeam/logs/top-output.txt

#PHPFPM logs
cp -r /var/log/php$(php -v | head -n 1 | cut -d " " -f2 | cut -d "." -f1,2)-fpm.log > /var/cw/systeam/logs/php$(php -v | head -n 1 | cut -d " " -f2 | cut -d "." -f1,2)-fpm.log

#APM Traffic output
apm -s $1 traffic -l1h --urls --ips --json > /var/cw/systeam/logs/apm-traffic.txt

#APM MySQL output
apm -s $1 mysql -l1h --json > /var/cw/systeam/logs/apm-mysql.txt

#Elastic Search Status
service elasticsearch status >> /var/cw/systeam/logs/service-statuses.txt

#Nginx Status
service nginx status > /var/cw/systeam/logs/service-statuses.txt

#Apache Status
service apache2 status > /var/cw/systeam/logs/service-statuses.txt

#Varnish Status
service varnish status > /var/cw/systeam/logs/service-statuses.txt

#MySQL Status
service mysql status > /var/cw/systeam/logs/service-statuses.txt

#Redis Status
service redis-server status > /var/cw/systeam/logs/service-statuses.txt

#APM PHP Slow Pages
apm -s $1 php -l1h --page_durations --slow_pages --json > /var/cw/systeam/logs/apm-slow-php-pages.txt

#APM Bots
apm -s $1 traffic --bots -l1h --json > /var/cw/systeam/logs/apm-bots.txt
