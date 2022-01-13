# SPDX-FileCopyrightText: 2022, Javier Arribas <jarribas@cttc.es>
# SPDX-License-Identifier: MIT

FROM ubuntu:20.04
LABEL version="1.0" description="Ubuntu 20.04 image GNURadio 3.8 and a set of SDR Ham Radio libraries and tools" maintainer="jarribas@cttc.es"

ARG USER=hamsdr


RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install software-properties-common -y && add-apt-repository ppa:gnuradio/gnuradio-releases-3.8 -y

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
  #--no-install-recommends \
  build-essential \
  cmake \
  git \
  g++ \
  ca-certificates \
  libboost-all-dev \
  libgmp-dev \
  swig \
  python3-numpy \
  python3-mako \
  python3-sphinx \
  python3-lxml \
  libfftw3-dev \
  liblog4cpp5-dev \
  #gnuradio-dev \
  gnuradio \
  #gr-osmosdr \
  libsdl1.2-dev \
  libgsl-dev \
  libqwt-qt5-dev \
  libqt5opengl5-dev \
  python3-pyqt5 \
  libzmq3-dev \
  python3-yaml \
  python3-click \
  python3-click-plugins \
  python3-zmq \
  python3-scipy \
  python3-gi \
  python3-gi-cairo \
  gir1.2-gtk-3.0 \
  libcodec2-dev \
  libgsm1-dev \
  libpugixml-dev \
  libpcap-dev \
  libblas-dev \
  liblapack-dev \
  libarmadillo-dev \
  libgflags-dev \
  libgoogle-glog-dev \
  libgnutls-openssl-dev \
  libmatio-dev \
  libgtest-dev \
  libprotobuf-dev \
  protobuf-compiler \
  nano \
  tar \
  unzip \
  screen \
  wget \
  sudo \
  libsoapysdr-dev \
  libi2c-dev \
  libusb-1.0-0-dev \
  libwxgtk3.0-gtk3-dev \
  freeglut3-dev \
  libxml2-dev \
  liborc-0.4-dev \
  uhd-host \
  libuhd-dev \
  default-jre \
  alsa-base \
  pulseaudio \
  libpulse-dev \
  alsa-utils \
  python3-pip \
  xastir \
  gedit \
  xterm \
  libavahi-common-dev \
  libavahi-client-dev \
  libaio-dev \
  bison \
  flex \
  liborc-dev \
  librtlsdr-dev \
  qtbase5-dev \
  libqt5svg5-dev \
  libasound2 \
  libasound2-dev \
  libcppunit-dev \
  python-numpy \
  libjack-dev \
  portaudio19-dev \
  libportaudio2 \
  libportaudiocpp0 \
  openssh-server \
  qtchooser \
  libqt5multimedia5-plugins \
  qtmultimedia5-dev \
  libqt5websockets5-dev \
  qttools5-dev \
  qttools5-dev-tools \
  libqt5opengl5-dev \
  libqt5quick5 \
  libqt5charts5-dev \
  qml-module-qtlocation \
  qml-module-qtlocation \
  qml-module-qtpositioning \
  qml-module-qtquick-window2 \
  qml-module-qtquick-dialogs \
  qml-module-qtquick-controls \
  qml-module-qtquick-controls2 \
  qml-module-qtquick-layouts \
  libqt5serialport5-dev \
  qtdeclarative5-dev \
  qtpositioning5-dev \
  qtlocation5-dev \
  libqt5texttospeech5-dev \
  libopencv-dev \
  libfaad-dev \
  libopus-dev \
  libavfilter-dev \
  libspeexdsp-dev \
  libsamplerate0-dev \
  bash-completion \
  octave && apt-get clean
  

RUN groupadd -g 1000 -r $USER
RUN useradd -u 1000 -g 1000 --create-home -r $USER

#Change password
RUN echo "$USER:$USER" | chpasswd

#Make sudo passwordless
RUN echo "${USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-$USER
RUN usermod -aG sudo $USER
RUN usermod -aG plugdev $USER
RUN usermod -a -G audio $USER

USER $USER
WORKDIR /home/$USER

RUN cd /home/$USER/ && volk_profile

RUN mkdir -p /home/$USER/sdr

# get, build and install hackrf suite
ARG hackrf_git=https://github.com/mossmann/hackrf.git
RUN cd /home/$USER/sdr/ && git clone ${hackrf_git} hackrf && mkdir -p hackrf/host/build && cd hackrf/host/build && cmake .. && make -j$(($NPROC+1)) && sudo make install && sudo ldconfig

# get, build and install libiio suite
ARG libiio_git=https://github.com/analogdevicesinc/libiio.git
RUN cd /home/$USER/sdr/ && git clone ${libiio_git} libiio && mkdir -p libiio/build && cd libiio/build && cmake .. && make -j$(($NPROC+1)) && sudo make install && sudo ldconfig

