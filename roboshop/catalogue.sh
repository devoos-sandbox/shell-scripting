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

component="catalogue"
appContent="https://roboshop-artifacts.s3.amazonaws.com/${component}-v3.zip"
url="https://raw.githubusercontent.com/devoos-sandbox/shell-scripting/refs/heads/main/roboshop/nginx.conf"
appLog="/tmp/${component}.log"
appUser="roboshop"
appContent="https://roboshop-artifacts.s3.amazonaws.com/${component}-v3.zip"

echo -e -n "\e[33m Disabling default nodeVersion : \e[0m"
  dnf module disable nodejs -y  &>> ${appLog}
  dnf module enable nodejs:20 -y    &>> ${appLog}
stat $?

echo -e -n  "\e[33m Installing nodejs: \e[0m"
dnf install nodejs -y  &>> ${appLog}
stat $?

echo -e -n "\e[33m Creating AppUser: \e[0m"
id ${appUser} &>> ${appLog}
if [ $? -ne 0 ]; then
    useradd ${appUser} &>> ${appLog}
    stat $?
else
    echo -e "\e[32m ${appUser} user already exists: SKIPPING \e[0m"
fi

echo -e -n  "\e[33m Cleanup of app directory: \e[0m"
rm -rf /app &>> ${appLog}
stat $?

echo -e -n  "\e[33m Creating App Directory: \e[0m"
mkdir /app &>> ${appLog}    
stat $? 

exho -e -n  "\e[33m Downloading ${component} content: \e[0m"
# curl -sS --fail -o /tmp/${component}.zip ${appContent} &>> ${appLog}
curl -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}-v3.zip
cd /app
unzip /tmp/${component}.zip &>> ${appLog}
stat $? 

echo -e -n  "\e[33m Installing nodejs dependencies: \e[0m"
cd /app
npm install &>> ${appLog}
stat $?


echo -e -n "\e[33m Configuring ${component} systemd: \e[0m"
cp ./${component}.service /etc/systemd/system/${component}.service
stat $? 

echo -e -n  "\e[33m Starting ${component}: \e[0m"
systemctl daemon-reload &>> ${appLog}
systemctl enable ${component}   &>> ${appLog}
systemctl start ${component}   &>> ${appLog}
stat $?

echo -e -n  "\n\n \t \e[32m ${component} setup completed \e[0m"
