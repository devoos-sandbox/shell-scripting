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

component="payment"
appContent="https://roboshop-artifacts.s3.amazonaws.com/${component}-v3.zip"
appLog="/tmp/${component}.log"
appUser="roboshop"

echo -e -n "\e[33m Installing python3 & dependencies: \e[0m"
dnf install python3 gcc python3-devel -y &>> ${appLog}
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

echo -e -n "\e[33m Downloading ${component} content: \e[0m"
curl -sS --fail -o /tmp/${component}.zip ${appContent} &>> ${appLog}
cd /app
unzip -o /tmp/${component}.zip &>> ${appLog}
stat $?

echo -e -n "\e[33m Installing ${component} dependencies: \e[0m"
cd /app
pip3 install -r requirements.txt &>> ${appLog}
stat $?

echo -e -n "\e[33m Starting ${component}: \e[0m"
systemctl daemon-reload &>> ${appLog}
systemctl enable ${component} &>> ${appLog}
systemctl start ${component} &>> ${appLog}
stat $?

echo -e "\n\n\t\e[32m ${component} setup completed \e[0m"
echo -e "\e[36m------------------------------------------------------\e[0m"
echo -e "\e[36m Service Name   : ${component}\e[0m"
echo -e "\e[36m Log File       : ${appLog}\e[0m"
echo -e "\e[36m App Directory  : /app\e[0m"
echo -e "\e[36m To check status: systemctl status ${component}\e[0m"
echo -e "\e[36m------------------------------------------------------\e[0m"
echo -e "\e[1;33mYour ${component} service is running\e[0m"
echo -e "\e[1;33mTo manage the ${component} service, use: systemctl [start|stop|status] ${component}\e[0m"
echo -e "\e[1;33mCheck the log file /tmp/${component}.log for more details.\e[0m" 