#! /bin/bash

echo "Enter API Key: "
read api

echo "Domain: "
read domain

echo "\nMX: " && curl -s "https://api.elasticemail.com/v2/domain/verifymx?apikey=$api&domain=$domain" | sed 's/.*\(false\).*/Failed/' | sed 's/.*\(true\).*/Success/'

echo "\n\nDKIM:" && curl -s "https://api.elasticemail.com/v2/domain/verifydkim?apikey=$api&domain=$domain" | sed 's/.*\(false\).*/Failed/' | sed 's/.*\(true\).*/Success/'

echo "\n\nDMARC:" && curl -s "https://api.elasticemail.com/v2/domain/verifydmarc?apikey=$api&domain=$domain" | sed 's/.*\(false\).*/Failed/' | sed 's/.*\(true\).*/Success/'

echo "\n\nSPF:" && curl -s "https://api.elasticemail.com/v2/domain/verifyspf?apikey=$api&domain=$domain" | sed 's/.*\(false\).*/Failed/' | sed 's/.*\(true\).*/Success/'

echo "\n"
