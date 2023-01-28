VERSION=$1
cd /var/cw/systeam
wget -1 https://nodejs.org/download/release/v$VERSION/node-v$VERSION-linux-x64.tar.gz
tar -xf node-v$VERSION-linux-x64.tar.gz
rm /usr/bin/node /usr/bin/npm
ln -s /var/cw/systeam/node-v$VERSION-linux-x64/bin/node /usr/bin/node
ln -s /var/cw/systeam/node-v$VERSION-linux-x64/bin/npm /usr/bin/npm
