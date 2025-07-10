#!/bin/bash

# Check if all 5 parameters are provided
if [ "$#" -lt 5 ]; then
  echo "Usage: $0 <email> <api_key> <action> <server_id> <app_id>"
  echo "Example: $0 user@example.com myapikey varnish srv123 app456"
  exit 1
fi

EMAIL="$1"
API_KEY="$2"
ACTION="$3"
SERVER_ID="$4"
APP_ID="$5"

# Get the access token
echo "Requesting access token..."

RESPONSE=$(curl -s -X POST https://api.cloudways.com/api/v1/oauth/access_token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "email=$EMAIL" \
  -d "api_key=$API_KEY")

# Extract access_token using awk
ACCESS_TOKEN=$(echo "$RESPONSE" | awk -F'"' '/access_token/ {print $4}')

if [ -z "$ACCESS_TOKEN" ]; then
  echo "❌ Failed to retrieve access token. Full response:"
  echo "$RESPONSE"
  exit 1
fi

echo -e "\n🔎 Verifying if Varnish is running..."

precheck_status=$(curl -s -o /dev/null -w "%{http_code}" \
  -X POST https://api.cloudways.com/api/v1/service/varnish \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -d "server_id=$SERVER_ID&action=enable")

if [ "$precheck_status" -ne 200 ]; then
  echo -e "\n❌ Varnish is already down with this error: $precheck_status"
  echo "Exiting script."
  exit 1
fi

echo -e "\n✅ Access token retrieved."

# Function to manage varnish and restart service
varnish() {
  echo -e "\n📦 Adding exclusion rule to Varnish..."

  VCL_LIST='[
    {
      "method": "exclude",
      "type": "url",
      "value": "\\wp-content\\uploads\\"
    }
  ]'

  # Step 1: Call Varnish Setting API
#  curl -s -X POST https://api.cloudways.com/api/v1/app/manage/varnish_setting \
#    -H "Content-Type: application/json" \
#    -H "Authorization: Bearer $ACCESS_TOKEN" \
#    -d "server_id=$SERVER_ID" \
#    -d "app_id=$APP_ID" \
#    -d "vcl_list=$VCL_LIST"

curl -s -X POST https://api.cloudways.com/api/v1/app/manage/varnish_setting \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -d "{
    \"server_id\": \"$SERVER_ID\",
    \"app_id\": \"$APP_ID\",
    \"vcl_list\": $VCL_LIST
  }"

#  echo "⏳ Waiting 120 seconds before restarting the server..."
  sleep 120

  # Step 2: Restart the server
  echo -e "\n🔄 Restarting server with ID: $SERVER_ID..."
  curl -s -X POST https://api.cloudways.com/api/v1/server/restart \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    -d "server_id=$SERVER_ID"

#  echo "⏳ Waiting 120 seconds before disabling Varnish service..."
  sleep 120

  # Step 3: Disable Varnish service
  echo -e "\n🚫 Disabling Varnish service..."
  curl -s -X POST https://api.cloudways.com/api/v1/service/varnish \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    -d "server_id=$SERVER_ID&action=disable"

#  echo "⏳ Waiting another 120 seconds before enabling Varnish service..."
  sleep 60

  # Step 4: Enable Varnish service
  echo -e "\n✅ Enabling Varnish service..."
  ENABLE_RESPONSE=$(curl -s -X POST https://api.cloudways.com/api/v1/service/varnish \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    -d "server_id=$SERVER_ID&action=enable")

  echo -e "📤 Response from 'enable' call:\n"
  echo "$ENABLE_RESPONSE"
}

# Execute the specified action
if [ "$ACTION" == "varnish" ]; then
  varnish
fi
