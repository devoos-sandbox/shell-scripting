#!/bin/bash


component="catalogue"
appContent="https://roboshop-artifacts.s3.amazonaws.com/${component}-v3.zip"
appLog="/tmp/${component}.log"
appUser="roboshop"
appDir="/app"
# Override variables
mongodbRepo="https://raw.githubusercontent.com/devoos-sandbox/shell-scripting/refs/heads/main/roboshop/mongodb.repo"

source common.sh

nodejs

echo -e -n "\e[33m Configuring Mongodb Repo: \e[0m"
curl -sS --fail ${mongodbRepo} -o /etc/yum.repos.d/${component}.repo &>> ${appLog}
stat $?

echo -e -n "\e[33m Installing Mongodb Shell: \e[0m"
dnf install mongodb-mongosh -y &>> ${appLog}
stat $?

echo -e -n "\e[32m Injecting App Schema \e[0m"
mongosh --host mongodb.roboshop.internal </app/db/master-data.js &>> ${appLog}
stat $?

message
