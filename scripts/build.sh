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
echo "|------> Начало сборки $t"

SERVERNAME="mtproto-proxy-server"
SERVERDIR="/var/www/$SERVERNAME"
MTPROTONAME="mtproto-proxy"
MTPROTODIR="/var/www/$MTPROTONAME"

# Проверка папок
if ! [ -d /var/ ]; then
  mkdir "/var"
fi
if ! [ -d /var/www/ ]; then
  mkdir "/var/www"
fi
if ! [ -d /var/www/$MTPROTONAME/ ]; then
  mkdir "/var/www/$MTPROTONAME"
fi

if ! [ -d $MTPROTODIR/ ]; then
  mkdir "$MTPROTODIR"
fi

# Права доступа
chmod 777 -R $SERVERDIR/*
chmod 777 -R $MTPROTODIR/*

# Сборка MTProxy
cd ./MTProxy-master
make
if [ $? -eq 0 ]; then
  echo "|---> Сборка MTProxy прошла успешно"
  rm -rf "../mtproto-proxy/mtproto-proxy"
  cp objs/bin/mtproto-proxy $MTPROTODIR
  echo "|---> Файл перемещен в mtproto-proxy"
  cd ..
else
  echo "|---> Сборка MTProxy завершилась ошибкой"
fi

# Права доступа
chmod 777 -R $SERVERDIR/*
chmod 777 -R $MTPROTODIR/*

echo "----------------------------------------------------------------------"

exit 0
