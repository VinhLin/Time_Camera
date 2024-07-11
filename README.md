## Setup time for camera HKVision

Đoạn script dùng để setup lại thời gian cho camera **HKVision**.

Password được dùng mặc định.

### Download and Run
```
wget -O set_camera_time.sh https://raw.githubusercontent.com/VinhLin/Time_Camera/main/set_camera_time.sh
sudo chmod +x set_camera_time.sh
./set_camera_time.sh 192.168.10.239
```

### Note
- Để ý kết quả output, nếu có output là:
```
{"code":0,"data":{}}
```
- Tức là đã setup thành công.

--------------------------------------------------------------------------------
### Xử lý errors: `literal carriage return`
```
dos2unix <file_script_name>
```






