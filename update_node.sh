version=$1
cd /var/cw/systeam
wget https://nodejs.org/download/release/v$version/node-v$version-linux-x64.tar.gz
tar -xvf node-v$version-linux-x64.tar.gz
rm /usr/bin/node /usr/bin/npm
ln -s /var/cw/systeam/node-v$version-linux-x64/bin/node /usr/bin/node
ln -s /var/cw/systeam/node-v$version-linux-x64/bin/npm /usr/bin/npm
