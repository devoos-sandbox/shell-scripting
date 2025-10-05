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

downloading_app_content() {
    echo -e -n  "\e[33m Downloading ${component} content: \e[0m"
    curl -sS --fail -o /tmp/${component}.zip ${appContent} &>> ${appLog}
    stat $?

    echo -e -n  "\e[33m Extracting ${component} content: \e[0m"
    rm  -rf ${appDir} &>> ${appLog}
    cd ${appDir}
    unzip -o /tmp/${component}.zip &>> ${appLog}
    stat $?
}   

