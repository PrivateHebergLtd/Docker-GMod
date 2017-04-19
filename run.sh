#!/usr/bin/env bash

export MONO_IOMAP=all

function InstallTemplate {
	echo "[PrivateHeberg©]  Installation du serveur..."
	cd /data/unturned/Servers/${INSTANCE_ID}
	wget https://cdn.privateheberg.fr/Unturned/Template.zip -O template.zip
	unzip -o template.zip
	rm template.zip
}

function InstallRocket {
	cd /data/unturned
	[ -f RocketLauncher.exe ] && rm -rf RocketLauncher.exe
	[ -f RocketVersion.txt ] && rm -rf RocketVersion.txt
	[ -d Module/Rocket.Unturned ] && rm -rf Rocket.Unturned
	wget https://cdn.privateheberg.fr/Unturned/Rocket.zip -O rocket.zip
	unzip -o rocket.zip
	rm rocket.zip
}

function CreateCommands {
	echo "[PrivateHeberg©]  Création du fichier de Commandes..."
	cd /data/unturned/Servers/${INSTANCE_ID}
	wget https://cdn.privateheberg.fr/Unturned/Commands.dat
	echo $'\r'"port ${INSTANCE_PORT}" >> Server/Commands.dat
	echo $'\r'"maxplayers ${SLOTS}" >> Server/Commands.dat
}

for i in $(seq 1 50);
do
    echo " "
done

echo "#######################################"
echo "#  PrivateHeberg© - Module Unturned   #"
echo "#######################################"

# On va dans la parti. data
cd /data

# Création des dossiers
[ ! -d /data/backup ] && mkdir /data/backup
[ ! -d /data/unturned ] && mkdir /data/unturned


echo "[PrivateHeberg©]  Lancement de la mise à jour du SteamCMD..."
/home/unturned/steamcmd/steamcmd.sh \
    +login anonymous \
    +quit

echo "[PrivateHeberg©]  Lancement de la mise de Unturned..."
/home/unturned/steamcmd/steamcmd.sh \
	+@sSteamCmdForcePlatformBitness 32 \
	+login ${STEAM_USER} ${STEAM_PASSWORD} \
	+force_install_dir /data/unturned \
	+app_update 304930 validate \
	+quit

cd /data/unturned

find . -type f -iname \*.png -delete

# Installer Rocket
if [ ! -f RocketLauncher.exe ]; then
	echo "[PrivateHeberg©]  Installation du module Rocket car le fichier de lancement n'a pas été trouvé..."
	InstallRocket
fi

# Rechercher une mise à jour Rocket et l'installer
current_version='cat RocketVersion.txt'
last_version=$(wget https://cdn.privateheberg.fr/Unturned/RocketVersion.txt -q -O -)
if [ $current_version != $last_version ]; then
	echo "[PrivateHeberg©]  Lancement de la mise à jour du module Rocket... (version $current_version)" 
	InstallRocket
fi

# Création des répertoires
mkdir -p /data/unturned/Servers/${INSTANCE_ID}

# Fichier template
[ ! -d /data/unturned/Servers/${INSTANCE_ID}/Server ] && InstallTemplate

# Fichier de configuration
[ ! -f /data/unturned/Servers/${INSTANCE_ID}/Server/Commands.dat ] && CreateCommands

echo "[PrivateHeberg©]  Démarrage du serveur Unturned via le module Rocket !"

STEAMCMD_API=/home/unturned/steamcmd/linux32/steamclient.so
UNTURNED_API=/data/unturned/Unturned_Data/Plugins/x86/steamclient.so
if [ -f $STEAMCMD_API ]; then
	if diff $STEAMCMD_API $UNTURNED_API >/dev/null ; then
		echo "[PrivateHeberg©]  Status de l'API Steam: À jour !"
	else
		echo "[PrivateHeberg©]  Status de l'API Steam: Mise à jour !"
		cp $STEAMCMD_API $UNTURNED_API
		echo "[PrivateHeberg©]  Mise à jour de l'API Steam fini !"
	fi
fi

cd /data/unturned

if [ -f RocketLauncher.exe ]; then
	ulimit -n 2048
	mono RocketLauncher.exe ${INSTANCE_ID}
else
	echo "[PrivateHeberg©]  RocketLauncher n'a pas été trouvé. Lancement impossible :("
fi