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

component="frontend"
appContent="https://roboshop-artifacts.s3.amazonaws.com/${component}-v3.zip"
url="https://raw.githubusercontent.com/devoos-sandbox/shell-scripting/refs/heads/main/roboshop/nginx.conf"
appLog="/tmp/${component}.log"

echo -e -n "\e[33m Disabling default nginx: \e[0m"
dnf module disable nginx -y &>> ${appLog}
stat $?


dnf module enable nginx:1.24 -y &>> ${appLog}

echo -e -n  "\e[33m Installing nginx: \e[0m"
dnf install nginx -y  &>> ${appLog}
stat $?

echo -e -n  "\e[33m Starting nginx: \e[0m"
systemctl enable nginx   &>> ${appLog}
systemctl start nginx   &>> ${appLog}
stat $?

rm -rf /usr/share/nginx/html/*  &>> /tmp/frontend.log

echo -e -n  "\e[33m Downloading ${component} content: \e[0m"
curl -sS --fail -o /tmp/${component}.zip ${appContent} &>> ${appLog}
stat $?

cd /usr/share/nginx/html 
unzip /tmp/${component}.zip &>> ${appLog}


rm -f /etc/nginx/nginx.conf &>> ${appLog}

echo -e -n  "\e[33m Updating nginx Proxy: \e[0m"
curl ${url} &> /etc/nginx/nginx.conf &>> ${appLog}
stat $?

echo -e -n  "\e[33m Updating ${component} Configuration: \e[0m"
systemctl restart nginx 
stat $?

echo -e -n  "\n\n \t \e[32m ${component} setup completed \e[0m"