#!/bin/bash
#===============================================================================#
#                                                           			#
#          FILE:  restore.sh                                                    #
#                                                           			#
#         USAGE:  ./restore_site.sh --help or -h                                #
#                                                     			        #
#   DESCRIPTION:  This script helps with restoring a backup from a specific     #
#		  point to a new application                                    #
#                                                           			#
#        AUTHOR:  Raja Shahrukh, https://github.com/rajashahrukh                #
#       COMPANY:  Cloudways                                                     #
#       VERSION:  1.0                                                           #
#       CREATED:  ---                                                           #
#      REVISION:  ---								#
#===============================================================================#

SOURCE_APP=$1
DEST_APP=$2
RESTORE_POINT=$3
APPDIR=/home/master/applications

wp() {
    /usr/local/bin/wp --allow-root --skip-plugins --skip-themes $@
}

print_color() {

    case $1 in
    "Success") COLOR="\033[1;32mSuccess:\033[0m" ;;
    "Error") COLOR="\033[1;31mError:\033[0m" ;;
    "INFO") COLOR="\033[1;36mINFO:\033[0m" ;;
    esac
    echo -e "${COLOR} $2"
}

usage() {
    cat >&2 <<EOF

    Usage:

    ./restore_site.sh source_app_db dest_app_db restore_date

EOF
}

if [[ -z $1 || -z $2 || -z $3 ]]; then
    echo -e "Missing arguments"
    usage
    exit
elif [ $# -eq 0 ]; then
    echo -e "No arguments provided"
    usage
    exit
elif [ $# -gt 3 ]; then
    echo -e "Too many arguments!"
    usage
    exit
fi

if [[ ! -e $APPDIR/$SOURCE_APP && ! -e $APPDIR/$DEST_APP ]]; then
    print_color "Error" "Both source $SOURCE_APP and destination $DEST_APP applications do not exist."
    exit
elif [[ ! -e $APPDIR/$SOURCE_APP ]]; then
    print_color "Error" "Source application $SOURCE_APP does not exist."
    exit
elif [[ ! -e $APPDIR/$DEST_APP ]]; then
    print_color "Error" "Destination application $DEST_APP does not exist."
    exit
fi

read -p "Are you sure you would like to proceed with the restore? " -n 1 -r
echo # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted!"
    exit 0
fi

if ! cd $APPDIR/$DEST_APP/public_html/ && wp core is-installed >/dev/null 2>&1; then
    print_color "Error" "This is not a WordPress application or WP CLI is not working!"
    exit 0
fi

if [[ -e $APPDIR/$SOURCE_APP/tmp/public_html || -e $APPDIR/$SOURCE_APP/tmp/private_html || -e $APPDIR/$SOURCE_APP/tmp/mysql ]]; then
    print_color "INFO" "Backup already exists!"
    exit 0
fi

print_color "INFO" "Fetching Backup..."

if /var/cw/scripts/bash/duplicity_restore.sh --src $SOURCE_APP -r --dst "$APPDIR/$SOURCE_APP/tmp" --time "$RESTORE_POINT"; then

    DEST_APP_DB_PW=$(cd $APPDIR/$DEST_APP/public_html/ && wp config get DB_PASSWORD)
    DEST_APP_URL=$(cd $APPDIR/$DEST_APP/public_html/ && wp option get home)

    print_color "INFO" "Removing contents of Destination app..."

    print_color "INFO" "Removing database..."
    cd $APPDIR/$DEST_APP/public_html/ && wp db reset --yes

    print_color "INFO" "Removing files..."
    rm -rf $APPDIR/$DEST_APP/public_html/*

    print_color "INFO" "Copying data..."

    rsync -avuz -q $APPDIR/$SOURCE_APP/tmp/public_html/. $APPDIR/$DEST_APP/public_html/

    print_color "INFO" "Updating Database details in destination App"
    cd $APPDIR/$DEST_APP/public_html/
    wp config set DB_NAME $DEST_APP
    wp config set DB_USER $DEST_APP
    print_color "Success" "$(wp config set DB_PASSWORD $DEST_APP_DB_PW | cut -d " " -f 2-9)"

    print_color "INFO" "Importing Database..."
    mysql $DEST_APP <$APPDIR/$SOURCE_APP/tmp/mysql/$SOURCE_APP*.sql

    print_color "INFO" "Performing search-replace"
    EXISTING_URL=$(cd $APPDIR/$DEST_APP/public_html/ && wp option get home)
    print_color "Success" "$(wp search-replace "$EXISTING_URL" "$DEST_APP_URL" --all-tables | tail -1 | cut -d " " -f2-)"

    print_color "INFO" "Fixing .user.ini file"
    if [[ -e $APPDIR/$DEST_APP/public_html/.user.ini ]]; then
        sed -i 's/$SOURCE_APP/$DEST_APP/g' $APPDIR/$DEST_APP/public_html/.user.ini
        print_color "Success" ".user.ini fixed"
    else
        print_color "INFO" "user.ini does not exist."
    fi

    print_color "INFO" "Flushing WordPress Cache"
    cd $APPDIR/$DEST_APP/public_html/ && wp cache flush

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

    print_color "INFO" "Removing Backup files in tmp directory"
    rm -rf $APPDIR/$SOURCE_APP/tmp/mysql $APPDIR/$SOURCE_APP/tmp/public_html $APPDIR/$SOURCE_APP/tmp/private_html

    print_color "INFO" "Fixing permissions"
    chown -R $DEST_APP:www-data $APPDIR/$DEST_APP/public_html
    find $APPDIR/$DEST_APP/public_html/ -type d -not -perm 775 -print0 | xargs -0 -P 20 chmod 775 2>/dev/null
    find $APPDIR/$DEST_APP/public_html/ -type f -not -perm 664 -print0 | xargs -0 -P 20 chmod 664 2>/dev/null

    print_color "Success" "Backup has been restored to $DEST_APP"
else
    print_color "Error" "Could not fetch backup"
fi
