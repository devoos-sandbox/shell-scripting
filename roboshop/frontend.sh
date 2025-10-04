#!/bin/bash

echo -e "\e[33m Disabling default nginx: \e[0m"
dnf module disable nginx -y &>> /tmp/frontend.log

echo -e "\e[33m Enabliing Intended nginx version: \e[0m"
dnf module enable nginx:1.24 -y. &>> /tmp/frontend.log

echo -e "\e[33m Installing nginx: \e[0m"
dnf install nginx -y  &>> /tmp/frontend.log

systemctl enable nginx   &>> /tmp/frontend.log
systemctl start nginx   &>> /tmp/frontend.log

rm -rf /usr/share/nginx/html/*  &>> /tmp/frontend.log

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>> /tmp/frontend.log


rm -f /etc/nginx/nginx.conf &>> /tmp/frontend.log

echo -e "\e[33m Updating nginx Proxy: \e[0m"
curl https://raw.githubusercontent.com/devoos-sandbox/shell-scripting/refs/heads/main/roboshop/nginx.conf >  /etc/nginx/nginx.conf


systemctl restart nginx 

echo -e "\e[32m Frontend setup completed \e[0m"