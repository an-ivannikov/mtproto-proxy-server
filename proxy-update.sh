#!/bin/bash

# Проверка установленных пакетов из списка
#-----------------------------------------
# sudo nano /etc/apt/sources.list
# #deb cdrom:[Ubuntu-Server 16.04 LTS _Xenial Xerus_ - Release amd64 (20160420.3)]/ xenial main restricted
#


# Возврат цвета в "нормальное" состояние
tput sgr0
# Очистка экрана
clear

SERVERNAME="mtproto-proxy-server"
SERVERDIR="/var/www/$SERVERNAME"
MTPROTONAME="mtproto-proxy"
MTPROTODIR="/var/www/$MTPROTONAME"

# Время
t=`date +%Y-%m-%d-%H-%M-%S`
Y=`date +%Y`
m=`date +%m`
d=`date +%d`



# Проверка доступа
if [ `whoami` != 'root' ]; then
  echo "Доступ запрещен. Запустите $0 от имени 'root'"
  exit 1;
fi

# Проверка папок
if ! [ -d /var/ ]; then
  mkdir "/var"
fi
if ! [ -d /var/www/ ]; then
  mkdir "/var/www"
fi
if ! [ -d $MTPROTODIR/ ]; then
  mkdir $MTPROTODIR
fi
if ! [ -d $SERVERDIR/ ]; then
  mkdir $SERVERDIR
fi

# Текущая директория
DIRSCRIPT=$(pwd)
if [ "$DIRSCRIPT" != "$SERVERDIR" ]; then
  #YES | cp -rf ./ $SERVERDIR
  cd $SERVERDIR
  chmod 777 -R $SERVERDIR/*
  sh ./proxy-update.sh
  exit 0
fi


if ! [ -d ./archive/ ]; then
  mkdir "./archive"
fi
if ! [ -d ./archive/MTProxy/ ]; then
  mkdir "./archive/MTProxy"
fi

chmod 777 -R $SERVERDIR/*
chmod 777 -R $MTPROTODIR/*


# Устанока зависимостей
#sh ./scripts/install-dependencies.sh


# Загрузка и распаковка MTProxy
# https://github.com/TelegramMessenger/MTProxy/archive/master.zip
sh ./scripts/download.sh

# Сборка MTProxy
sh ./scripts/build.sh

sh ./scripts/mtproto-proxy-install-service.sh

exit 0
