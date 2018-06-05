#!/bin/bash

# Проверка установленных пакетов из списка
#-----------------------------------------
# sudo nano /etc/apt/sources.list
# #deb cdrom:[Ubuntu-Server 16.04 LTS _Xenial Xerus_ - Release amd64 (20160420.3)]/ xenial main restricted
#


# Проверка доступа
if [ `whoami` != 'root' ]; then
  echo "Доступ запрещен. Запустите $0 от имени 'root'"
  exit 1;
fi

# Время
t=`date +%Y-%m-%d-%H-%M-%S`

SERVERNAME="mtproto-proxy-server"
SERVERDIR="/var/www/$SERVERNAME"
MTPROTONAME="mtproto-proxy"
MTPROTODIR="/var/www/$MTPROTONAME"

echo "|------> Начало получения proxy-secret $t"

# Проверка папок
if ! [ -d $MTPROTODIR/ ]; then
  mkdir $MTPROTODIR
fi

# Права доступа
chmod 777 -R $SERVERDIR/*
chmod 777 -R $MTPROTODIR/*

curl -s https://core.telegram.org/getProxySecret -o $MTPROTODIR/proxy-secret
if [ $? -eq 0 ]; then
  echo "|---> proxy-secret получен"
else
  echo "|---> Ошибка"
fi

# Права доступа
chmod 777 -R $SERVERDIR/*
chmod 777 -R $MTPROTODIR/*

echo "----------------------------------------------------------------------"

exit 0
