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

SERVERNAME="mtproto-proxy-server"
SERVERDIR="/var/www/$SERVERNAME"
MTPROTONAME="mtproto-proxy"
MTPROTODIR="/var/www/$MTPROTONAME"

# Время
t=`date +%Y-%m-%d-%H-%M-%S`

echo "|------> Начало Загрузки MTProxy $t"
# Проверка папок
if ! [ -d ./archive/ ]; then
  mkdir "./archive"
fi
if ! [ -d ./archive/MTProxy/ ]; then
  mkdir "./archive/MTProxy"
fi

chmod 777 -R $SERVERDIR/*
chmod 777 -R $MTPROTODIR/*

# Загрузка и распаковка MTProxy
# https://github.com/TelegramMessenger/MTProxy/archive/master.zip
wget -O "./archive/MTProxy/$t.MTProxy.zip" https://github.com/TelegramMessenger/MTProxy/archive/master.zip
if [ $? -eq 0 ]; then
  echo "|---> Загрузка MTProxy прошла успешно"
  rm -rf "./MTProxy-master"
  #mkdir "./MTProxy-master"
  unzip -qq ./archive/MTProxy/$t.MTProxy.zip
  if [ $? -eq 0 ]; then
    echo "|---> Распаковка MTProxy прошла успешно"
  else
    echo "|---> Распаковка MTProxy завершилась ошибкой"
  fi
else
  echo "|---> Загрузка MTProxy завершилась ошибкой"
fi

# Права доступа
chmod 777 -R $SERVERDIR/*
chmod 777 -R $MTPROTODIR/*

echo "----------------------------------------------------------------------"

exit 0
