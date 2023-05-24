#!/bin/bash

#Declaring variables

SOURCE_APP=$1
DEST_APP=$2
RESTORE_POINT=$3

print_color(){

case $1 in
	"Success") COLOR="\033[1;32mSuccess:\033[0m" ;;
        "Error") COLOR="\033[1;31mError:\033[0m" ;;
	"INFO") COLOR="\033[1;34mINFO:\033[0m" ;;
esac

echo -e "${COLOR} $2"

}

if [[ -z $1 || -z $2 || -z $3 ]]; then
    echo -e "Missing arguments"
    exit
else
    if cd /home/master/applications/$DEST_APP/public_html/ && /usr/local/bin/wp core is-installed --allow-root >/dev/null 2>&1; then

        #Fetching backup via Duplicity

       print_color "INFO" "Fetching Backup..."

        #Checks if backup already exists if not then removes destination files from public_html

        if [ -e /home/master/applications/$DEST_APP/tmp/public_html/wp-config.php ]; then

            print_color "INFO" "Backup already exists!"
        else
            DEST_APP_DB_PW=$(cd /home/master/applications/$DEST_APP/public_html/ && /usr/local/bin/wp config get DB_PASSWORD --allow-root)

            /var/cw/scripts/bash/duplicity_restore.sh --src $SOURCE_APP -r --dst '/home/master/applications/'$DEST_APP'/tmp' --time "$RESTORE_POINT"

            print_color "INFO" "Removing contents of Destination app..."

            print_color "INFO" "Removing database..."
            cd /home/master/applications/$DEST_APP/public_html/ && /usr/local/bin/wp db reset --allow-root

            print_color "INFO" "Removing files..."
            rm -rf /home/master/applications/$DEST_APP/public_html/*

            #Copies backup data to destination

            print_color "INFO" "Copying data..."

            rsync -avuz -q /home/master/applications/$DEST_APP/tmp/public_html/. /home/master/applications/$DEST_APP/public_html/

            cd /home/master/applications/$DEST_APP/public_html/ && /usr/local/bin/wp config set DB_NAME $DEST_APP --allow-root && /usr/local/bin/wp config set DB_USER $DEST_APP --allow-root && /usr/local/bin/wp config set DB_PASSWORD $DEST_APP_DB_PW --allow-root

            print_color "INFO" "Importing Database..."

            mysql $DEST_APP </home/master/applications/$DEST_APP/tmp/mysql/$SOURCE_APP*.sql

	    #Write code for Search-Replace here

	    #Write code for WordPress permissions and ownership here

            print_color "INFO" "Flushing WordPress Cache"

            cd /home/master/applications/$DEST_APP/public_html/ && /usr/local/bin/wp cache flush --allow-root
	    #print_color "INFO"  "WordPress cache purged!"

	    if [[ $(systemctl is-active varnish) == "active" ]]; then
	    print_color "INFO" "Purging Varnish cache"
	    systemctl restart varnish
            print_color "Success" "Varnish Cache Purged"
            else
	    print_color "INFO" "Cannot flush Varnish cache. Varnish is disable!"
	    fi

            if [[ $(systemctl is-active redis) == "active" ]]; then
            print_color "INFO" "Purging Redis Cache"
            redis-cli flushall
            print_color "Success" "Redis Cache Purged"
            else
            print_color "INFO" "Cannot flush Redis cache. Redis is disable!"
            fi

            #Removing backup files in tmp directory

            print_color "INFO" "Removing Backup files in tmp directory"
            rm -rf /home/master/applications/$DEST_APP/tmp/mysql /home/master/applications/$DEST_APP/tmp/public_html /home/master/applications/$DEST_APP/tmp/private_html
            echo -e "INFO: Removed"

            print_color "Success" "Backup has been restored to $DEST_APP"

        fi

    else

        print_color "Error" "This is not a WordPress application or WP CLI is not working!"

    fi

fi