# get, build and install libad9361-iio suite
ARG libad9361_git=https://github.com/analogdevicesinc/libad9361-iio.git
RUN cd /home/$USER/sdr/ && git clone ${libad9361_git} libad9361-iio && mkdir -p libad9361-iio/build && cd libad9361-iio/build && cmake .. && make -j$(($NPROC+1)) && sudo make install && sudo ldconfig

# get, build and install gr-iio suite
ARG griio_git=https://github.com/analogdevicesinc/gr-iio.git
RUN cd /home/$USER/sdr/ && git clone -b upgrade-3.8 ${griio_git} gr-iio && mkdir -p gr-iio/build  && cd gr-iio/build && cmake .. && make -j$(($NPROC+1)) && sudo make install && sudo ldconfig

# get, build and install LimeSuite
ARG LimeSuite_git=https://github.com/myriadrf/LimeSuite.git
RUN cd /home/$USER/sdr/ && git clone ${LimeSuite_git} LimeSuite && cd LimeSuite/build && cmake .. && make -j$(($NPROC+1)) && sudo make install && sudo ldconfig

# get, build and install gr-limesdr (original version)
ARG gr_limesdr_git=https://github.com/myriadrf/gr-limesdr
RUN cd /home/$USER/sdr/ && git clone ${gr_limesdr_git} gr-limesdr && mkdir -p gr-limesdr/build && cd gr-limesdr/build && git checkout gr-3.8 && cmake .. && make -j$(($NPROC+1)) && sudo make install && sudo ldconfig

#get and install gr-iqbal
ARG gr_iqbal_git=https://github.com/osmocom/gr-iqbal.git
RUN cd /home/$USER/sdr/ && git clone -b gr3.8 ${gr_iqbal_git} gr-iqbal && cd gr-iqbal && git submodule init && git submodule update && mkdir -p build && cd build && cmake .. && make -j$(($NPROC+1)) && sudo make install && sudo ldconfig

#get and install gr-osmosdr
ARG gr_osmosdr_git=https://github.com/osmocom/gr-osmosdr.git
RUN cd /home/$USER/sdr/ && git clone -b gr3.8 ${gr_osmosdr_git} gr-osmosdr && mkdir -p gr-osmosdr/build && cd gr-osmosdr/build && cmake .. && make -j$(($NPROC+1)) && sudo make install && sudo ldconfig

#get and install gr-Satellites
ARG gr_satellites_git=https://github.com/daniestevez/gr-satellites.git
RUN pip3 install --user --upgrade construct requests
RUN cd /home/$USER/sdr/ && git clone --recursive ${gr_satellites_git} gr-satellites && cd gr-satellites && git checkout maint-3.8 && mkdir -p build && cd build && cmake .. && make -j$(($NPROC+1)) && sudo make install && sudo ldconfig

#get, build and install grcorrectiq
ARG grcorrectiq_git=https://github.com/ghostop14/gr-correctiq.git
RUN cd /home/$USER/sdr/ && git clone -b maint-3.8 ${grcorrectiq_git} grcorrectiq && cd grcorrectiq && mkdir -p build && cd build && cmake .. && make -j$(($NPROC+1)) && sudo make install && sudo ldconfig


#get, build and install gqrx
ARG gqrx_git=https://github.com/gqrx-sdr/gqrx.git
RUN cd /home/$USER/sdr/ && git clone -b v2.15.2 ${gqrx_git} gqrx && cd gqrx && mkdir -p build && cd build && cmake .. && make -j$(($NPROC+1)) && sudo make install && sudo ldconfig

#get, build and install sdrangel
#ARG libdab_git=https://github.com/srcejon/dab-cmdline
#RUN cd /home/$USER/sdr/ && git clone ${libdab_git} libdab && cd libdab/library && git checkout msvc && mkdir -p build && cd build && cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/libdab .. && make -j$(($NPROC+1)) && sudo make install && sudo ldconfig

#ARG serialdv_git=https://github.com/f4exb/serialDV.git
#RUN cd /home/$USER/sdr/ && git clone ${serialdv_git} serialdv && cd serialdv && git reset --hard "v1.1.4" && mkdir -p build && cd build && cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/serialdv .. && make -j$(($NPROC+1)) && sudo make install && sudo ldconfig

#ARG aptdec_git=https://github.com/srcejon/aptdec.git
#RUN cd /home/$USER/sdr/ && git clone -b libaptdec ${aptdec_git} aptdec && cd aptdec && mkdir -p build && cd build && cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/aptdec .. && make -j$(($NPROC+1)) && sudo make install && sudo ldconfig

#ARG cm256cc_git=https://github.com/f4exb/cm256cc.git
#RUN cd /home/$USER/sdr/ && git clone ${cm256cc_git} cm256cc && cd cm256cc && git reset --hard c0e92b92aca3d1d36c990b642b937c64d363c559 && mkdir -p build && cd build && cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/cm256cc .. && make -j$(($NPROC+1)) && sudo make install && sudo ldconfig

