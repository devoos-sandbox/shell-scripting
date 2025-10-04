#!/bin/bash

stat() {
  if [ $1 -eq 0 ]; then
    echo -e "\e[32m Success \e[0m"
  else
    echo -e "\e[31m Failure \e[0m"
    echo -e "\e[33m Check the log file /tmp/frontend.log for more information \e[0m"
    exit 1
  fi
}

component="mognodb"
mongodbRepo="https://raw.githubusercontent.com/devoos-sandbox/shell-scripting/refs/heads/main/roboshop/mongodb.repo "
appLog="/tmp/${component}.log"

echo -e -n  "\e[33m Configuring Mongodb Repo: \e[0m"
curl -sS --fail ${mongodbRepo} -o /etc/yum.repos.d/${component}.repo &>> ${appLog}
stat $?

echo -e -n  "\e[33m Installing Mongodb: \e[0m"
dnf install mongodb-org -y &>> ${appLog}
stat $?

echo -e -n  "\e[33m Starting ${component}: \e[0m"
systemctl enable mongod &>> ${appLog}
systemctl start mongod &>> ${appLog}
stat $?

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
systemctl restart mongod &>> ${appLog}
stat $?

systemctl restart mongod &>> ${appLog}
stat $?

echo -e -n  "\n\n \t \e[32m ${component} setup completed \e[0m"