#!/bin/bash

#Declaring variables

SOURCE_APP=$1
DEST_APP=$2
RESTORE_POINT=$3

#if /usr/local/bin/wp cli version --allow-root > /dev/null 2>&1;
#then

if [[ -z $1 || -z $2 || -z $3 ]]; then
    echo -e "Missing arguments"
    exit
else
    if /usr/local/bin/wp cli version --allow-root >/dev/null 2>&1; then

        #Fetching backup via Duplicity

        echo -e "Fetching Backup...\n\n"

        #Checks if backup already exists if not then removes destination files from public_html

        if [ -e /home/master/applications/$DEST_APP/tmp/public_html/wp-config.php ]; then

            echo "Backup already exists!"
        else
            DEST_APP_DB_PW=$(cd /home/master/applications/$DEST_APP/public_html/ && /usr/local/bin/wp config get DB_PASSWORD --allow-root)

            /var/cw/scripts/bash/duplicity_restore.sh --src $SOURCE_APP -r --dst '/home/master/applications/'$DEST_APP'/tmp' --time "$RESTORE_POINT"

            echo -e "Removing contents of Destination app...\n\n"

            echo -e "Removing database...\n\n"
            cd /home/master/applications/$DEST_APP/public_html/ && /usr/local/bin/wp db reset --allow-root

            echo -e "Removing files...\n\n"
            rm -rf /home/master/applications/$DEST_APP/public_html/*

            #Copies backup data to destination

            echo -e "Copying data...\n\n"

            rsync -avuz -q /home/master/applications/$DEST_APP/tmp/public_html/. /home/master/applications/$DEST_APP/public_html/

            cd /home/master/applications/$DEST_APP/public_html/ && /usr/local/bin/wp config set DB_NAME $DEST_APP --allow-root && /usr/local/bin/wp config set DB_USER $DEST_APP --allow-root && /usr/local/bin/wp config set DB_PASSWORD $DEST_APP_DB_PW --allow-root

            echo -e "Importing Database...\n\n"

            mysql $DEST_APP </home/master/applications/$DEST_APP/tmp/mysql/$SOURCE_APP*.sql

            echo -e "Flushing Cache"

            #    service varnish restart
            /usr/local/bin/wp cache flush --allow-root
            echo -e "Import Successful"

            echo -e "Successful"

            #Removing backup files in tmp directory

            echo -e "Removing Backup files in tmp directory"
            rm -rf /home/master/applications/$DEST_APP/tmp/mysql /home/master/applications/$DEST_APP/tmp/public_html /home/master/applications/$DEST_APP/tmp/private_html
            echo -e "Removed"

        fi

    else

        echo -e "WP CLI is not working!"

    fi

fi
