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

component="shipping"
appContent="https://roboshop-artifacts.s3.amazonaws.com/${component}-v3.zip"
appLog="/tmp/${component}.log"
appUser="roboshop"

echo -e -n "\e[33m Installing maven: \e[0m"
dnf install maven -y &>> ${appLog}
stat $?


echo -e -n "\e[33m Creating AppUser: \e[0m"
id ${appUser} &>> ${appLog}
if [ $? -ne 0 ]; then
  useradd ${appUser} &>> ${appLog}
  stat $?
else
  echo -e "\e[32m ${appUser} user already exists: SKIPPING \e[0m"
fi

echo -e -n "\e[33m Cleanup of app directory: \e[0m"
rm -rf /app &>> ${appLog}
stat $?

echo -e -n "\e[33m Creating App Directory: \e[0m"
mkdir /app &>> ${appLog}
stat $?

echo -e -n "\e[33m Configuring ${component} systemd: \e[0m"
cp "$(dirname "$0")/${component}.service" /etc/systemd/system/${component}.service
stat $?

echo -e -n "\e[33m Downloading & Extracting ${component} content: \e[0m"
curl -sS --fail -o /tmp/${component}.zip ${appContent} &>> ${appLog}
cd /app
unzip -o /tmp/${component}.zip &>> ${appLog}
stat $?

echo -e -n "\e[33m Building ${component} Application: \e[0m"
cd /app 
mvn clean package  &>> ${appLog}
mv target/shipping-1.0.jar shipping.jar     &>> ${appLog}
stat $?

echo -e -n "\e[33m Installing mysql client: \e[0m"
dnf install mysql -y &>> ${appLog}
stat $?

echo -e -n "\e[33m Injecting ${component} Schema: \e[0m"
mysql -h mysql.roboshop.internal -uroot -pRoboShop@1 < /app/db/schema.sql &>> ${appLog}
stat $?

echo -e -n "\e[33m Injecting initial data: \e[0m"
mysql -h mysql.roboshop.internal -uroot -pRoboShop@1 < /app/db/app-user.sql  &>> ${appLog}
stat $?

echo -e -n "\e[33m Injecting master data: \e[0m"
mysql -h mysql.roboshop.internal -uroot -pRoboShop@1 < /app/db/master-data.sql &>> ${appLog}   
stat $?

echo -e -n "\e[33m Starting ${component}: \e[0m"
systemctl daemon-reload &>> ${appLog}
systemctl enable shipping &>> ${appLog}
systemctl restart shipping &>> ${appLog}
stat $?

echo -e "\n\n\t\e[32m ${component} setup completed \e[0m"
echo -e "\e[36m------------------------------------------------------\e[0m"
echo -e "\e[36m Service Name   : ${component}\e[0m
echo -e "\e[36m Log File       : ${appLog}\e[0m"
echo -e "\e[36m MySQL Host     : mysql.roboshop.internal\e[0m"
echo -e "\e[36m------------------------------------------------------\e[0m"
echo -e "\e[33m Please update the MySQL IP address in /etc/systemd/system/${component}.service file \e[0m"
echo -e "\e[33m After updating the IP address, run the below commands: \e[0m"
echo -e "\e[33m 1. systemctl daemon-reload \e[0m"
echo -e "\e[33m 2. systemctl restart ${component} \e[0m"
echo -e "\e[33m 3. Check the status of the service: systemctl status ${component} \e[0m"
echo -e "\e[1;33mTo manage the ${component} service, use: systemctl [start|stop|status] ${component}\e[0m"
echo -e "\e[1;33mCheck the log file /tmp/${component}.log for more details.\e[0m"
echo -e "\e[36m------------------------------------------------------\e[0m"
echo -e "\e[1;33mYour ${component} service is running\e[0m"
echo -e "\e[1;33mTo manage the ${component} service, use: systemctl [start|stop|status] ${component}\e[0m"
echo -e "\e[1;33mCheck the log file /tmp/${component}.log for more details.\e[0m"
echo -e "\e[36m------------------------------------------------------\e[0m" 
