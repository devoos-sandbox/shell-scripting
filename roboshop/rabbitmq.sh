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

component="rabbitmq"
appLog="/tmp/${component}.log"
appUser="roboshop"

echo -e -n "\e[33m Setting up ${component} Repo: \e[0m"
cp "$(dirname "$0")/${component}.repo" /etc/yum.repos.d/${component}.repo
stat $?

echo -e -n "\e[33m Installing ${component}: \e[0m"
dnf install rabbitmq-server -y &>> ${appLog}
stat $?

echo -e -n "\e[33m Starting ${component} Service: \e[0m"
systemctl enable rabbitmq-server &>> ${appLog}
systemctl start rabbitmq-server &>> ${appLog}
stat $?

echo -e -n "\e[33m Configuring RabbitMQ Permissions: \e[0m"
rabbitmqctl add_user ${appUser} roboshop123 &>> ${appLog} || true 
rabbitmqctl set_permissions -p / ${appUser} ".*" ".*" ".*" &>> ${appLog}
stat $?

echo -e "\n\n\t\e[32m${component} setup completed\e[0m"
echo -e "\n\n\t\e[1;32m✅✅✅ ${component^^} SETUP COMPLETED SUCCESSFULLY! ✅✅✅\e[0m\n"
echo -e "\e[1;33mYour RabbitMQ server is running on default port 5672\e[0m"
echo -e "\e[1;33mUse the command 'rabbitmqctl' to manage RabbitMQ server\e[0m"
echo -e "\e[1;33mFor more information, visit: ${doc_url}\e[0m"
echo -e "\e[1;33mTo manage the RabbitMQ service, use: systemctl [start|stop|status] rabbitmq-server\e[0m"
echo -e "\e[1;33mCheck the log file /tmp/${component}.log for more details.\e[0m"