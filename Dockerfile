# ==================
#  Unturned Dockerfile
#   PrivateHeberg©
# ==================

FROM debian:8
MAINTAINER privateHeberg

# ==== Variables ==== #
ENV STEAM_USER anonymous
ENV STEAM_PASSWORD ""
ENV INSTANCE_NAME=""
ENV INSTANCE_PORT=27015
# =================== #

# ==== Paquets ==== #
RUN apt-get update &&\
    apt-get install -y curl unzip
RUN dpkg --add-architecture i386
RUN apt-get update &&\
    apt-get install -y build-essential gcc-multilib rpm libstdc++6:i386 libgcc1:i386 zlib1g:i386 libncurses5:i386 &&\
    apt-get install libmono2.0-cil mono-runtime &&\
    apt-get install libc6:i386 libgl1-mesa-glx:i386 libxcursor1:i386 libxrandr2:i386
# ================= #

# ==== Steam user ==== #
RUN adduser \
	--disabled-login \
	--shell /bin/bash \
	--gecos "" \
	steam
RUN usermod -a -G sudo steam
# ==================== #

# ==== Scripts ==== #
COPY run.sh /home/unturned/run.sh
RUN touch /root/.bash_profile
RUN chmod 777 /home/unturned/run.sh
RUN mkdir  /data
RUN chown steam -R /data && chmod 755 -R /data
# ================= #

# ==== SteamCMD ==== #
RUN mkdir /home/unturned/steamcmd &&\
	cd /home/unturned/steamcmd &&\
	curl http://media.steampowered.com/installer/steamcmd_linux.tar.gz | tar -vxz
# ================== #

# ==== Volumes ==== #
VOLUME  /data
WORKDIR /data
# ================= #

ENTRYPOINT ["/home/unturned/run.sh"]