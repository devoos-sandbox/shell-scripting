#!/bin/bash

component="redis"
appLog="/tmp/${component}.log"

source roboshop/common.sh

echo -e -n "\e[33m Disabling Redis Default Version: \e[0m"
dnf module disable redis -y &>> "${appLog}"
stat $?

echo -e -n "\e[33m Enabling Redis Version 7: \e[0m"
dnf module enable redis:7 -y &>> "${appLog}"
stat $?

echo -e -n "\e[33m Installing Redis: \e[0m"
dnf install redis -y &>> "${appLog}"
stat $?

echo -e -n "\e[33m Updating ${component} Configuration: \e[0m"
sed -i -e 's|127.0.0.1|0.0.0.0|' -e 's|protected-mode yes|protected-mode no|' /etc/redis/redis.conf
stat $?

echo -e -n "\e[33m Starting ${component}: \e[0m"
systemctl enable redis &>> "${appLog}"
systemctl start redis &>> "${appLog}"
stat $?

echo -e "\n\n\t\e[1;32m✅✅✅ ${component^^} SETUP COMPLETED SUCCESSFULLY! ✅✅✅\e[0m\n"
echo -e "\e[1;33mYour Redis server is running on default port 6379\e[0m"
echo -e "\e[1;33mUse the command 'redis-cli' to connect to the Redis server\e[0m"
echo -e "\e[1;33mFor more information, visit: https://redis.io/docs/getting-started/installation/\e[0m"
echo -e "\e[1;33mTo manage the Redis service, use: systemctl [start|stop|status] redis\e[0m"
echo -e "\e[1;33mCheck the log file /tmp/${component}.log for more details.\e[0m"      