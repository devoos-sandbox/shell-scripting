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

echo -e "\e[33m Disabling default nginx: \e[0m"
dnf module disable nginx -y &>> /tmp/frontend.log
stat $?


dnf module enable nginx:1.24 -y &>> /tmp/frontend.log

echo -e "\e[33m Installing nginx: \e[0m"
dnf install nginx -y  &>> /tmp/frontend.log
stat $?

systemctl enable nginx   &>> /tmp/frontend.log
systemctl start nginx   &>> /tmp/frontend.log
stat $?

rm -rf /usr/share/nginx/html/*  &>> /tmp/frontend.log

echo -e "\e[33m Downloading Frontend content: \e[0m"
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
stat $?

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>> /tmp/frontend.log


rm -f /etc/nginx/nginx.conf &>> /tmp/frontend.log

echo -e "\e[33m Updating nginx Proxy: \e[0m"
curl https://raw.githubusercontent.com/devoos-sandbox/shell-scripting/refs/heads/main/roboshop/nginx.conf >  /etc/nginx/nginx.conf

echo -e "\e[33m Updating Frontend Configuration: \e[0m"
systemctl restart nginx 
stat $?

echo -e "\n\n \t \e[32m Frontend setup completed \e[0m"