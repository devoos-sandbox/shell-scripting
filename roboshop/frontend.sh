#!/bin/bash

source roboshop/common.sh

component="frontend"
appContent="https://roboshop-artifacts.s3.amazonaws.com/${component}-v3.zip"
url="https://raw.githubusercontent.com/devoos-sandbox/shell-scripting/refs/heads/main/roboshop/nginx.conf"
appLog="/tmp/${component}.log"
appDir="/usr/share/nginx/html/"

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

downloading_app_content

echo -e -n "\e[33m Cleaning up proxy: \e[0m"
>>/etc/nginx/nginx.conf &>> ${appLog}
stat $?

echo -e -n  "\e[33m Updating nginx Proxy: \e[0m"
curl ${url} > /etc/nginx/nginx.conf
stat $?

echo -e -n  "\e[33m Updating ${component} Configuration: \e[0m"
systemctl restart nginx 
stat $?

echo -e -n  "\n\n \t \e[32m ${component} setup completed \e[0m"