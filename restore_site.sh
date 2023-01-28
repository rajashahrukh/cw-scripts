#!/bin/bash

source_app=$1
dest_app=$2
restore_point=$3
dest_app_db_pw=$(cd /home/master/applications/$dest_app/public_html/ && /usr/local/bin/wp config get DB_PASSWORD --allow-root)

echo -e "Fetching Backup...\n\n"

/var/cw/scripts/bash/duplicity_restore.sh --src $source_app -r --dst '/home/master/applications/'$dest_app'/tmp' --time "$restore_point"

echo -e "Removing contents of Destination app...\n\n"

if [ -e /home/master/applications/$dest_app/tmp/public_html/wp-config.php ]
then
    rm -rf /home/master/applications/$dest_app/public_html/*
else
    echo "Backup Failed"
	break;
fi

echo -e "Copying data...\n\n"

rsync -avuz -q /home/master/applications/$dest_app/tmp/public_html/. /home/master/applications/$dest_app/public_html/

cd /home/master/applications/$dest_app/public_html/ && /usr/local/bin/wp config set DB_NAME $dest_app --allow-root && /usr/local/bin/wp config set DB_USER $dest_app --allow-root && /usr/local/bin/wp config set DB_PASSWORD $dest_app_db_pw --allow-root

echo -e "Importing Database...\n\n"

cd /home/master/applications/$dest_app/public_html/ && /usr/local/bin/wp db reset --yes --allow-root

mysql $dest_app < /home/master/applications/$dest_app/tmp/mysql/*sql

echo -e "Import Successful"

echo -e "Successful"
