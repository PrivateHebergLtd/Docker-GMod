# ========================
#  Garry's Mod Dockerfile
#     PrivateHeberg©
# ========================

FROM debian:8
MAINTAINER privateHeberg

# ==== Variables ==== #
ENV INSTANCE_ID=""
# =================== #

# ==== Paquets ==== #
RUN apt-get update
RUN dpkg --add-architecture i386
RUN apt-get update &&\
    apt-get -y install mailutils postfix curl wget file gzip bzip2 bsdmainutils python util-linux tmux lib32gcc1 libstdc++6 libstdc++6:i386 lib32tinfo5
# ================= #

# ==== Garry's Mod User ==== #
RUN adduser \
	--disabled-login \
	--shell /bin/bash \
	--gecos "" \
	gmod
RUN usermod -a -G sudo gmod
# ========================== #

# ==== Scripts ==== #
COPY run.sh /home/gmod/run.sh
RUN touch /root/.bash_profile
RUN chmod 777 /home/gmod/run.sh
RUN mkdir  /data
RUN chown gmod -R /data && chmod 755 -R /data
# ================= #

# ==== Volumes ==== #
VOLUME  /data
WORKDIR /data
# ================= #

ENTRYPOINT ["/home/gmod/run.sh"]
