from datetime import datetime
from onvif import ONVIFCamera
import argparse
import pytz

# Camera connection details
CAMERA_HOST = '192.168.100.117'
CAMERA_PORT = 8899
CAMERA_USER = 'admin'
CAMERA_PASS = 'tlJwpbo6'

# Create an ONVIF camera instance
# mycam = ONVIFCamera(CAMERA_HOST, CAMERA_PORT, CAMERA_USER, CAMERA_PASS)

################################### Get Information of Camera Onvif #########################################
def get_device_information():
    mycam = ONVIFCamera(CAMERA_HOST, CAMERA_PORT, CAMERA_USER, CAMERA_PASS)
    # Get device information
    device_info = mycam.devicemgmt.GetDeviceInformation()

    # Print device information
    print(f"Manufacturer: {device_info.Manufacturer}")
    print(f"Model: {device_info.Model}")
    print(f"Firmware Version: {device_info.FirmwareVersion}")
    print(f"Serial Number: {device_info.SerialNumber}")
    print(f"Hardware Id: {device_info.HardwareId}")

################################### Get URL Snapshot of Camera Onvif #########################################
def get_snapshot_url():
    mycam = ONVIFCamera(CAMERA_HOST, CAMERA_PORT, CAMERA_USER, CAMERA_PASS)
    # Get the media service
    media_service = mycam.create_media_service()

    # Get the profiles
    profiles = media_service.GetProfiles()
    profile = profiles[0]

    # Get the snapshot URI
    snapshot_uri = media_service.GetSnapshotUri({'ProfileToken': profile.token})
    snapshot_url = snapshot_uri.Uri

    print(f'Snapshot URL: {snapshot_url}')

################################### Get Stream RTSP of Camera Onvif #########################################
def get_stream_url():
    mycam = ONVIFCamera(CAMERA_HOST, CAMERA_PORT, CAMERA_USER, CAMERA_PASS)
    # Get the media service
    media_service = mycam.create_media_service()

    # Get the profiles
    profiles = media_service.GetProfiles()
    if not profiles:
        raise Exception("No profiles found on the camera.")

    # Select the first profile
    profile_token = profiles[0].token

    # Get the stream URI
    stream_setup = {
        'Stream': 'RTP-Unicast',  # Or 'RTP-Multicast'
        'Transport': {'Protocol': 'RTSP'}
    }
    request = media_service.create_type('GetStreamUri')
    request.ProfileToken = profile_token
    request.StreamSetup = stream_setup

    stream_uri = media_service.GetStreamUri(request)
    rtsp_url = stream_uri.Uri

    print(f"RTSP Stream URL: {rtsp_url}")

################################### Set Time for Camera Onvif ###############################################
def setup_time():
    mycam = ONVIFCamera(CAMERA_HOST, CAMERA_PORT, CAMERA_USER, CAMERA_PASS)

    # Get the current time in the Asia/Ho_Chi_Minh timezone
    timezone = pytz.timezone('Asia/Ho_Chi_Minh')
    local_time = datetime.now(timezone)

    # Create a SetSystemDateAndTime request object
    request = mycam.devicemgmt.create_type('SetSystemDateAndTime')

    request.DateTimeType = 'Manual'
    request.DaylightSavings = False
    request.TimeZone = {'TZ': 'Asia/Ho_Chi_Minh'}
    request.UTCDateTime = {
        'Time': {
            'Hour': local_time.hour,
            'Minute': local_time.minute,
            'Second': local_time.second,
        },
        'Date': {
            'Year': local_time.year,
            'Month': local_time.month,
            'Day': local_time.day,
        }
    }

    mycam.devicemgmt.SetSystemDateAndTime(request)
    device_time = mycam.devicemgmt.GetSystemDateAndTime()
    print(f"Camera date and time set to: {device_time.UTCDateTime}")

################################### Main Code ###############################################
def main():
    parser = argparse.ArgumentParser(description="ONVIF Camera Setup Script")
    parser.add_argument('--get-info', action='store_true', help='Get device information')
    parser.add_argument('--get-snapshot-url', action='store_true', help='Get snapshot URL')
    parser.add_argument('--get-stream-url', action='store_true', help='Get RTSP stream URL')
    parser.add_argument('--setup-time', action='store_true', help='Setup camera time')

    args = parser.parse_args()

    if args.get_info:
        get_device_information()
    if args.get_snapshot_url:
        get_snapshot_url()
    if args.get_stream_url:
        get_stream_url()
    if args.setup_time:
        setup_time()

if __name__ == '__main__':
    main()