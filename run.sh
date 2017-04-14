#!/usr/bin/env bash

export MONO_IOMAP=all

echo "#######################################"
echo "#  PrivateHeberg© - Module Unturned   #"
echo "#######################################"

# On va dans la parti. data
cd /data

# Création des dossiers
[ ! -d /data/backup ] && mkdir /data/backup
[ ! -d /data/unturned ] && mkdir /data/unturned
[ ! -d /data/rocket ] && mkdir /data/rocket


echo "--- Mise à jour de SteamCMD ---"
/home/unturned/steamcmd/steamcmd.sh \
    +login anonymous \
    +quit

echo "--- Mise à jour du serveur Unturned ---"
/home/unturned/steamcmd/steamcmd.sh \
	+@sSteamCmdForcePlatformBitness 32 \
	+login ${STEAM_USER} ${STEAM_PASSWORD} \
	+force_install_dir /data/unturned \
	+app_update 304930 validate \
	+quit

cd /data/unturned

# Installer Rocket
if [ ! -f RocketLauncher.exe ]; then
	echo "--- Installation de Rocket ---"
	InstallRocket
fi

# Rechercher une mise à jour Rocket et l'installer
current_version='cat RocketVersion.txt'
last_version=$(wget https://cdn.privateheberg.com/Unturned/RocketVersion.txt -q -O -)
if [ $current_version != $last_version ]; then
	echo "--- Mise à jour de Rocket ---"
	InstallRocket
fi

# Création des répertoires
mkdir -p /data/unturned/Servers/${INSTANCE_ID}

# Fichier template
[ ! -d /data/unturned/Servers/${INSTANCE_ID}/Server ] && InstallTemplate

# Fichier de configuration
[ ! -f /data/unturned/Servers/${INSTANCE_ID}/Server/Commands.dat ] && CreateCommands

echo "--- Démarrage du serveur ---"

STEAMCMD_API=/home/unturned/steamcmd/linux32/steamclient.so
UNTURNED_API=/data/unturned/Unturned_Data/Plugins/x86/steamclient.so
if [ -f $STEAMCMD_API ]; then
	if diff $STEAMCMD_API $UNTURNED_API >/dev/null ; then
		# À jour
	else
		cp $STEAMCMD_API $UNTURNED_API
		# Mise à jour
	fi
fi

cd /data/unturned

find . -type f -iname \*.png -delete # Delete useless files

if [ -f RocketLauncher.exe ]; then
	ulimit -n 2048
	mono RocketLauncher.exe ${INSTANCE_ID}
else
	echo "RocketLauncher n'a pas été trouvé. Lancement impossible !"
fi

InstallTemplate () {
	echo "--- Création des fichiers template ---"
	cd /data/unturned/Servers/${INSTANCE_ID}
	wget https://cdn.privateheberg.com/Unturned/Template.zip -O template.zip
	unzip -o template.zip
	rm template.zip
}

InstallRocket () {
	cd /data/unturned
	[ -f RocketLauncher.exe ] && rm -rf RocketLauncher.exe
	[ -f RocketVersion.txt ] && rm -rf RocketVersion.txt
	[ -d Module/Rocket.Unturned ] && rm -rf Rocket.Unturned
	wget https://cdn.privateheberg.com/Unturned/Rocket.zip -O rocket.zip
	unzip -o rocket.zip
	rm rocket.zip
}

CreateCommands () {
	cd /data/unturned/Servers/${INSTANCE_ID}
	wget https://cdn.privateheberg.com/Unturned/Commands.dat
	echo $'\r'"port ${INSTANCE_PORT}" >> Server/Commands.dat
	echo $'\r'"maxplayers ${SLOTS}" >> Server/Commands.dat
}