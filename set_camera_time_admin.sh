#!/bin/bash

####################################### Sample #####################################
# sudo chmod +x set_camera_time.sh
# ./set_camera_time.sh 192.168.10.239
####################################################################################

# Define the cookie file path
COOKIE_FILE="cookies.txt"

# Define the device IP
IP_Device="$1"

# Check IP_Device, if null, set default IP_Device
if [ -z "$IP_Device" ]; then
    echo "Set IP Camera default: 192.168.10.239"
    IP_Device="192.168.10.239"
fi

# Define the URLs
URL_Login="http://$IP_Device/api.html?n=login"
URL_SetTime="http://$IP_Device/api.html?n=setTimeParam"

# Get the current date and time
Day=$(date +"%d")
Month=$(date +"%m")
Year=$(date +"%Y")
Hours=$(date +"%H")
Minute=$(date +"%M")
Second=$(date +"%S")

# Check if the cookie file exists
if [ ! -f "$COOKIE_FILE" ]; then
    echo "Cookie file $COOKIE_FILE does not exist. Logging in to create the cookie file."
    curl -c "$COOKIE_FILE" --path-as-is -i -s -k -X POST \
    -H "Host: $IP_Device" \
    -H "Content-Length: 89" \
    -H "Accept: */*" \
    -H "X-Requested-With: XMLHttpRequest" \
    -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.6367.118 Safari/537.36" \
    -H "Content-Type: application/json; charset=UTF-8" \
    -H "Origin: http://$IP_Device" \
    -H "Referer: http://$IP_Device/index.html" \
    -H "Accept-Encoding: gzip, deflate, br" \
    -H "Accept-Language: en-US,en;q=0.9" \
    -H "Connection: close" \
    -b "updateTips=true" \
    --data-binary '{"api":"login","data":{"username":"admin","password":"21232f297a57a5a743894a0e4a801fc3"}}' \
    "$URL_Login"

    if [ ! -f "$COOKIE_FILE" ]; then
        echo "Failed to create the cookie file."
        exit 1
    fi
fi

# Extract the sessionID from the cookie file
SESSION_ID=$(grep "sessionID" "$COOKIE_FILE" | awk '{print $7}')
# echo "SESSION ID: $SESSION_ID"

# Check if sessionID was found
if [ -z "$SESSION_ID" ]; then
    echo "sessionID not found in the cookie file."
    exit 1
fi

# Construct the JSON payload
JSON_PAYLOAD=$(cat <<EOF
{
    "api": "setTimeParam",
    "data": {
        "year": "$Year",
        "month": "$Month",
        "day": "$Day",
        "hour": "$Hours",
        "minute": "$Minute",
        "second": "$Second",
        "model": "1",
        "timeZone": "Asia/Ho_Chi_Minh",
        "NVRModify": "0",
        "SNTPServerAddr": "time.windows.com",
        "ntpAutomatic": "0",
        "ntpInterval": "0"
    }
}
EOF
)

# Calculate the correct content length
CONTENT_LENGTH=$(echo -n "$JSON_PAYLOAD" | wc -c)

# Use curl to set the time for the camera
response=$(curl --path-as-is -i -s -k -X POST \
    -H "Host: $IP_Device" \
    -H "Content-Length: $CONTENT_LENGTH" \
    -H "Accept: */*" \
    -H "X-Requested-With: XMLHttpRequest" \
    -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.6367.118 Safari/537.36" \
    -H "Content-Type: application/json; charset=UTF-8" \
    -H "Origin: http://$IP_Device" \
    -H "Referer: http://$IP_Device/views/main.html" \
    -H "Accept-Encoding: gzip, deflate, br" \
    -H "Accept-Language: en-US,en;q=0.9" \
    -H "Connection: close" \
    -b "updateTips=true; sessionID=$SESSION_ID; userName=admin; default_streamtype=false; previewRes=3; previewStream=0" \
    --data-binary "$JSON_PAYLOAD" \
    "$URL_SetTime")

# Print the response
echo "$response"

# Remove cookie file
rm "$COOKIE_FILE"
