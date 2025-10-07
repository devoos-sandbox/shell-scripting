#!/bin/bash


component="mongodb"
mongodbRepo="https://raw.githubusercontent.com/devoos-sandbox/shell-scripting/refs/heads/main/roboshop/mongodb.repo"
appLog="/tmp/${component}.log"

source roboshop/common.sh

echo -e -n  "\e[33m Configuring MongoDB Repo: \e[0m"
curl -sS --fail ${mongodbRepo} -o /etc/yum.repos.d/${component}.repo &>> ${appLog}
stat $?

echo -e -n  "\e[33m Installing MongoDB: \e[0m"
dnf install mongodb-org -y &>> ${appLog}
stat $?

echo -e -n  "\e[33m Updating ${component} Configuration: \e[0m"
sed -i -e 's|127.0.0.1|0.0.0.0|' /etc/mongod.conf
systemctl daemon-reload &>> ${appLog}
stat $?

echo -e -n  "\e[33m Starting ${component}: \e[0m"
systemctl enable mongod &>> ${appLog}
systemctl start mongod &>> ${appLog}
stat $?

echo -e -n  "\n\n \t \e[32m ${component} setup completed \e[0m"
echo -e "\n\n\t\e[1;32m✅✅✅ ${component^^} SETUP COMPLETED SUCCESSFULLY! ✅✅✅\e[0m\n"
echo -e "\e[1;33mYour MongoDB server is running on default port 27017\e[0m"
echo -e "\e[1;33mUse the command 'mongo' to connect to the MongoDB server\e[0m"
echo -e "\e[1;33mFor more information, visit: https://www.mongodb.com/docs/manual/installation/\e[0m"
echo -e "\e[1;33mTo manage the MongoDB service, use: systemctl [start|stop|status] mongod\e[0m"
echo -e "\e[1;33mCheck the log file /tmp/${component}.log for more details.\e[0m"