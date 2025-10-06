if [ $(id -u) -ne 0 ]; then
  echo -e "\e[31m You should be running this script as root or with sudo privileges \e[0m"
  exit 1
fi

stat() {
  if [ $1 -eq 0 ]; then
    echo -e "\e[32m Success \e[0m"
  else
    echo -e "\e[31m Failure \e[0m"
    echo -e "\e[33m Check the log file /tmp/${component}.log for more information \e[0m"
    exit 1
  fi
}

configure_systemd() {
    # echo -e -n "\e[33m Configuring ${component} systemd: \e[0m"
    # cp ${component}.service /etc/systemd/system/${component}.service
    # stat $?

    echo -e -n "\e[33m Configuring ${component} systemd: \e[0m"
    cp "$(dirname "$0")/${component}.service" /etc/systemd/system/${component}.service 2>/dev/null || cp "roboshop/${component}.service" /etc/systemd/system/${component}.service
    stat $?
}


downloading_app_content() {
    echo -e -n  "\e[33m Downloading ${component} content: \e[0m"
    curl -sS --fail -o /tmp/${component}.zip ${appContent} &>> ${appLog}
    stat $?

    echo -e -n  "\e[33m Extracting ${component} content: \e[0m"
    rm  -rf ${appDir} &>> ${appLog}
    mkdir ${appDir} &>> ${appLog}
    unzip -o /tmp/${component}.zip -d ${appDir} &>> ${appLog}
    stat $?
}   

creating_app_user() {
    echo -e -n "\e[33m Creating AppUser: \e[0m"
    id ${appUser} &>> ${appLog}
    if [ $? -ne 0 ]; then
        useradd ${appUser} &>> ${appLog}
        stat $?
    else
        echo -e "\e[32m ${appUser} user already exists: SKIPPING \e[0m"
    fi
}   

start_service() {
    echo -e -n "\e[33m Starting ${component}: \e[0m"
    systemctl daemon-reload &>> ${appLog}
    systemctl enable ${component} &>> ${appLog}
    systemctl restart ${component} &>> ${appLog}
    stat $?
}   

message() {
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
}

nodejs() {
    echo -e -n "\e[33m Disabling default nodeVersion : \e[0m"
    dnf module disable nodejs -y &>> ${appLog} &>> ${appLog}
    dnf module enable nodejs:20 -y &>> ${appLog}
    stat $?

    echo -e -n "\e[33m Installing nodejs: \e[0m"
    dnf install nodejs -y &>> ${appLog}
    stat $?

    creating_app_user

    downloading_app_content

    echo -e -n "\e[33m Installing nodejs dependencies: \e[0m"
    cd /app
    npm install &>> ${appLog}
    stat $?

    configure_systemd
    start_service

    message
}


