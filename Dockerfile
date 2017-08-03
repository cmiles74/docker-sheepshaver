from debian:wheezy

# set our environment variables
env DEBIAN_FRONTEND='noninteractive apt-get -y install x11-common'
env GIT_SSL_NO_VERIFY=true

# install software
run apt-get -y update
run apt-get -y install build-essential gcc-4.6 g++-4.6 \
    autotools-dev automake
run apt-get -y install --no-install-recommends xserver-xorg-core \
    xserver-xorg-input-all xserver-xorg-video-fbdev libsdl1.2-dev \
    pulseaudio pulseaudio-utils libgtk2.0-dev vim git ssh

# fix gcc version
run rm /usr/bin/gcc
run rm /usr/bin/gcov
run rm /usr/bin/gcc-ar
run rm /usr/bin/gcc-ranlib
run rm /usr/bin/gcc-nm
run rm /usr/bin/g++
run ln -s /usr/bin/gcc-4.6 /usr/bin/gcc
run ln -s /usr/bin/gcov-4.6 /usr/bin/gcov
run ln -s /usr/bin/g++-4.6 /usr/bin/g++

# create our developer user
workdir /root
run groupadd -r developer -g 1000
run useradd -u 1000 -r -g developer \
    -d /developer -c "Software Developer" developer
copy /developer /developer
run chmod +x /developer/bin/*
run chown -R developer:developer /developer
run usermod -a -G audio developer

# volume used for mounting project files
volume ["/data"]
copy /data /data
workdir /data

# switch to developer
user developer

# check out sheepshaver
run mkdir /developer/src
run cd /developer/src; git clone https://github.com/cebix/macemu.git

# build sheepshaver
run cd /developer/src/macemu/SheepShaver; make links
run cd /developer/src/macemu/SheepShaver/src/Unix; NO_CONFIGURE=1 ./autogen.sh
run cd /developer/src/macemu/SheepShaver/src/Unix; ./configure --enable-sdl-video --enable-sdl-audio --disable-vosf
run cd /developer/src/macemu/SheepShaver/src/Unix; make
run cd /developer/src/macemu/SheepShaver/src/Unix; strip SheepShaver

# install sheepshaver
user root
run cp /developer/src/macemu/SheepShaver/src/Unix/SheepShaver /usr/bin

# start sheepshaver
user developer
entrypoint ["/developer/bin/start-sheepshaver"]
