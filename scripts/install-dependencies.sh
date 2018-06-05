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

echo "|------> Начало установки зависимостей $t"

# Обновление индекса пакетов
apt-get update
if [ $? -eq 0 ]; then
  echo "|---> Обновление индекса пакетов прошло успешно"
else
  echo "|---> Обновление индекса пакетов завершилось ошибкой"
fi

# Обновление пакетов
apt-get upgrade -y
if [ $? -eq 0 ]; then
  echo "|---> Обновление пакетов прошло успешно"
else
  echo "|---> Обновление пакетов завершилось ошибкой"
fi


# Проверка пакета curl
I=`dpkg -s "curl" | grep "Status" `
if [ "$I" = "Status: install ok installed" ]; then
  echo "|---> curl установлен"
else
  echo "|---> curl не установлен"
  apt-get install -y curl
  if [ $? -eq 0 ]; then
    echo "|---> Установка curl прошла успешно"
  else
    echo "|---> Установка curl завершилась ошибкой"
  fi
fi


# Проверка пакета wget
I=`dpkg -s "wget" | grep "Status" `
if [ "$I" = "Status: install ok installed" ]; then
  echo "|---> wget установлен"
else
  echo "|---> wget не установлен"
  apt-get install -y wget
  if [ $? -eq 0 ]; then
    echo "|---> Установка wget прошла успешно"
  else
    echo "|---> Установка wget завершилась ошибкой"
  fi
fi


# Проверка пакета jq
I=`dpkg -s "jq" | grep "Status" `
if [ "$I" = "Status: install ok installed" ]; then
  echo "|---> jq установлен"
else
  echo "|---> jq не установлен"
  apt-get install -y jq
  if [ $? -eq 0 ]; then
    echo "|---> Установка jq прошла успешно"
  else
    echo "|---> Установка jq завершилась ошибкой"
  fi
fi


# Проверка пакета unzip
I=`dpkg -s "unzip" | grep "Status" `
if [ "$I" = "Status: install ok installed" ]; then
  echo "|---> unzip установлен"
else
  echo "|---> unzip не установлен"
  apt-get install -y unzip
  if [ $? -eq 0 ]; then
    echo "|---> Установка unzip прошла успешно"
  else
    echo "|---> Установка unzip завершилась ошибкой"
  fi
fi


# Проверка пакета nodejs
I=`dpkg -s "nodejs" | grep "Status" `
if [ "$I" = "Status: install ok installed" ]; then
  echo "|---> nodejs установлен"
else
  echo "|---> nodejs не установлен"
  # https://nodejs.org/en/download/package-manager/#debian-and-ubuntu-based-linux-distributions
  curl -sL "https://deb.nodesource.com/setup_8.x" | sudo -E "bash" -
  apt-get install -y nodejs
  if [ $? -eq 0 ]; then
    echo "|---> Установка nodejs прошла успешно"
  else
    echo "|---> Установка nodejs завершилась ошибкой"
  fi
fi



# Проверка пакета build-essential
I=`dpkg -s "build-essential" | grep "Status" `
if [ "$I" = "Status: install ok installed" ]; then
  echo "|---> build-essential установлен"
else
  echo "|---> build-essential не установлен"
  apt-get install -y build-essential
  if [ $? -eq 0 ]; then
    echo "|---> Установка build-essential прошла успешно"
  else
    echo "|---> Установка build-essential завершилась ошибкой"
  fi
fi

# Проверка пакета libssl-dev
I=`dpkg -s "libssl-dev" | grep "Status" `
if [ "$I" = "Status: install ok installed" ]; then
  echo "|---> libssl-dev установлен"
else
  echo "|---> libssl-dev не установлен"
  apt-get install -y libssl-dev
  if [ $? -eq 0 ]; then
    echo "|---> Установка libssl-dev прошла успешно"
  else
    echo -e "|---> Установка libssl-dev завершилась ошибкой"
  fi
fi


# Проверка пакета vnstat
I=`dpkg -s "vnstat" | grep "Status" `
if [ "$I" = "Status: install ok installed" ]; then
  echo "|---> vnstat установлен"
else
  echo "|---> vnstat не установлен"
  apt-get install -y vnstat
  if [ $? -eq 0 ]; then
    echo "|---> Установка vnstat прошла успешно"
  else
    echo -e "|---> Установка vnstat завершилась ошибкой"
  fi
fi

echo "----------------------------------------------------------------------"

exit 0