#ARG mbelib_git=https://github.com/szechyjs/mbelib.git
#RUN cd /home/$USER/sdr/ && git clone ${mbelib_git} mbelib && cd mbelib && git reset --hard 9a04ed5c78176a9965f3d43f7aa1b1f5330e771f && mkdir -p build && cd build && cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/mbelib .. && make -j$(($NPROC+1)) && sudo make install && sudo ldconfig

#ARG dsdcc_git=https://github.com/f4exb/dsdcc.git
#RUN cd /home/$USER/sdr/ && git clone ${dsdcc_git} dsdcc && cd dsdcc && git reset --hard "v1.9.3" && mkdir -p build && cd build && cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/dsdcc -DUSE_MBELIB=ON -DLIBMBE_INCLUDE_DIR=/opt/install/mbelib/include -DLIBMBE_LIBRARY=/opt/install/mbelib/lib/libmbe.so -DLIBSERIALDV_INCLUDE_DIR=/opt/install/serialdv/include/serialdv -DLIBSERIALDV_LIBRARY=/opt/install/serialdv/lib/libserialdv.so .. && make -j$(($NPROC+1)) && sudo make install && sudo ldconfig

#ARG codec2_git=https://github.com/drowe67/codec2.git
#RUN cd /home/$USER/sdr/ && git clone ${codec2_git} codec2 && cd codec2 && git reset --hard 76a20416d715ee06f8b36a9953506876689a3bd2 && mkdir -p build && cd build && cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/codec2 .. && make -j$(($NPROC+1)) && sudo make install && sudo ldconfig

#ARG sgp4_git=https://github.com/dnwrnr/sgp4.git
#RUN cd /home/$USER/sdr/ && git clone ${sgp4_git} sgp4 && cd sgp4 && mkdir -p build && cd build && cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/sgp4 .. && make -j$(($NPROC+1)) && sudo make install && sudo ldconfig

#ARG libsigmf_git=https://github.com/f4exb/libsigmf.git
#RUN cd /home/$USER/sdr/ && git clone -b new-namespaces ${libsigmf_git} libsigmf && cd libsigmf && mkdir -p build && cd build && cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/libsigmf .. && make -j$(($NPROC+1)) && sudo make install && sudo ldconfig

#ARG sdrangel_git=https://github.com/f4exb/sdrangel.git
#RUN cd /home/$USER/sdr/ && git clone ${sdrangel_git} sdrangel && cd sdrangel && mkdir -p build && cd build && cmake -Wno-dev -DDEBUG_OUTPUT=ON -DRX_SAMPLE_24BIT=ON \
#-DCMAKE_BUILD_TYPE=RelWithDebInfo \
#-DUHD_DIR=/opt/install/uhd \
#-DAPT_DIR=/opt/install/aptdec \
#-DCM256CC_DIR=/opt/install/cm256cc \
#-DDSDCC_DIR=/opt/install/dsdcc \
#-DSERIALDV_DIR=/opt/install/serialdv \
#-DMBE_DIR=/opt/install/mbelib \
#-DCODEC2_DIR=/opt/install/codec2 \
#-DSGP4_DIR=/opt/install/sgp4 \
#-DLIBSIGMF_DIR=/opt/install/libsigmf \
#-DDAB_DIR=/opt/install/libdab \
#-DCMAKE_INSTALL_PREFIX=/opt/install/sdrangel .. && make -j$(($NPROC+1)) && sudo make install && sudo ldconfig


#get and install gr-APRS (Arribas fork for GNURadio 3.8)
ARG gr_aprs_git=https://github.com/Arribas/gr-APRS.git
RUN cd /home/$USER/sdr/ && git clone ${gr_aprs_git} gr-aprs && cd gr-aprs && git checkout gr3.8 && sudo cp Module/packet.py /usr/local/lib/python3/dist-packages/

#make gqrx happy
#RUN sudo service dbus start \
#&& sudo service avahi-daemon start

#export some shell paths
RUN echo "export PYTHONPATH=/usr/lib/python3/dist-packages:/usr/lib/python3/site-packages:/usr/local/lib/python3/dist-packages:/home/$USER/.local/lib/python3.8/site-packages" >> /home/$USER/.bashrc \
&& echo "export LD_LIBRARY_PATH=/usr/lib:$LD_LIBRARY_PATH" >> /home/$USER/.bashrc \
&& echo "export PATH=/home/$USER/.local/bin:$PATH" >> /home/$USER/.bashrc \
&& echo "sudo service dbus start" >> /home/$USER/.bashrc \
&& echo "sudo service avahi-daemon start" >>/home/$USER/.bashrc


ENTRYPOINT ["/bin/bash"]
