#!/bin/bash

stat() {
  if [ $1 -eq 0 ]; then
    echo -e "\e[32m Success \e[0m"
  else
    echo -e "\e[31m Failure \e[0m"
    echo -e "\e[33m Check the log file /tmp/${component}.log for more information \e[0m"
    exit 1
  fi
}

if [ $(id -u) -ne 0 ]; then
  echo -e "\e[31m You should be running this script as root or with sudo privileges \e[0m"
  exit 1
fi


component="mysql"
appLog="/tmp/${component}.log"

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