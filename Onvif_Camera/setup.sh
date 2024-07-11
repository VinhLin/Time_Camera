#!/bin/bash

####################################### Sample #####################################
# python3 onvif_camera_setup.py --get-info
# python3 onvif_camera_setup.py --get-snapshot-url
# python3 onvif_camera_setup.py --get-stream-url
# python3 onvif_camera_setup.py --setup-time
####################################################################################

# Update Pi
sudo apt update -y

# Install pip
sudo apt install python3-pip -y
pip --version

# Install lib: onvif and pytz
pip install onvif-zeep -y
pip install pytz -y

# Download python script code
wget -O /usr/bin/onvif_camera_setup.py https://raw.githubusercontent.com/VinhLin/Time_Camera/Onvif_Camera/main/onvif_camera_setup.py
