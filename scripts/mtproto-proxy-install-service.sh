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

echo "|------> Начало установки службы $t"

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
if ! [ -d /var/www/$MTPROTONAME/ ]; then
  mkdir "/var/www/$MTPROTONAME"
fi

if ! [ -d $MTPROTODIR/ ]; then
  mkdir "$MTPROTODIR"
fi

# Права доступа
chmod 777 -R $SERVERDIR/*
chmod 777 -R $MTPROTODIR/*

instr=""
user=$(cat "$MTPROTODIR/user")
if [ "$user" != "" ]; then
  instr="$instr--user $user"
fi
port=$(cat "$MTPROTODIR/port")
if [ "$port" != "" ]; then
  instr="$instr --port $port"
fi
httpPorts=$(cat "$MTPROTODIR/http-ports")
if [ "$httpPorts" != "" ]; then
  instr="$instr --http-ports $httpPorts"
fi

natInfo=$(cat "$MTPROTODIR/nat-info")
if [ "$natInfo" != "" ]; then
  instr="$instr --nat-info $natInfo"
fi

slaves=$(cat "$MTPROTODIR/slaves")
if [ "$slaves" != "" ]; then
  instr="$instr --slaves $slaves"
fi

mtprotoSecret=$(cat "$MTPROTODIR/mtproto-secret")
if [ "$mtprotoSecret" != "" ]; then
  instr="$instr --mtproto-secret $mtprotoSecret"
fi

instr="$instr --aes-pwd proxy-secret proxy-multi.conf"
proxyTag=$(cat "$MTPROTODIR/proxy-tag")
if [ "$proxyTag" != "" ]; then
  instr="$instr --proxy-tag $proxyTag"
fi


S="[Unit]"
S="$S\nDescription=MTProxy 'mtproto-proxy'"
S="$S\nAfter=syslog.target"
S="$S\nAfter=network.target"
S="$S\n"
S="$S\n[Service]"
S="$S\nType=simple"
S="$S\nPIDFile=$MTPROTODIR/$MTPROTONAME.pid"
S="$S\nWorkingDirectory=$MTPROTODIR"
S="$S\n"
S="$S\nExecStart=$MTPROTODIR/$MTPROTONAME $instr"
S=$S'\nExecReload=/bin/kill -s HUP $MAINPID'
S=$S'\nExecStop=/bin/kill -s QUIT $MAINPID'
S="$S\nRestart=always"
S="$S\n"
S="$S\n[Install]"
S="$S\nWantedBy=multi-user.target"
S="$S\n"

echo "$S" > /etc/systemd/system/$MTPROTONAME.service
systemctl enable $MTPROTONAME
systemctl start $MTPROTONAME
systemctl daemon-reload

exit 0
