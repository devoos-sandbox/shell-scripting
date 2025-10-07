#!/bin/bash


component="shipping"
appContent="https://roboshop-artifacts.s3.amazonaws.com/${component}-v3.zip"
appLog="/tmp/${component}.log"
appUser="roboshop"
appDir="/app"
# Override variables

source roboshop/common.sh

maven

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
echo -e "\e[36m Service Name   : ${component}\e[0m"
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