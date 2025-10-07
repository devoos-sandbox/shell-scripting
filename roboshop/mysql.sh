#!/bin/bash

component="mysql"
appLog="/tmp/${component}.log"

source roboshop/common.sh

echo -e -n  "\e[33m Installing ${component}: \e[0m"
dnf install mysql-server -y  &>> ${appLog}
stat $?

echo -e -n  "\e[33m Starting ${component}: \e[0m"
systemctl enable mysqld &>> ${appLog}
systemctl start mysqld &>> ${appLog} 
stat $?

echo -e -n  "\e[33m Setting ${component} root password: \e[0m"
mysql_secure_installation --set-root-pass RoboShop@1 
stat $?

echo -e -n  "\n\n \t \e[32m ${component} setup completed \e[0m"
echo -e "\n\n\t\e[1;32m✅✅✅ ${component^^} SETUP COMPLETED SUCCESSFULLY! ✅✅✅\e[0m\n"
echo -e "\e[1;33mYour MySQL server is running on default port 3306\e[0m"
echo -e "\e[1;33mUse the command 'mysql -u root -p' to connect to the MySQL server\e[0m"
echo -e "\e[1;33mFor more information, visit: https://dev.mysql.com/doc/\e[0m"
echo -e "\e[1;33mTo manage the MySQL service, use: systemctl [start|stop|status] mysqld\e[0m"
echo -e "\e[1;33mCheck the log file /tmp/${component}.log for more details.\e[0m"   