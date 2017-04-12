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
if [ ! -f RocketLauncher.exe ]; then
	echo "--- Installation de Rocket ---"
	cp /home/unturned/rocket/RocketLauncher.exe /data/unturned
	cp /home/unturned/rocket/*.dll /data/unturned/Unturned_Headless_Data/Managed
fi


if [ ! -f /data/unturned/Servers/${INSTANCE_ID}/Server/Commands.dat ]; then
	echo "--- Création des fichiers template ---"
	cp /home/unturned/template /data/unturned/Servers/${INSTANCE_ID}/
	cd /data/unturned/Servers/${INSTANCE_ID}/
	# Ajouter les paramètres
	echo $'\r'"port ${INSTANCE_PORT}" >> Server/Commands.dat
	echo $'\r'"maxplayers ${SLOTS}" >> Server/Commands.dat
fi

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

if [ -f RocketLauncher.exe ]; then
	ulimit -n 2048
	mono RocketLauncher.exe ${INSTANCE_ID}
else
	echo "RocketLauncher n'a pas été trouvé. Lancement impossible !"
fi