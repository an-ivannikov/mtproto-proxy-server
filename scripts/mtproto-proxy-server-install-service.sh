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

echo "|------> Начало установки сервера $t"

SERVERNAME="mtproto-proxy-server"
SERVERDIR="/var/www/$SERVERNAME"
MTPROTONAME="mtproto-proxy"
MTPROTODIR="/var/www/$MTPROTONAME"

#systemctl -l status mtproto-proxy.service
# Проверка папок
if ! [ -d /var/ ]; then
  mkdir "/var"
fi
if ! [ -d /var/www/ ]; then
  mkdir "/var/www"
fi
if ! [ -d /var/www/$SERVERNAME/ ]; then
  mkdir "/var/www/$SERVERNAME"
fi

if ! [ -d $SERVERDIR/ ]; then
  mkdir "$SERVERDIR"
fi

# Права доступа
chmod 777 -R $SERVERDIR/*
chmod 777 -R $MTPROTODIR/*


S="[Unit]"
S="$S\nDescription=MTProxy 'mtproto-proxy-server'"
S="$S\nAfter=syslog.target"
S="$S\nAfter=network.target"
S="$S\n"
S="$S\n[Service]"
S="$S\nType=simple"
S="$S\nEnvironment=NODE_ENV=production"
S="$S\nPIDFile=$SERVERDIR/$SERVERNAME.pid"
S="$S\nWorkingDirectory=$SERVERDIR"
S="$S\n"
S="$S\nExecStart=/usr/bin/node ./server/bin/www"
S=$S'\nExecReload=/bin/kill -s HUP $MAINPID'
S=$S'\nExecStop=/bin/kill -s QUIT $MAINPID'
S="$S\nRestart=always"
S="$S\n"
S="$S\n[Install]"
S="$S\nWantedBy=multi-user.target"
S="$S\n"

echo "$S" > /etc/systemd/system/$SERVERNAME.service
systemctl enable $SERVERNAME
systemctl start $SERVERNAME
systemctl daemon-reload

exit 0
