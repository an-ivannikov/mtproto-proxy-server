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
  YES | cp -rf ./ $SERVERDIR
  cd $SERVERDIR
  chmod 777 -R $SERVERDIR/*
  sh ./install.sh
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
sh ./scripts/install-dependencies.sh


# Загрузка и распаковка MTProxy
# https://github.com/TelegramMessenger/MTProxy/archive/master.zip
sh ./scripts/download.sh

# Сборка MTProxy
sh ./scripts/build.sh

# Получение proxy-secret
sh ./scripts/get-proxy-secret.sh
# Получение telegram configuration
sh ./scripts/get-telegram-configuration.sh

# Получение proxy-secret
#sh ./scripts/get-secret.sh
mtprotoSecret=$(head -c 16 /dev/urandom | xxd -ps)
echo "$mtprotoSecret" > $MTPROTODIR/mtproto-secret
# Настройки по умолчанию
user="nobody"
echo "$user" > $MTPROTODIR/user

port=8888
echo "$port" > $MTPROTODIR/port
# Внешний порт(-ы) MTProxy
httpPorts=443
echo "$httpPorts" > $MTPROTODIR/http-ports


ethIP=$(ifconfig eth |grep "inet addr:"|cut -f 2 -d ':'|cut -f 1 -d ' ')
ethLO=$(ifconfig lo |grep "inet addr:"|cut -f 2 -d ':'|cut -f 1 -d ' ')

jsonHost=$(curl 'ifconfig.co/json')
echo "$jsonHost" > $SERVERDIR/server/server_info.json

# Внешний ip
ip=$(echo $jsonHost | jq --raw-output '.ip')
# Внешний hostname
hostname=$(echo $jsonHost | jq --raw-output '.hostname')
country=$(echo $jsonHost | jq --raw-output '.country')
country_iso=$(echo $jsonHost | jq --raw-output '.country_iso')
city=$(echo $jsonHost | jq --raw-output '.city')

op80=$(curl 'ifconfig.co/port/80' | jq --raw-output '.reachable')
op8080=$(curl 'ifconfig.co/port/8080' | jq --raw-output '.reachable')
op443=$(curl 'ifconfig.co/port/443' | jq --raw-output '.reachable')
op8888=$(curl 'ifconfig.co/port/8888' | jq --raw-output '.reachable')


natInfo="$ethIP:$ip"
echo "$natInfo" > $MTPROTODIR/nat-info
echo "" > $MTPROTODIR/proxy-tag
echo "1" > $MTPROTODIR/slaves


sh ./scripts/mtproto-proxy-install-service.sh

npm install

sh ./scripts/mtproto-proxy-server-install-service.sh

tPing=$(ping -c 3 'api.telegram.org')

links="[
{\"href\":\"tg://proxy?server=$ip&port=$httpPorts&secret=$mtprotoSecret\"},
{\"href\":\"https://t.me/proxy?server=$ip&port=$httpPorts&secret=$mtprotoSecret\"},
{\"href\":\"tg://proxy?server=$hostname&port=$httpPorts&secret=$mtprotoSecret\"},
{\"href\":\"https://t.me/proxy?server=$hostname&port=$httpPorts&secret=$mtprotoSecret\"}
]"
echo "$links" > $SERVERDIR/server/proxy_links.json

echo "----------------------------------------------------------------------"
echo "Параметры Хоста:"
echo "Внутренние:"
echo "\tИнтерфейс lo IP:\t$ethLO"
echo "\tИнтерфейс eth* IP:\t$ethIP"

echo "Внешние:"
echo "\tСтрана: $country ($country_iso), Город: $city"
echo "\tIP:\t\t$ip"
echo "\tHOSTNAME\t$hostname"
echo "\t80 открыт:\t$op80"
echo "\t443 открыт:\t$op443"
echo "\t8080 открыт:\t$op8080"
echo "\t8888 открыт:\t$op8888"
echo "Пинг до api.telegram.org:"
echo "$tPing"
echo "-> Данные для регистрации в MTProxy Admin Bot @MTProxybot"
echo "-> mtproto-secret:"
echo "\t$mtprotoSecret"
echo "-> <host>:<port>"
echo "\t$ip:$httpPorts"
echo "\t$hostname:$httpPorts"
echo ""
echo "Ссылки с ip:"
echo "\ttg://proxy?server=$ip&port=$httpPorts&secret=$mtprotoSecret"
echo "\thttps://t.me/proxy?server=$ip&port=$httpPorts&secret=$mtprotoSecret"
echo "Ссылки с hostname:"
echo "\ttg://proxy?server=$hostname&port=$httpPorts&secret=$mtprotoSecret"
echo "\thttps://t.me/proxy?server=$hostname&port=$httpPorts&secret=$mtprotoSecret"

echo "----------------------------------------------------------------------"



# Права доступа
chmod 777 -R $SERVERDIR/*
chmod 777 -R $MTPROTODIR/*



exit 0
