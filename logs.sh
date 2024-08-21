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
find /* -type f -exec du -sh {} + -o -type d -exec du -sh {} + 2>/dev/null | sort -rh | awk '!seen[$1]++' | head -n 10

#Recent 100 lines of Nginx logs
tail -100 /home/master/applications/$1/logs/nginx*.cloudwaysapps.com.access.log > /var/cw/systeam/logs/nginx-$1.access.log

#Recent 100 lines of PHP Slow logs
tail -100 /home/master/applications/$1/logs/php-app.slow.log > /var/cw/systeam/logs/php-$1.slow.log

#MySQL Slow Logs
tail -100 /var/log/mysql/slow-query.log > /var/cw/systeam/logs/mysql-slow-query.txt

#Processes
top -b -n1 > /var/cw/systeam/logs/top-output.txt

#PHPFPM logs
tail -100 /var/log/php$(php -v | head -n 1 | cut -d " " -f2 | cut -d "." -f1,2)-fpm.log > /var/cw/systeam/logs/php$(php -v | head -n 1 | cut -d " " -f2 | cut -d "." -f1,2)-fpm.txt

#APM Traffic output
apm -s $1 traffic -l1h --urls --ips --json > /var/cw/systeam/logs/apm-traffic.txt

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

#APM PHP Slow Pages
apm -s $1 php -l1h --page_durations --slow_pages --json > /var/cw/systeam/logs/apm-slow-php-pages.txt

#APM Bots
apm -s $1 traffic --bots -l1h --json > /var/cw/systeam/logs/apm-bots.txt
