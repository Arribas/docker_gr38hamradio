#docker run -it --device=/dev/ttyUSB0 --device=/dev/ttyUSB1 --privileged -v /dev/bus/usb:/dev/bus/usb --net=host --env="DISPLAY" --volume="$PWD/docker_shared_folder:/home/dongle/host_files:rw" gnss_dongle:1.0
docker run -it \
	--device /dev/snd \
	-e PULSE_SERVER=unix:${XDG_RUNTIME_DIR}/pulse/native \
	-e QT_QUICK_BACKEND=software \
	-v ${XDG_RUNTIME_DIR}/pulse/native:${XDG_RUNTIME_DIR}/pulse/native \
	-v ~/.config/pulse/cookie:/root/.config/pulse/cookie \
	-v /tmp/.X11-unix:/tmp/.X11-unix:rw \
	-e DISPLAY=unix$DISPLAY --device /dev/dri \
        -e QT_X11_NO_MITSHM=1 \
	--group-add $(getent group audio | cut -d: -f3) \
	--privileged -v /dev/bus/usb:/dev/bus/usb --net=host --env="DISPLAY" --volume="$PWD/docker_shared_folder:/home/dongle/host_files:rw" gnuradioham:1.0
#docker run -it --privileged -v /dev/bus/usb:/dev/bus/usb --net=host --env="DISPLAY" --volume="$HOME/.Xauthority:/home/android/.Xauthority:rw" gnuradio-android
